import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/routes/app_routes.dart';
import '../widgets/native_ad_placeholder.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final AppController _appController = Get.find<AppController>();
  String _selectedLang = 'en';

  final List<(String code, String name, String flag)> _initialLanguages = const [
    ('en', 'English', '🇺🇸'),
    ('es', 'Español', '🇪🇸'),
    ('pt', 'Português', '🇵🇹'),
    ('fr', 'Français', '🇫🇷'),
    ('de', 'Deutsch', '🇩🇪'),
    ('it', 'Italiano', '🇮🇹'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedLang = _appController.selectedLanguage.value;
  }

  void _onDone() {
    _appController.changeLanguage(_selectedLang);
    _appController.completeOnboarding();
    Get.offAllNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FCF9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Title, Subtitle, and Done Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Languages',
                          style: AppTypography.headlineLarge.copyWith(fontSize: 24.sp),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Select your preferred language to continue.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textBody,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Done Button
                  GestureDetector(
                    onTap: _onDone,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB9F0E1),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: const Color(0xFF0F766E),
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Languages List
              ..._initialLanguages.map((lang) {
                final isSelected = _selectedLang == lang.$1;
                return Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedLang = lang.$1);
                    },
                    child: Container(
                      height: 52.h,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryTealLight
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.5.w : 1.0.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? AppColors.primaryTeal.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(lang.$3, style: TextStyle(fontSize: 22.sp)),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Text(
                              lang.$2,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          Container(
                            width: 22.w,
                            height: 22.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? const Color(0xFF2FD1A6)
                                  : const Color(0xFFE2E8F0),
                            ),
                            child: isSelected
                                ? Icon(
                                    CupertinoIcons.checkmark_alt,
                                    size: 14.sp,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              SizedBox(height: 16.h),

              // Native Ad Placeholder
              const NativeAdPlaceholder(),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
