import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../data/services/subscription_service.dart';
import '../widgets/animated_cta_button.dart';

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

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map && args['fromOnboarding'] == true) {
      _fromOnboarding = true;
    }
    _initCrossDelay();
  }

  void _initCrossDelay() {
    final delaySeconds = _appController.remoteConfigService.crossDelaySeconds;
    if (delaySeconds <= 0) {
      _showCloseButton = true;
    } else {
      _crossDelayTimer = Timer(Duration(seconds: delaySeconds), () {
        if (mounted) {
          setState(() => _showCloseButton = true);
        }
      });
    }
  }

  @override
  void dispose() {
    _crossDelayTimer?.cancel();
    super.dispose();
  }

  void _onClose() {
    if (_fromOnboarding) {
      _appController.completeOnboarding();
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.back();
    }
  }

  Future<void> _onSubscribe() async {
    setState(() => _isLoading = true);
    // Purchases using the remote product ID configured for the selected plan
    final selectedProductId = _appController.remoteConfigService.getProductId(
      _selectedPlan,
    );
    debugPrint('Subscribing with remote product ID: $selectedProductId');

    final success = await _appController.upgradeToPremium(_selectedPlan);
    _appController.completeOnboarding();
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      await _showCongratsDialog();
    }
    if (!mounted) return;
    Get.offAllNamed(AppRoutes.home);
  }

  /// Shown once, right after a successful purchase, before landing on Home.
  Future<void> _showCongratsDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Container(
          padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 24.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(AppAssets.crown, width: 72.w, height: 72.w),
              SizedBox(height: 16.h),
              Text(
                'Congratulations! 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "You're now a Premium member.\nEnjoy an ad-free experience and all\nadvanced features.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onRestore() async {
    setState(() => _isLoading = true);
    await _appController.subscriptionService.restorePurchases();
    if (!mounted) return;
    setState(() => _isLoading = false);
    Get.snackbar('Restore', 'Purchase restored successfully (demo).');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FCF9),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(AppAssets.premiumBg, fit: BoxFit.cover),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 4.h),
                    // Centered Crown
                    Image.asset(
                      AppAssets.crown,
                      width: 88.w,
                      height: 88.w,
                      fit: BoxFit.contain,
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
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Unlock ',
                                style: TextStyle(
                                  color: const Color(0xFF111827),
                                  fontSize: 32.sp,
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextSpan(
                                text: 'Premium',
                                style: TextStyle(
                                  color: const Color(0xFF0AA37D),
                                  fontSize: 32.sp,
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
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
                    SizedBox(height: 8.h),

                    // Premium Health Pass Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: ShapeDecoration(
                        color: const Color(0x666CF8BB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x0C000000),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.workspace_premium_rounded,
                            size: 15.sp,
                            color: const Color(0xFF068364),
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            'PREMIUM HEALTH PASS',
                            style: TextStyle(
                              color: const Color(0xFF068364),
                              fontSize: 10.5.sp,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // Feature List Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22.r),
                        border: Border.all(
                          color: const Color(0xFFE2F4EE),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF33D2AB)
                                .withValues(alpha: 0.16),
                            blurRadius: 18,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildFeatureRow(
                            icon: Icons.history_rounded,
                            title: 'Unlimited BMI History',
                          ),
                          _buildFeatureDivider(),
                          _buildFeatureRow(
                            icon: Icons.bar_chart_rounded,
                            title: 'Personalized Meal Plan',
                          ),
                          _buildFeatureDivider(),
                          _buildFeatureRow(
                            icon: Icons.trending_up_rounded,
                            title: 'Weight Progress Analytics',
                          ),
                          _buildFeatureDivider(),
                          _buildFeatureRow(
                            icon: Icons.monitor_heart_outlined,
                            title: 'Your Healthy Weight Plan',
                          ),
                          _buildFeatureDivider(),
                          _buildFeatureRow(
                            icon: Icons.browser_not_supported_outlined,
                            title: 'Ad-Free Experience',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Plan Selection (Monthly vs Yearly)
                    Row(
                      children: [
                        // Monthly Plan
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(
                              () => _selectedPlan = SubscriptionPlan.monthly,
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18.r),
                                border: Border.all(
                                  color:
                                      _selectedPlan == SubscriptionPlan.monthly
                                      ? const Color(0xFF0AA37D)
                                      : const Color(0xFFE2F4EE),
                                  width:
                                      _selectedPlan == SubscriptionPlan.monthly
                                      ? 1.5.w
                                      : 1.0.w,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF33D2AB)
                                        .withValues(alpha: 0.12),
                                    blurRadius: 12,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildPlanRadio(
                                    _selectedPlan == SubscriptionPlan.monthly,
                                  ),
                                  SizedBox(height: 6.h),
                                  Center(
                                    child: Column(
                                      children: [
                                        Text(
                                          'Monthly Plan',
                                          style: TextStyle(
                                            color: const Color(0xFF374151),
                                            fontSize: 13.5.sp,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          '\$4.99',
                                          style: TextStyle(
                                            color: const Color(0xFF0AA37D),
                                            fontSize: 24.sp,
                                            fontFamily: 'Outfit',
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Text(
                                          'month',
                                          style: TextStyle(
                                            color: const Color(0xFF9CA3AF),
                                            fontSize: 12.sp,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // OR Badge
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Container(
                            width: 28.w,
                            height: 28.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFB4E4D7),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF33D2AB)
                                      .withValues(alpha: 0.10),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: const Color(0xFF0AA37D),
                                  fontSize: 9.sp,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Yearly Plan (Best Value)
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(
                              () => _selectedPlan = SubscriptionPlan.yearly,
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18.r),
                                border: Border.all(
                                  color:
                                      _selectedPlan == SubscriptionPlan.yearly
                                      ? const Color(0xFF0AA37D)
                                      : const Color(0xFFE2F4EE),
                                  width:
                                      _selectedPlan == SubscriptionPlan.yearly
                                      ? 1.5.w
                                      : 1.0.w,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF33D2AB)
                                        .withValues(alpha: 0.14),
                                    blurRadius: 12,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildPlanRadio(
                                        _selectedPlan ==
                                            SubscriptionPlan.yearly,
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6.w,
                                          vertical: 2.5.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFB800),
                                          borderRadius: BorderRadius.circular(
                                            6.r,
                                          ),
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
                                            Text(
                                              'BEST VALUE',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 7.5.sp,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6.h),
                                  Center(
                                    child: Column(
                                      children: [
                                        Text(
                                          'Yearly Plan',
                                          style: TextStyle(
                                            color: const Color(0xFF374151),
                                            fontSize: 13.5.sp,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          '\$29.99',
                                          style: TextStyle(
                                            color: const Color(0xFF0AA37D),
                                            fontSize: 24.sp,
                                            fontFamily: 'Outfit',
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Text(
                                          'year',
                                          style: TextStyle(
                                            color: const Color(0xFF9CA3AF),
                                            fontSize: 12.sp,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),

                    // Dynamic CTA Button
                    Obx(
                      () => AnimatedCtaButton(
                        text: _isLoading
                            ? 'Processing...'
                            : _appController.remoteConfigService.buttonText,
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
                    SizedBox(height: 10.h),

                    Text(
                      '7 Days Free • Cancel Anytime',
                      style: TextStyle(
                        color: const Color(0xFF6B7280),
                        fontSize: 12.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 6.h),

                    // Small subtle dash divider
                    Container(
                      width: 48.w,
                      height: 2.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // Bottom Policy Links
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFooterLink('Privacy Policy', () {}),
                        _buildFooterDivider(),
                        _buildFooterLink('Restore Purchase', _onRestore),
                        _buildFooterDivider(),
                        _buildFooterLink('Terms of Use', () {}),
                      ],
                    ),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),

            // Top-Left Close Cross Button overlaid on Stack
            Positioned(
              top: 14.h,
              left: 18.w,
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
                        decoration: const BoxDecoration(
                          color: Color(0xFFBFEFDF),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            CupertinoIcons.xmark,
                            size: 18.sp,
                            color: const Color(0xFF0F5F55),
                            shadows: const [
                              Shadow(
                                color: Color(0xFF0F5F55),
                                blurRadius: 0,
                                offset: Offset(0.6, 0),
                              ),
                              Shadow(
                                color: Color(0xFF0F5F55),
                                blurRadius: 0,
                                offset: Offset(-0.6, 0),
                              ),
                            ],
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

  Widget _buildPlanRadio(bool isSelected) {
    if (isSelected) {
      return Container(
        width: 18.w,
        height: 18.w,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF0AA37D),
        ),
        child: Icon(Icons.check, size: 12.sp, color: Colors.white),
      );
    }
    return Container(
      width: 18.w,
      height: 18.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFB4E4D7), width: 1.5),
        color: Colors.white,
      ),
    );
  }

  Widget _buildFeatureDivider() {
    return const Divider(height: 1, thickness: 0.8, color: Color(0xFFF1F5F9));
  }

  Widget _buildFeatureRow({required IconData icon, required String title}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.5.h),
      child: Row(
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: const Color(0xFFD8F7EE),
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Center(
              child: Icon(icon, color: const Color(0xFF0AA37D), size: 20.sp),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: const Color(0xFF1E293B),
                fontSize: 14.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(
            CupertinoIcons.checkmark_circle,
            color: const Color(0xFF0AA37D),
            size: 20.sp,
          ),
        ],
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
          color: const Color(0xFF94A3B8),
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
