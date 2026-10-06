import 'dart:async';

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

  static const Color _green = Color(0xFF0AA37D);

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
        if (mounted) setState(() => _showCloseButton = true);
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
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final selectedProductId = _appController.remoteConfigService.getProductId(
      _selectedPlan,
    );
    debugPrint('Subscribing with remote product ID: $selectedProductId');

    bool success = false;
    try {
      success = await _appController.upgradeToPremium(_selectedPlan);
      _appController.completeOnboarding();
    } catch (e) {
      debugPrint('Subscription error: $e');
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      await _showCongratsDialog();
    }
    if (!mounted) return;
    Get.offAllNamed(AppRoutes.home);
  }

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
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await _appController.subscriptionService.restorePurchases();
    } catch (e) {
      debugPrint('Restore error: $e');
    }
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
                          AppAssets.crown,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),

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
                        horizontal: 12.w,
                        vertical: 6.h,
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
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.workspace_premium_rounded,
                            size: 16.sp,
                            color: const Color(0xFF00714D),
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            'PREMIUM HEALTH PASS',
                            style: TextStyle(
                              color: const Color(0xFF00714D),
                              fontSize: 12.sp,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w700,
                              height: 1.27,
                              letterSpacing: 0.55,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18.h),

                    // Feature List Card: takes whatever space is left,
                    // rows share it equally so nothing overflows.
                    Expanded(
                      flex: 8,
                      child: Container(
                        width: double.infinity,
                        constraints: BoxConstraints(minHeight: 150.h),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x3F33D2AB),
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
                                title: 'Unlimited BMI History',
                              ),
                              _buildFeatureDivider(),
                              _buildFeatureRow(
                                imagePath: AppAssets.preIcon2,
                                title: 'Personalized Meal Plan',
                              ),
                              _buildFeatureDivider(),
                              _buildFeatureRow(
                                imagePath: AppAssets.preIcon3,
                                title: 'Weight Progress Analytics',
                              ),
                              _buildFeatureDivider(),
                              _buildFeatureRow(
                                imagePath: AppAssets.preIcon4,
                                title: 'Your Healthy Weight Plan',
                              ),
                              _buildFeatureDivider(),
                              _buildFeatureRow(
                                imagePath: AppAssets.preIcon5,
                                title: 'Ad-Free Experience',
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
                            title: 'Monthly Plan',
                            price: '\$4.99',
                            period: 'month',
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
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFB4E4D7),
                                width: 1.2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x1A33D2AB),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: _green,
                                  fontSize: 9.sp,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: _buildPlanCard(
                            plan: SubscriptionPlan.yearly,
                            title: 'Yearly Plan',
                            price: '\$29.99',
                            period: 'year',
                            showBestValue: true,
                            shadowColor: const Color(0x2433D2AB),
                            shadowBlur: 12,
                            shadowOffset: const Offset(0, 3),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 28.h),

                    // CTA Button (no Obx: nothing observable is read here,
                    // which would throw a GetX "improper use" error)
                    AnimatedCtaButton(
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

                    Container(
                      width: 48.w,
                      height: 2.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // Footer links
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildFooterLink('Privacy Policy', () {}),
                          _buildFooterDivider(),
                          _buildFooterLink('Restore Purchase', _onRestore),
                          _buildFooterDivider(),
                          _buildFooterLink('Terms of Use', () {}),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),

            // Close button
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
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: selected ? _green : const Color(0xFFE2F4EE),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: const Color(0xFF4B5563),
                        fontSize: 14.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      price,
                      style: TextStyle(
                        color: const Color(0xFF09B389),
                        fontSize: 22.sp,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      period,
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
        decoration: const BoxDecoration(shape: BoxShape.circle, color: _green),
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

  /// Each row is Expanded, so the 5 rows split the card height equally
  /// and can never overflow vertically.
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
                  color: const Color(0xFF111827),
                  fontSize: 14.sp,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
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
