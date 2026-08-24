import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../controllers/app_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_profile_model.dart';

class UnitsDialog extends StatefulWidget {
  const UnitsDialog({super.key});

  @override
  State<UnitsDialog> createState() => _UnitsDialogState();
}

class _UnitsDialogState extends State<UnitsDialog> {
  final AppController _controller = Get.find<AppController>();
  late UnitSystem _selected;

  @override
  void initState() {
    super.initState();
    _selected = _controller.unitSystem.value;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Units',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 14.h),

            // Metric
            GestureDetector(
              onTap: () => setState(() => _selected = UnitSystem.metric),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                color: Colors.transparent,
                child: Row(
                  children: [
                    Icon(
                      _selected == UnitSystem.metric
                          ? CupertinoIcons.checkmark_alt_circle_fill
                          : CupertinoIcons.circle,
                      size: 18.sp,
                      color: _selected == UnitSystem.metric
                          ? const Color(0xFF2FD1A6)
                          : const Color(0xFFCBD5E1),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Metric (kg, cm)',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Imperial
            GestureDetector(
              onTap: () => setState(() => _selected = UnitSystem.imperial),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                color: Colors.transparent,
                child: Row(
                  children: [
                    Icon(
                      _selected == UnitSystem.imperial
                          ? CupertinoIcons.checkmark_alt_circle_fill
                          : CupertinoIcons.circle,
                      size: 18.sp,
                      color: _selected == UnitSystem.imperial
                          ? const Color(0xFF2FD1A6)
                          : const Color(0xFFCBD5E1),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Imperial (lb, ft/in)',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // Cancel / Save Action Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () {
                    _controller.setUnitSystem(_selected);
                    Get.back();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1DB59B),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
