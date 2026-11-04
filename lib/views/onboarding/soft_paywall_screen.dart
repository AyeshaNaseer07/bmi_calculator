import 'dart:async';

import '../../data/services/analytics_service.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/open_url.dart';
import '../../data/services/price_service.dart';
import '../../data/services/remote_config_service.dart';
import '../../data/services/subscription_service.dart';
import '../widgets/ads/interstitial_ad_manager.dart';
import '../widgets/animated_cta_button.dart';
import '../widgets/premium_congrats_dialog.dart';

class SoftPaywallScreen extends StatefulWidget {
  final VoidCallback? onUnlocked;
  final VoidCallback? onDismissed;

  const SoftPaywallScreen({super.key, this.onUnlocked, this.onDismissed});

  @override
  State<SoftPaywallScreen> createState() => _SoftPaywallScreenState();
}

class _SoftPaywallScreenState extends State<SoftPaywallScreen> {
  final AppController _app = Get.find<AppController>();
  SubscriptionPlan _plan = SubscriptionPlan.yearly;
  bool _loading = false;
  bool _showCloseButton = false;
  Timer? _crossDelayTimer;

  @override
  void initState() {
    super.initState();
    AnalyticsService.log(AnalyticsService.paywallView, {'paywall': 'week'});
    _plan = _app.remoteConfigService.defaultPlan(PaywallType.week);
    InterstitialAdManager.instance.load(InterstitialPlacement.weekPaywallCross);
    final delay = _app.remoteConfigService.crossDelaySeconds(PaywallType.week);
    if (delay <= 0) {
      _showCloseButton = true;
    } else {
      _crossDelayTimer = Timer(Duration(seconds: delay), () {
        if (mounted) setState(() => _showCloseButton = true);
      });
    }
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    await PriceService.load(_app.remoteConfigService, PaywallType.week);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _crossDelayTimer?.cancel();
    super.dispose();
  }

  static const Color _green = Color(0xFF0AA37D);

  Color get _navy => const Color(0xFF0F1F4B);
  Color get _ringBorder => const Color(0xFFB4E4D7);
  Color get _lineColor => const Color(0xFFD1D5DB);

  static List<(String, String)> get _features => [
    (
      'n_7_day_personalized_meal_plan'.tr,
      'breakfast_lunch_dinner_planned_for_every'.tr,
    ),
    ('meal_benefits_nutrition'.tr, 'see_the_benefits_and_nutrition_of'.tr),
    ('ingredients_for_every_meal'.tr, 'get_a_clear_ingredient_list_for'.tr),
    ('mark_meals_as_eaten'.tr, 'track_each_breakfast_lunch_dinner_as'.tr),
    (
      'track_your_weekly_progress'.tr,
      'see_your_progress_based_on_completed'.tr,
    ),
  ];

  Future<void> _subscribe() async {
    if (_loading) return;
    if (!_offer(_plan).isAvailable) {
      // The splash fetch may still be running; give it a moment, then retry.
      await _loadPrices().timeout(const Duration(seconds: 3), onTimeout: () {});
      if (!mounted) return;
      if (!_offer(_plan).isAvailable) {
        Get.snackbar('no_product_found'.tr, 'check_internet_connection'.tr);
        return;
      }
    }
    setState(() => _loading = true);
    bool ok = false;
    try {
      ok = await _app.upgradeToPremium(_plan, PaywallType.week);
    } catch (e) {
      debugPrint('Subscription error: $e');
    }
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      await PremiumCongratsDialog.show();
      Get.back();
      widget.onUnlocked?.call();
    }
  }

  void _close() {
    // Can't leave while a purchase or restore is in progress.
    if (_loading) return;
    InterstitialAdManager.instance.show(
      InterstitialPlacement.weekPaywallCross,
      onDone: () {
        Get.back();
        if (_app.remoteConfigService.isSoftPaywallAccessEnabled) {
          widget.onUnlocked?.call();
        } else {
          widget.onDismissed?.call();
        }
      },
    );
  }

  Future<void> _restore() async {
    if (_loading) return;
    setState(() => _loading = true);
    bool restored = false;
    try {
      restored = await _app.restorePurchases();
    } catch (e) {
      debugPrint('Restore error: $e');
    }
    if (!mounted) return;
    setState(() => _loading = false);
    if (restored) {
      await PremiumCongratsDialog.show(isRestore: true);
      Get.back();
      widget.onUnlocked?.call();
    } else {
      Get.snackbar('restore'.tr, 'no_previous_purchase_found'.tr);
    }
  }

  PlanOffer _offer(SubscriptionPlan slot) =>
      PriceService.offerFor(slot, _app.remoteConfigService, PaywallType.week);

  // Per-day / per-month breakdown, same as the main paywall.
  String _period(PlanOffer o) => o.price == null
      ? '--'
      : switch (o.type) {
          PlanType.yearly => 'price_per_month'.trParams({
            'price': o.price!.perMonth(o.type),
          }),
          PlanType.monthly => 'price_per_week'.trParams({
            'price': o.price!.perWeek(o.type),
          }),
          PlanType.weekly => 'price_per_day'.trParams({
            'price': o.price!.perDay(o.type),
          }),
          PlanType.lifetime => 'one_time_payment'.tr,
        };

  @override
  Widget build(BuildContext context) {
    // Card titles follow the product, not the slot it sits in.
    final left = _offer(SubscriptionPlan.monthly);
    final right = _offer(SubscriptionPlan.yearly);
    final leftIsBest = left.type.rank > right.type.rank;
    return PopScope(
      canPop: !_loading,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(AppAssets.softBg, fit: BoxFit.cover),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedOpacity(
                        opacity: _showCloseButton ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: IgnorePointer(
                          ignoring: !_showCloseButton,
                          child: GestureDetector(
                            onTap: _close,
                            child: Container(
                              width: 28.w,
                              height: 28.w,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0x22000000),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                AppAssets.preCross,
                                width: 12.w,
                                height: 12.w,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 84.h),
                        child: Image.asset(
                          AppAssets.softCrown,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    _title(context),
                    SizedBox(height: 10.h),
                    _badge(),
                    SizedBox(height: 8.h),
                    Text(
                      'better_meals_healthier_you'.tr,
                      style: TextStyle(
                        color: AppPalette.textBody,
                        fontSize: 11.sp,
                        fontFamily: 'Inter',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12.h),
                    Expanded(flex: 9, child: _featureCard()),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Expanded(
                          child: _planCard(
                            SubscriptionPlan.monthly,
                            '${left.type.name}_plan'.tr,
                            (left.price?.priceString ?? '--'),
                            _period(left),
                            best: leftIsBest,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.w),
                          child: Container(
                            width: 24.w,
                            height: 24.w,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppPalette.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: _ringBorder, width: 1),
                            ),
                            child: Text(
                              'or_caps'.tr,
                              style: TextStyle(
                                color: AppPalette.textSecondary,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _planCard(
                            SubscriptionPlan.yearly,
                            '${right.type.name}_plan'.tr,
                            (right.price?.priceString ?? '--'),
                            _period(right),
                            best: !leftIsBest,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Image.asset(
                          AppAssets.softLeft,
                          width: 16.w,
                          height: 30.h,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Obx(
                            () => AnimatedCtaButton(
                              text: PriceService.getCtaLabel(
                                _offer(_plan).product,
                                PaywallType.week,
                              ),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1BD19E), Color(0xFF078A6A)],
                              ),
                              borderRadius: BorderRadius.circular(28.r),
                              height: 52.h,
                              isLoading: _loading,
                              leadingIcon: Image.asset(
                                AppAssets.premiumCrown,
                                width: 18.w,
                                height: 18.w,
                                color: Colors.white,
                                fit: BoxFit.contain,
                              ),
                              trailingIcon: Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                              onPressed: _loading ? null : _subscribe,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Image.asset(
                          AppAssets.softRight,
                          width: 16.w,
                          height: 30.h,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 32.w,
                          child: Divider(height: 1, color: _lineColor),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Text(
                            'cancel_anytime'.tr,
                            style: TextStyle(
                              color: AppPalette.textSecondary,
                              fontSize: 11.sp,
                              fontFamily: 'Inter',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          width: 32.w,
                          child: Divider(height: 1, color: _lineColor),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _link(
                            'privacy_policy'.tr,
                            () => openUrl(AppStrings.privacyPolicyUrl),
                          ),
                          _sep(),
                          _link('restore_purchase'.tr, _restore),
                          _sep(),
                          _link(
                            'terms_of_use'.tr,
                            () => openUrl(AppStrings.termsUrl),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title(BuildContext context) {
    // Locked to LTR so the wreaths don't swap sides in RTL languages; the
    // title text keeps the real direction.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppAssets.wreathRight, height: 44.h, fit: BoxFit.contain),
          SizedBox(width: 6.w),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'unlock'.tr,
                      style: TextStyle(
                        color: _navy,
                        fontSize: 30.sp,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: 'premium'.tr,
                      style: TextStyle(
                        color: _green,
                        fontSize: 30.sp,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                textDirection: Directionality.of(context),
              ),
            ),
          ),
          SizedBox(width: 6.w),
          Image.asset(AppAssets.wreathLeft, height: 44.h, fit: BoxFit.contain),
        ],
      ),
    );
  }

  Widget _badge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0x666CF8BB),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(AppAssets.softBadge, width: 18.w, height: 18.w),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              'n_7_day_healthy_meal_plan'.tr,
              style: TextStyle(
                color: const Color(0xFF00714D),
                fontSize: 11.sp,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureCard() {
    final rows = <Widget>[];
    for (var i = 0; i < _features.length; i++) {
      if (i > 0) {
        rows.add(
          Divider(height: 1, thickness: 0.8, color: const Color(0xFFE5E7EB)),
        );
      }
      rows.add(Expanded(child: _featureRow(i)));
    }
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0x3333D2AB),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: rows),
    );
  }

  Widget _featureRow(int i) {
    final f = _features[i];
    return Row(
      children: [
        Image.asset(AppAssets.softIcons[i], width: 40.w, height: 40.w),
        SizedBox(width: 12.w),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: constraints.maxWidth,
                child: _featureText(f),
              ),
            ),
          ),
        ),
        Container(
          width: 22.w,
          height: 22.w,
          decoration: const BoxDecoration(
            color: _green,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_rounded, size: 14.sp, color: Colors.white),
        ),
      ],
    );
  }

  Widget _featureText((String, String) f) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          f.$1,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _navy,
            fontSize: 13.sp,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          f.$2,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppPalette.textSecondary,
            fontSize: 10.sp,
            fontFamily: 'Inter',
            height: 1.25,
          ),
        ),
      ],
    );
  }

  Widget _planCard(
    SubscriptionPlan plan,
    String title,
    String price,
    String period, {
    bool best = false,
  }) {
    final sel = _plan == plan;
    return GestureDetector(
      onTap: () => setState(() => _plan = plan),
      child: Container(
        padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
        decoration: BoxDecoration(
          color: AppPalette.surface,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: sel ? _green : (const Color(0xFFD7EFE8)),
            width: sel ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: sel ? const Color(0x3333D2AB) : const Color(0x1A33D2AB),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 18.w,
                  height: 18.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: sel ? _green : AppPalette.surface,
                    border: sel
                        ? null
                        : Border.all(color: _ringBorder, width: 1.4),
                  ),
                  child: sel
                      ? Icon(Icons.check, size: 12.sp, color: Colors.white)
                      : null,
                ),
                if (best)
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB800),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              AppAssets.bestValueCrown,
                              width: 9.w,
                              height: 9.w,
                            ),
                            SizedBox(width: 3.w),
                            Flexible(
                              child: Text(
                                'best_value'.tr,
                                style: TextStyle(
                                  fontSize: 7.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xFF374151),
                fontSize: 13.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(
              height: 32.sp,
              width: double.infinity,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: price.isEmpty
                    ? Center(
                        key: const ValueKey('loading'),
                        child: const CupertinoActivityIndicator(
                          color: Color(0xFF09B389),
                        ),
                      )
                    : FittedBox(
                        key: const ValueKey('loaded'),
                        fit: BoxFit.scaleDown,
                        child: Text(
                          price,
                          maxLines: 1,
                          style: TextStyle(
                            color: const Color(0xFF09B389),
                            fontSize: 24.sp,
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
              ),
            ),
            Text(
              period.isEmpty ? ' ' : period,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xFF9CA3AF),
                fontSize: 11.sp,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _link(String t, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Text(
      t,
      style: TextStyle(
        fontSize: 10.sp,
        color: AppPalette.textSecondary,
        fontFamily: 'Inter',
      ),
    ),
  );

  Widget _sep() => Padding(
    padding: EdgeInsets.symmetric(horizontal: 10.w),
    child: Text(
      '|',
      style: TextStyle(fontSize: 10.sp, color: const Color(0xFFCBD5E1)),
    ),
  );
}
