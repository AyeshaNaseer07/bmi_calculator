import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/routes/app_routes.dart';
import '../../data/services/subscription_service.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_gradient_button.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final AppController _appController = Get.find<AppController>();
  SubscriptionPlan _selectedPlan = SubscriptionPlan.yearly;
  bool _isLoading = false;

  void _onClose() {
    _appController.completeOnboarding();
    Get.offAllNamed(AppRoutes.home);
  }

  void _onSubscribe() async {
    setState(() => _isLoading = true);
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Close Button
                Row(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        onTap: _onClose,
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: const BoxDecoration(
                            color: Color(0xFFC7EFE4),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.xmark,
                            size: 16.sp,
                            color: Colors.black,
                            weight: 5.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 74.w),
                    Image.asset(AppAssets.crown, width: 130.w, height: 108.w),
                  ],
                ),
                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppAssets.wreathRight,
                      width: 32.w,
                      height: 52.h,
                    ),
                    SizedBox(width: 8.w),
                    RichText(
                      text: TextSpan(
                        style: AppTypography.headlineLarge.copyWith(
                          fontSize: 24.sp,
                        ),
                        children: const [
                          TextSpan(text: 'Unlock '),
                          TextSpan(
                            text: 'Premium',
                            style: TextStyle(color: AppColors.primaryTealLight),
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      AppAssets.wreathLeft,
                      width: 32.w,
                      height: 52.h,
                    ),
                    SizedBox(width: 8.w),
                  ],
                ),
                Text(
                  'Unlock advanced health tools and enjoy\na smarter wellness experience.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textBody,
                    fontSize: 12.sp,
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
                        title: 'Export PDF Reports',
                      ),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      _buildFeatureRow(
                        iconPath: AppAssets.preIcon6,
                        fallbackIcon: Icons.block,
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
                                      _selectedPlan == SubscriptionPlan.monthly
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
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '\$4.99',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryTealLight,
                                ),
                              ),
                              Text(
                                'month',
                                style: AppTypography.bodySmall.copyWith(
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // OR Divider
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF64748B),
                          ),
                        ),
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
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    '\$29.99',
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryTealLight,
                                    ),
                                  ),
                                  Text(
                                    'Year',
                                    style: AppTypography.bodySmall.copyWith(
                                      fontSize: 11.sp,
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
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFB800),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 10.sp,
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'BEST VALUE',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 8.sp,
                                      fontWeight: FontWeight.w900,
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

                // Start Free Trial Button
                CustomGradientButton(
                  text: _isLoading ? 'Processing...' : 'Start Free Trial',
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
                SizedBox(height: 10.h),

                Text(
                  '7 Days Free • Cancel Anytime',
                  style: AppTypography.bodySmall.copyWith(fontSize: 12.sp),
                ),
                SizedBox(height: 16.h),

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
          Container(
            width: 32.w,
            height: 32.w,
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: const Color(0xFFEDFAF5),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Image.asset(
              iconPath,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) =>
                  Icon(fallbackIcon, size: 18.sp, color: AppColors.primaryTeal),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          Icon(
            CupertinoIcons.checkmark_alt_circle,
            color: const Color(0xFF2FD1A6),
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
