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
import '../widgets/custom_card.dart';

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

  @override
  void initState() {
    super.initState();
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
    _appController.completeOnboarding();
    Get.offAllNamed(AppRoutes.home);
  }

  void _onSubscribe() async {
    setState(() => _isLoading = true);
    // Purchases using the remote product ID configured for the selected plan
    final selectedProductId = _appController.remoteConfigService.getProductId(
      _selectedPlan,
    );
    debugPrint('Subscribing with remote product ID: $selectedProductId');

    await _appController.upgradeToPremium(_selectedPlan);
    _appController.completeOnboarding();
    setState(() => _isLoading = false);
    Get.offAllNamed(AppRoutes.home);
  }

  void _onRestore() async {
    setState(() => _isLoading = true);
    await _appController.subscriptionService.restorePurchases();
    setState(() => _isLoading = false);
    Get.snackbar('Restore', 'Purchase restored successfully (demo).');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FCF9),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AppAssets.premiumBg, fit: BoxFit.cover),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Centered Crown
                  Image.asset(AppAssets.crown, width: 100.w, height: 100.w),
                  // Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppAssets.wreathRight,
                        width: 32.w,
                        height: 52.h,
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Unlock ',
                              style: TextStyle(
                                color: const Color(0xFF111827),
                                fontSize: 32,
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(
                              text: 'Premium',
                              style: TextStyle(
                                color: const Color(0xFF0AA37D),
                                fontSize: 32,
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Image.asset(
                        AppAssets.wreathLeft,
                        width: 32.w,
                        height: 52.h,
                      ),
                    ],
                  ),
                  Text(
                    'Unlock advanced health tools and enjoy \na smarter wellness experience.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF4B5563),
                      fontSize: 12.5,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Feature List Card
                  CustomCard(
                    borderRadius: 18.r,
                    padding: EdgeInsets.symmetric(
                      vertical: 8.h,
                      horizontal: 16.w,
                    ),
                    child: Column(
                      children: [
                        _buildFeatureRow(
                          iconPath: AppAssets.preIcon1,
                          fallbackIcon: Icons.history,
                          title: 'Unlimited BMI History',
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        _buildFeatureRow(
                          iconPath: AppAssets.preIcon2,
                          fallbackIcon: Icons.bar_chart,
                          title: 'Advanced Health Reports',
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        _buildFeatureRow(
                          iconPath: AppAssets.preIcon3,
                          fallbackIcon: Icons.show_chart,
                          title: 'Weight Progress Analytics',
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        _buildFeatureRow(
                          iconPath: AppAssets.preIcon4,
                          fallbackIcon: Icons.favorite_border,
                          title: 'Personalized Health Insights',
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        _buildFeatureRow(
                          iconPath: AppAssets.preIcon5,
                          fallbackIcon: Icons.picture_as_pdf_outlined,
                          title: 'Ad-Free Experience',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Plan Selection (Monthly vs Yearly) with Remote IDs & Pricing
                  Row(
                    children: [
                      // Monthly Plan
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(
                            () => _selectedPlan = SubscriptionPlan.monthly,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: _selectedPlan == SubscriptionPlan.monthly
                                    ? AppColors.primaryTeal
                                    : const Color(0xFFE2E8F0),
                                width: _selectedPlan == SubscriptionPlan.monthly
                                    ? 1.5.w
                                    : 1.0.w,
                              ),
                              boxShadow: AppColors.cardShadow,
                            ),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    width: 18.w,
                                    height: 18.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            _selectedPlan ==
                                                SubscriptionPlan.monthly
                                            ? AppColors.primaryTeal
                                            : const Color(0xFFCBD5E1),
                                        width: 1.5.w,
                                      ),
                                      color:
                                          _selectedPlan ==
                                              SubscriptionPlan.monthly
                                          ? AppColors.primaryTeal
                                          : Colors.white,
                                    ),
                                    child:
                                        _selectedPlan ==
                                            SubscriptionPlan.monthly
                                        ? Icon(
                                            Icons.check,
                                            size: 12.sp,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  'Monthly Plan',
                                  style: TextStyle(
                                    color: const Color(0xFF4B5563),
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Obx(
                                  () => Text(
                                    _appController
                                        .remoteConfigService
                                        .monthlyPrice,
                                    style: TextStyle(
                                      color: const Color(0xFF33D2AB),
                                      fontSize: 22,
                                      fontFamily: 'Outfit',
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                Text(
                                  'month',
                                  style: TextStyle(
                                    color: const Color(0xFF9CA3AF),
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // OR Divider
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 8.h,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(AppAssets.preOr, width: 32, height: 32),
                            Text(
                              'OR',
                              style: TextStyle(
                                color: const Color(0xFF4B5563),
                                fontSize: 10,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Yearly Plan (Best Value)
                      Expanded(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            GestureDetector(
                              onTap: () => setState(
                                () => _selectedPlan = SubscriptionPlan.yearly,
                              ),
                              child: Container(
                                padding: EdgeInsets.all(14.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                    color:
                                        _selectedPlan == SubscriptionPlan.yearly
                                        ? AppColors.primaryTeal
                                        : const Color(0xFFE2E8F0),
                                    width:
                                        _selectedPlan == SubscriptionPlan.yearly
                                        ? 1.5.w
                                        : 1.0.w,
                                  ),
                                  boxShadow: AppColors.cardShadow,
                                ),
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Container(
                                        width: 18.w,
                                        height: 18.w,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color:
                                                _selectedPlan ==
                                                    SubscriptionPlan.yearly
                                                ? AppColors.primaryTeal
                                                : const Color(0xFFCBD5E1),
                                            width: 1.5.w,
                                          ),
                                          color:
                                              _selectedPlan ==
                                                  SubscriptionPlan.yearly
                                              ? AppColors.primaryTeal
                                              : Colors.white,
                                        ),
                                        child:
                                            _selectedPlan ==
                                                SubscriptionPlan.yearly
                                            ? Icon(
                                                Icons.check,
                                                size: 12.sp,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Text(
                                      'Yearly Plan',
                                      style: TextStyle(
                                        color: const Color(0xFF4B5563),
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Obx(
                                      () => Text(
                                        _appController
                                            .remoteConfigService
                                            .yearlyPrice,
                                        style: TextStyle(
                                          color: const Color(0xFF33D2AB),
                                          fontSize: 22,
                                          fontFamily: 'Outfit',
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Year',
                                      style: TextStyle(
                                        color: const Color(0xFF9CA3AF),
                                        fontSize: 12,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Best Value Badge
                            Positioned(
                              top: -10.h,
                              right: -4.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFB800),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      AppAssets.bestValueCrown,
                                      height: 10.h,
                                      width: 10.w,
                                    ),
                                    SizedBox(width: 3.w),
                                    Text(
                                      'BEST VALUE',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 8,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Dynamic Remote Button Text & CTA with eye-catching animations
                  Obx(
                    () => AnimatedCtaButton(
                      text: _isLoading
                          ? 'Processing...'
                          : _appController.remoteConfigService.buttonText,
                      backgroundImage: AppAssets.btnRectangle,
                      isLoading: _isLoading,
                      leadingIcon: Icon(
                        Icons.diamond_outlined,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                      trailingIcon: Icon(
                        CupertinoIcons.arrow_right,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                      onPressed: _isLoading ? null : _onSubscribe,
                    ),
                  ),
                  SizedBox(height: 10.h),

                  Obx(
                    () => Text(
                      _appController.remoteConfigService.trialSubtitle,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),

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
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),

          // Top-Left Close Cross Button overlaid on Stack
          Positioned(
            top: 12.h,
            left: 20.w,
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
                      padding: EdgeInsets.all(8.w),
                      decoration: const BoxDecoration(
                        color: Color(0xFFC7EFE4),
                        shape: BoxShape.circle,
                      ),
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
        ],
      ),
    );
  }

  Widget _buildFeatureRow({
    required String iconPath,
    required IconData fallbackIcon,
    required String title,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Image.asset(iconPath, fit: BoxFit.contain, height: 32.h, width: 32.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: const Color(0xFF111827),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Image.asset(AppAssets.preDown, height: 18.h, width: 18.w),
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
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFooterDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Text(
        '|',
        style: TextStyle(fontSize: 11.sp, color: const Color(0xFFCBD5E1)),
      ),
    );
  }
}
