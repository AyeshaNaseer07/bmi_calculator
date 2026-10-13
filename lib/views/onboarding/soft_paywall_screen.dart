import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../data/services/subscription_service.dart';
import '../widgets/animated_cta_button.dart';

/// Soft paywall shown when a free user opens the 1 Week Meal Plan.
/// The hard paywall ([PaywallScreen]) is untouched.
class SoftPaywallScreen extends StatefulWidget {
  /// Called after a successful purchase (the screen closes first).
  /// Defaults to just going back.
  final VoidCallback? onUnlocked;

  const SoftPaywallScreen({super.key, this.onUnlocked});

  @override
  State<SoftPaywallScreen> createState() => _SoftPaywallScreenState();
}

class _SoftPaywallScreenState extends State<SoftPaywallScreen> {
  final AppController _app = Get.find<AppController>();
  SubscriptionPlan _plan = SubscriptionPlan.yearly;
  bool _loading = false;

  static const Color _green = Color(0xFF0AA37D);
  static const Color _navy = Color(0xFF0F1F4B);

  static const _features = <(String, String)>[
    (
      '7-Day Personalized Meal Plan',
      'Breakfast, lunch & dinner planned\nfor every day.',
    ),
    (
      'Meal Benefits & Nutrition',
      'See the benefits and nutrition\nof every meal.',
    ),
    (
      'Ingredients for Every Meal',
      'Get a clear ingredient list for\neasy preparation.',
    ),
    (
      'Mark Meals as Eaten',
      'Track each breakfast, lunch & dinner\nas you complete it.',
    ),
    (
      'Track Your Weekly Progress',
      'See your progress based on\ncompleted meals.',
    ),
  ];

  Future<void> _subscribe() async {
    if (_loading) return;
    setState(() => _loading = true);
    bool ok = false;
    try {
      ok = await _app.upgradeToPremium(_plan);
    } catch (e) {
      debugPrint('Subscription error: $e');
    }
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      Get.back();
      widget.onUnlocked?.call();
    }
  }

  Future<void> _restore() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await _app.subscriptionService.restorePurchases();
    } catch (e) {
      debugPrint('Restore error: $e');
    }
    if (!mounted) return;
    setState(() => _loading = false);
    Get.snackbar('Restore', 'Purchase restored successfully (demo).');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    child: GestureDetector(
                      onTap: Get.back,
                      child: Container(
                        width: 34.w,
                        height: 34.w,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          AppAssets.preCross,
                          width: 12.w,
                          height: 12.w,
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
                  _title(),
                  SizedBox(height: 10.h),
                  _badge(),
                  SizedBox(height: 8.h),
                  Text(
                    'Better Meals  •  Healthier You',
                    style: TextStyle(
                      color: const Color(0xFF4B5563),
                      fontSize: 11.sp,
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Expanded(flex: 9, child: _featureCard()),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Expanded(
                        child: _planCard(
                          SubscriptionPlan.monthly,
                          'Monthly Plan',
                          '\$4.99',
                          '1 / month',
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        child: Container(
                          width: 24.w,
                          height: 24.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFB4E4D7),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: const Color(0xFF6B7280),
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _planCard(
                          SubscriptionPlan.yearly,
                          'Yearly Plan',
                          '\$29.99',
                          '1 / year',
                          best: true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  AnimatedCtaButton(
                    text: _loading
                        ? 'Processing...'
                        : _app.remoteConfigService.buttonText,
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
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Color(0xFFD1D5DB))),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Text(
                          '7 Days Free  •  Cancel Anytime',
                          style: TextStyle(
                            color: const Color(0xFF6B7280),
                            fontSize: 11.sp,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Color(0xFFD1D5DB))),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _link('Privacy Policy', () {}),
                        _sep(),
                        _link('Restore Purchase', _restore),
                        _sep(),
                        _link('Terms of Use', () {}),
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
    );
  }

  Widget _title() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(AppAssets.softLeft, height: 40.h, fit: BoxFit.contain),
        SizedBox(width: 6.w),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Unlock ',
                    style: TextStyle(
                      color: _navy,
                      fontSize: 30.sp,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text: 'Premium',
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
            ),
          ),
        ),
        SizedBox(width: 6.w),
        Image.asset(AppAssets.softRight, height: 40.h, fit: BoxFit.contain),
      ],
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
          Text(
            '7-DAY HEALTHY MEAL PLAN',
            style: TextStyle(
              color: const Color(0xFF00714D),
              fontSize: 11.sp,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
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
          const Divider(height: 1, thickness: 0.8, color: Color(0xFFE5E7EB)),
        );
      }
      rows.add(Expanded(child: _featureRow(i)));
    }
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3333D2AB),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                  color: const Color(0xFF6B7280),
                  fontSize: 10.sp,
                  fontFamily: 'Inter',
                  height: 1.25,
                ),
              ),
            ],
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: sel ? _green : const Color(0xFFD7EFE8),
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
                    color: sel ? _green : Colors.white,
                    border: sel
                        ? null
                        : Border.all(
                            color: const Color(0xFFB4E4D7),
                            width: 1.4,
                          ),
                  ),
                  child: sel
                      ? Icon(Icons.check, size: 12.sp, color: Colors.white)
                      : null,
                ),
                if (best)
                  Container(
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
                        Text(
                          'BEST VALUE',
                          style: TextStyle(
                            fontSize: 7.5.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              title,
              style: TextStyle(
                color: const Color(0xFF374151),
                fontSize: 13.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              price,
              style: TextStyle(
                color: const Color(0xFF09B389),
                fontSize: 24.sp,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              period,
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
        color: const Color(0xFF6B7280),
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
