import 'package:bmi_calculator/core/constants/app_assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../data/services/localization_service.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final AppController _appController = Get.find<AppController>();
  String _selectedLang = 'en';

  @override
  void initState() {
    super.initState();
    _selectedLang = _appController.selectedLanguage.value;
  }

  void _onDone() {
    _appController.changeLanguage(_selectedLang);
    Get.offNamed(AppRoutes.onboarding);
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
                          'languages'.tr,
                          style: TextStyle(
                            color: const Color(0xFF111827),
                            fontSize: 20,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'select_lang_subtitle'.tr,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Done Button
                  GestureDetector(
                    onTap: _onDone,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(AppAssets.btnBg),
                        Text(
                          'done'.tr,
                          style: TextStyle(
                            color: const Color(0xFF0F766E),
                            fontWeight: FontWeight.w700,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Languages List
              ...LocalizationService.supportedLanguages.map((lang) {
                final isSelected = _selectedLang == lang.code;
                return Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedLang = lang.code);
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
                          Text(lang.flag, style: TextStyle(fontSize: 22.sp)),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  lang.nativeName,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                if (lang.nativeName != lang.englishName) ...[
                                  SizedBox(width: 6.w),
                                  Text(
                                    '(${lang.englishName})',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                ],
                              ],
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
              // const NativeAdPlaceholder(),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
