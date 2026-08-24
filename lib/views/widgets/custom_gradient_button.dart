import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class CustomGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final double? height;
  final double? width;
  final Gradient? gradient;
  final Color? solidColor;
  final bool isOutlined;
  final Color? outlineColor;
  final TextStyle? textStyle;
  final BorderRadius? borderRadius;

  const CustomGradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.height,
    this.width,
    this.gradient,
    this.solidColor,
    this.isOutlined = false,
    this.outlineColor,
    this.textStyle,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? 54.h;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(28.r);

    if (isOutlined) {
      return Container(
        height: effectiveHeight,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: effectiveBorderRadius,
          border: Border.all(
            color: outlineColor ?? AppColors.primaryTeal,
            width: 1.5.w,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: effectiveBorderRadius,
            onTap: onPressed,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leadingIcon != null) ...[
                    leadingIcon!,
                    SizedBox(width: 8.w),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      overflow: TextOverflow.ellipsis,
                      style: textStyle ??
                          AppTypography.buttonText.copyWith(
                            color: outlineColor ?? AppColors.primaryTeal,
                          ),
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    SizedBox(width: 8.w),
                    trailingIcon!,
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: effectiveHeight,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        gradient: solidColor == null ? (gradient ?? AppColors.buttonGradient) : null,
        color: solidColor,
        borderRadius: effectiveBorderRadius,
        boxShadow: solidColor == null ? AppColors.buttonShadow : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: effectiveBorderRadius,
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leadingIcon != null) ...[
                  leadingIcon!,
                  SizedBox(width: 8.w),
                ],
                Flexible(
                  child: Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle ?? AppTypography.buttonText,
                  ),
                ),
                if (trailingIcon != null) ...[
                  SizedBox(width: 8.w),
                  trailingIcon!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
