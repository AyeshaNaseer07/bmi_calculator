import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/localization_service.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_gradient_button.dart';

class LanguagesScreen extends StatefulWidget {
  const LanguagesScreen({super.key});

  @override
  State<LanguagesScreen> createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  final AppController _appController = Get.find<AppController>();
  late String _selectedCode;

  @override
  void initState() {
    super.initState();
    _selectedCode = _appController.selectedLanguage.value;
  }

  void _onSave() {
    _appController.changeLanguage(_selectedCode);
    Get.back();
    Get.snackbar(
      'Language Saved',
      'App language has been updated.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryTeal,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(title: 'Languages'),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 8.h,
                  ),
                  itemCount: LocalizationService.supportedLanguages.length,
                  itemBuilder: (context, index) {
                    final lang = LocalizationService.supportedLanguages[index];
                    final isSelected = _selectedCode == lang.code;

                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCode = lang.code),
                        child: Container(
                          height: 54.h,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF2FD1A6)
                                  : const Color(0xFFE2E8F0),
                              width: isSelected ? 1.5.w : 1.0.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? AppColors.primaryTeal.withValues(
                                        alpha: 0.06,
                                      )
                                    : Colors.black.withValues(alpha: 0.02),
                                blurRadius: 6.r,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Text(
                                lang.flag,
                                style: TextStyle(fontSize: 20.sp),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lang.englishName,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    Text(
                                      lang.nativeName,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: AppColors.textLight,
                                      ),
                                    ),
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
                  },
                ),
              ),

              // Bottom Save Language Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                child: CustomGradientButton(
                  text: 'Save Language',
                  leadingIcon: Icon(
                    CupertinoIcons.globe,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                  solidColor: const Color(0xFF2FD1A6),
                  onPressed: _onSave,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
