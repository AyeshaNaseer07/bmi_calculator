import 'dart:async';

import '../../data/services/analytics_service.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/open_url.dart';
import '../../data/services/remote_config_service.dart';
import '../../data/services/price_service.dart';
import '../../data/services/subscription_service.dart';
import '../widgets/ads/interstitial_ad_manager.dart';
import '../widgets/animated_cta_button.dart';
import '../widgets/premium_congrats_dialog.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final AppController _appController = Get.find<AppController>();
  SubscriptionPlan _selectedPlan = SubscriptionPlan.yearly;
  bool _isLoading = false;
  bool _showCloseButton = false;
  Timer? _crossDelayTimer;
  bool _fromOnboarding = false;
  Map<SubscriptionPlan, PlanPrice> _prices = PriceService.cached(
    PaywallType.onboarding,
  );

  static const Color _green = Color(0xFF0AA37D);

  Color get _ringBorder => const Color(0xFFB4E4D7);
  Color get _lineColor => const Color(0xFFD1D5DB);
  Color get _badgeFill => const Color(0x666CF8BB);
  Color get _badgeText => const Color(0xFF00714D);

  @override
  void initState() {
    super.initState();
    AnalyticsService.log(AnalyticsService.paywallView, {
      'paywall': 'onboarding',
    });
    final args = Get.arguments;
    if (args is Map && args['fromOnboarding'] == true) {
      _fromOnboarding = true;
    }
    _selectedPlan = _appController.remoteConfigService.defaultPlan(
      PaywallType.onboarding,
    );
    _initCrossDelay();
    _loadPrices();
    InterstitialAdManager.instance.load(_crossAdPlacement);
  }

  Future<void> _loadPrices() async {
    final prices = await PriceService.load(
      _appController.remoteConfigService,
      PaywallType.onboarding,
    );
    if (!mounted) return;
    setState(() {
      _prices = prices;
    });
  }

  void _initCrossDelay() {
    final delaySeconds = _appController.remoteConfigService.crossDelaySeconds(
      PaywallType.onboarding,
    );
    if (delaySeconds <= 0) {
      _showCloseButton = true;
    } else {
      _crossDelayTimer = Timer(Duration(seconds: delaySeconds), () {
        if (mounted) setState(() => _showCloseButton = true);
      });
    }
  }

  @override
  void dispose() {
    _crossDelayTimer?.cancel();
    super.dispose();
  }

  /// `onb_paywall_*` in Remote Config, wherever this paywall is opened from.
  static const InterstitialPlacement _crossAdPlacement =
      InterstitialPlacement.onbPaywallCross;

  void _onClose() {
    // Can't leave while a purchase or restore is in progress.
    if (_isLoading) return;
    AnalyticsService.log(AnalyticsService.paywallClose, {
      'paywall': 'onboarding',
    });
    InterstitialAdManager.instance.show(
      _crossAdPlacement,
      onDone: _leavePaywall,
    );
  }

  void _leavePaywall() {
    if (_fromOnboarding) {
      _appController.completeOnboarding();
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.back();
    }
  }

  Future<void> _onSubscribe() async {
    if (_isLoading) return;
    if (!_offer(_selectedPlan).isAvailable) {
      // The splash fetch may still be running; give it a moment, then retry.
      await _loadPrices().timeout(const Duration(seconds: 3), onTimeout: () {});
      if (!mounted) return;
      if (!_offer(_selectedPlan).isAvailable) {
        Get.snackbar('no_product_found'.tr, 'check_internet_connection'.tr);
        return;
      }
    }
    setState(() => _isLoading = true);

    final selectedProductId = _appController.remoteConfigService.getProductId(
      _selectedPlan,
      PaywallType.onboarding,
    );
    debugPrint('Subscribing with remote product ID: $selectedProductId');

    bool success = false;
    try {
      success = await _appController.upgradeToPremium(
        _selectedPlan,
        PaywallType.onboarding,
      );
    } catch (e) {
      debugPrint('Subscription error: $e');
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Cancelled or failed: stay on the paywall.
    if (!success) return;
    _appController.completeOnboarding();
    await PremiumCongratsDialog.show();
    if (!mounted) return;
    Get.offAllNamed(AppRoutes.home);
  }

  Future<void> _onRestore() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    bool restored = false;
    try {
      restored = await _appController.restorePurchases();
    } catch (e) {
      debugPrint('Restore error: $e');
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (restored) {
      await PremiumCongratsDialog.show(isRestore: true);
      _leavePaywall();
    } else {
      Get.snackbar('restore'.tr, 'no_previous_purchase_found'.tr);
    }
  }

  PlanOffer _offer(SubscriptionPlan slot) => PriceService.offerFor(
    slot,
    _appController.remoteConfigService,
    _prices,
    PaywallType.onboarding,
  );

  String _breakdown(PlanOffer o) => o.price == null
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
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FCF9),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(AppAssets.premiumBg, fit: BoxFit.cover),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 4.h),

                    // Crown: shrinks automatically when space is tight
                    Flexible(
                      flex: 3,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 88.w),
                        child: Image.asset(
                          AppAssets.softCrown,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),

                    // Title with wreaths
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppAssets.wreathRight,
                          width: 22.56.w,
                          height: 44.44.h,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'unlock'.tr,
                                    style: TextStyle(
                                      color: AppPalette.textPrimary,
                                      fontSize: 32.sp,
                                      fontFamily: 'Outfit',
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'premium'.tr,
                                    style: TextStyle(
                                      color: _green,
                                      fontSize: 32.sp,
                                      fontFamily: 'Outfit',
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Image.asset(
                          AppAssets.wreathLeft,
                          width: 22.56.w,
                          height: 44.44.h,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),

                    // Premium Health Pass Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 22.w,
                        vertical: 7.h,
                      ),
                      decoration: ShapeDecoration(
                        color: _badgeFill,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        shadows: const [
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
                          Image.asset(
                            AppAssets.softBadge,
                            width: 20.w,
                            height: 20.w,
                          ),
                          SizedBox(width: 6.w),
                          Flexible(
                            child: Text(
                              'premium_health_pass'.tr,
                              style: TextStyle(
                                color: _badgeText,
                                fontSize: 12.sp,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w700,
                                height: 1.27,
                                letterSpacing: 0.55,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18.h),

                    Expanded(
                      flex: 8,
                      child: Container(
                        width: double.infinity,
                        constraints: BoxConstraints(minHeight: 150.h),
                        decoration: ShapeDecoration(
                          color: AppPalette.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          shadows: [
                            BoxShadow(
                              color: const Color(0x3F33D2AB),
                              blurRadius: 13.9,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 10.h,
                          ),
                          child: Column(
                            children: [
                              _buildFeatureRow(
                                imagePath: AppAssets.preIcon1,
                                title: 'unlimited_bmi_history'.tr,
                              ),
                              _buildFeatureDivider(),
                              _buildFeatureRow(
                                imagePath: AppAssets.preIcon2,
                                title: 'personalized_meal_plan'.tr,
                              ),
                              _buildFeatureDivider(),
                              _buildFeatureRow(
                                imagePath: AppAssets.preIcon3,
                                title: 'weight_progress_analytics'.tr,
                              ),
                              _buildFeatureDivider(),
                              _buildFeatureRow(
                                imagePath: AppAssets.preIcon4,
                                title: 'your_healthy_weight_plan'.tr,
                              ),
                              _buildFeatureDivider(),
                              _buildFeatureRow(
                                imagePath: AppAssets.preIcon5,
                                title: 'ad_free_experience'.tr,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Plan Selection
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _buildPlanCard(
                            plan: SubscriptionPlan.monthly,
                            title: '${left.type.name}_plan'.tr,
                            price: (left.price?.priceString ?? '--'),
                            period: _breakdown(left),
                            showBestValue: leftIsBest,
                            shadowColor: const Color(0x9189DED6),
                            shadowBlur: 13.1,
                            shadowOffset: Offset.zero,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Container(
                            width: 28.w,
                            height: 28.w,
                            decoration: BoxDecoration(
                              color: AppPalette.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _ringBorder,
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0x1A33D2AB),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'or_caps'.tr,
                                style: TextStyle(
                                  color: _green,
                                  fontSize: 9.sp,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: _buildPlanCard(
                            plan: SubscriptionPlan.yearly,
                            title: '${right.type.name}_plan'.tr,
                            price: (right.price?.priceString ?? '--'),
                            period: _breakdown(right),
                            showBestValue: !leftIsBest,
                            shadowColor: const Color(0x2433D2AB),
                            shadowBlur: 12,
                            shadowOffset: const Offset(0, 3),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 28.h),
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
                                _offer(_selectedPlan).product,
                                PaywallType.onboarding,
                              ),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1BD19E), Color(0xFF0AA37D)],
                              ),
                              borderRadius: BorderRadius.circular(28.r),
                              height: 52.h,
                              isLoading: _isLoading,
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
                              onPressed: _isLoading ? null : _onSubscribe,
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
                    SizedBox(height: 10.h),

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
                              fontSize: 12.sp,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
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

                    // Footer links
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildFooterLink(
                            'privacy_policy'.tr,
                            () => openUrl(AppStrings.privacyPolicyUrl),
                          ),
                          _buildFooterDivider(),
                          _buildFooterLink('restore_purchase'.tr, _onRestore),
                          _buildFooterDivider(),
                          _buildFooterLink(
                            'terms_of_use'.tr,
                            () => openUrl(AppStrings.termsUrl),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),

            // Close button
            PositionedDirectional(
              top: 14.h,
              start: 18.w,
              child: SafeArea(
                child: AnimatedOpacity(
                  opacity: _showCloseButton ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  child: IgnorePointer(
                    ignoring: !_showCloseButton,
                    child: GestureDetector(
                      onTap: _onClose,
                      child: Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFBFEFDF),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Image.asset(
                            AppAssets.preCross,
                            width: 12.w,
                            height: 12.w,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required SubscriptionPlan plan,
    required String title,
    required String price,
    required String period,
    required Color shadowColor,
    required double shadowBlur,
    required Offset shadowOffset,
    bool showBestValue = false,
  }) {
    final bool selected = _selectedPlan == plan;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [Colors.white, Color(0xFFEFFAF6)],
          ),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: selected ? _green : (const Color(0xFFE2F4EE)),
            width: selected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: shadowBlur,
              offset: shadowOffset,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 26.h,
              child: CustomPaint(painter: _WavePainter(selected)),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPlanRadio(selected),
                      if (showBestValue)
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
                                    height: 9.h,
                                    width: 9.w,
                                  ),
                                  SizedBox(width: 3.w),
                                  Flexible(
                                    child: Text(
                                      'best_value'.tr,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 7.5.sp,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
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
                  SizedBox(height: 8.h),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      style: TextStyle(
                        color: const Color(0xFF0F1F4B),
                        fontSize: 14.sp,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  _priceSlot(
                    height: 30.sp,
                    loading: price.isEmpty,
                    placeholder: const CupertinoActivityIndicator(
                      color: Color(0xFF09B389),
                    ),
                    child: Text(
                      price,
                      maxLines: 1,
                      style: TextStyle(
                        color: const Color(0xFF09B389),
                        fontSize: 22.sp,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _priceSlot(
                    height: 16.sp,
                    loading: period.isEmpty,
                    placeholder: Container(
                      width: 56.w,
                      height: 8.sp,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5EAF0),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    child: Text(
                      period,
                      maxLines: 1,
                      style: TextStyle(
                        color: const Color(0xFF9CA3AF),
                        fontSize: 12.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceSlot({
    required double height,
    required bool loading,
    required Widget placeholder,
    required Widget child,
  }) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: loading
            ? Center(key: const ValueKey('loading'), child: placeholder)
            : FittedBox(
                key: const ValueKey('loaded'),
                fit: BoxFit.scaleDown,
                child: child,
              ),
      ),
    );
  }

  Widget _buildPlanRadio(bool isSelected) {
    if (isSelected) {
      return Container(
        width: 18.w,
        height: 18.w,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: _green),
        child: Icon(Icons.check, size: 12.sp, color: Colors.white),
      );
    }
    return Container(
      width: 18.w,
      height: 18.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _ringBorder, width: 1.5),
        color: AppPalette.surface,
      ),
    );
  }

  Widget _buildFeatureDivider() {
    return Divider(height: 1, thickness: 0.8, color: AppPalette.divider);
  }

  Widget _buildFeatureRow({required String imagePath, required String title}) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              width: 32.w,
              height: 32.w,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF0F1F2E),
                  fontSize: 15.sp,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Image.asset(AppAssets.preDown, width: 19.w, height: 19.w),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterLink(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11.sp,
          // Same as the meal plan paywall's links.
          color: AppPalette.textSecondary,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildFooterDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Text(
        '|',
        style: TextStyle(fontSize: 11.sp, color: const Color(0xFFCBD5E1)),
      ),
    );
  }
}

/// Soft wave along the bottom of a plan card.
class _WavePainter extends CustomPainter {
  final bool selected;
  const _WavePainter(this.selected);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * 0.55)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.15,
        size.width * 0.45,
        size.height * 0.95,
        size.width * 0.7,
        size.height * 0.55,
      )
      ..cubicTo(
        size.width * 0.85,
        size.height * 0.3,
        size.width * 0.95,
        size.height * 0.4,
        size.width,
        size.height * 0.5,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = selected ? const Color(0x3333D2AB) : const Color(0x2294A3B8),
    );
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.selected != selected;
}
