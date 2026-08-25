import 'package:bmi_calculator/core/constants/app_assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
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
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Title and Done Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'languages'.tr,
                          style: TextStyle(
                            color: const Color(0xFF111827),
                            fontSize: 26.sp,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'select_lang_subtitle'.tr,
                          style: TextStyle(
                            color: const Color(0xFF374151),
                            fontSize: 12.sp,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  // Done Button
                  GestureDetector(
                    onTap: _onDone,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(AppAssets.btnBg, width: 70.w, height: 75.h),
                        Text(
                          'done'.tr,
                          style: TextStyle(
                            color: const Color(0xFF0F766E),
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Languages List
              ...LocalizationService.supportedLanguages.map((lang) {
                final isSelected = _selectedLang == lang.code;
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedLang = lang.code);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 56.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? const Color.fromARGB(
                                  255,
                                  127,
                                  213,
                                  190,
                                ).withValues(alpha: 0.4)
                              : const Color(0xFFE5E7EB),
                          width: isSelected ? 2.w : 1.w,
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? const Color.fromARGB(
                                    255,
                                    175,
                                    226,
                                    212,
                                  ).withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Row(
                          children: [
                            // Flag
                            Text(lang.flag, style: TextStyle(fontSize: 28.sp)),
                            SizedBox(width: 12.w),
                            // Language Name
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang.nativeName,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF111827),
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  if (lang.nativeName != lang.englishName) ...[
                                    SizedBox(height: 2.h),
                                    Text(
                                      lang.englishName,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: const Color(0xFF9CA3AF),
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            SizedBox(width: 12.w),
                            // Checkmark Circle
                            Container(
                              width: 24.w,
                              height: 24.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? const Color(0xFF2FD1A6)
                                    : const Color(0xFFE5E7EB),
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
                  ),
                );
              }),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
