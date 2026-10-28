import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTypography {
  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 11.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textLight,
      );

  static TextStyle get buttonText => GoogleFonts.plusJakartaSans(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.2,
      );

  static TextStyle get valueLarge => GoogleFonts.plusJakartaSans(
        fontSize: 32.sp,
        fontWeight: FontWeight.w800,
        color: AppColors.primaryTeal,
        letterSpacing: -0.5,
      );
}
