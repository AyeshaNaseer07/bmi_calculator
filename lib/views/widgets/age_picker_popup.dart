import 'package:bmi_calculator/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AgePickerPopup extends StatelessWidget {
  final int currentAge;
  final ValueChanged<int> onAgeChanged;
  final VoidCallback onClose;

  const AgePickerPopup({
    super.key,
    required this.currentAge,
    required this.onAgeChanged,
    required this.onClose,
  });

  static const _green = Color(0xFF09B389);

  Widget _arrow(String asset, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.35,
        child: Container(
          width: 26.w,
          height: 26.w,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFF1F5F9),
            shape: BoxShape.circle,
          ),
          child: Image.asset(asset, width: 12.w, height: 12.w),
        ),
      ),
    );
  }

  Widget _sideAge(String text) => SizedBox(
    width: 24.w,
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: const Color(0xFFC4CAD3),
        fontSize: 14,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 165.w,
      padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFD8F3EC), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3333D2AB),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Your Age',
            style: TextStyle(
              color: const Color(0xFF111827),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Your age helps calculate your BMI accurately.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF6B7280),
              fontSize: 10,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _arrow(
                AppAssets.ageBack,
                currentAge > 1,
                () => onAgeChanged(currentAge - 1),
              ),
              _sideAge(currentAge > 1 ? '${currentAge - 1}' : ''),
              // Selected age
              Container(
                constraints: BoxConstraints(minWidth: 40.w),
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9FBF3),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '$currentAge',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _green,
                    fontSize: 22,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _sideAge(currentAge < 120 ? '${currentAge + 1}' : ''),
              _arrow(
                AppAssets.ageForward,
                currentAge < 120,
                () => onAgeChanged(currentAge + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
