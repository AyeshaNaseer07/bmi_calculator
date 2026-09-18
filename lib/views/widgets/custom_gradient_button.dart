import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_assets.dart';
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
  final String? backgroundImage;
  final List<BoxShadow>? boxShadow;

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
    this.backgroundImage,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? 54.h;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12.r);
    final isEnabled = onPressed != null;

    const disabledBgColor = Color(0xFFE2E8F0);
    const disabledTextColor = Color(0xFF94A3B8);

    final effectiveTextStyle = (textStyle ?? AppTypography.buttonText).copyWith(
      color: isEnabled
          ? (textStyle?.color ??
              (isOutlined
                  ? (outlineColor ?? const Color(0xFF2EC4B6))
                  : Colors.white))
          : disabledTextColor,
    );

    Widget buttonContent;

    if (isOutlined) {
      buttonContent = AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: effectiveHeight,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: effectiveBorderRadius,
          border: Border.all(
            color: isEnabled
                ? (outlineColor ?? AppColors.primaryTeal)
                : const Color(0xFFCBD5E1),
            width: 1.5.w,
          ),
          boxShadow: isEnabled ? boxShadow : null,
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
                    IconTheme(
                      data: IconThemeData(
                        color: isEnabled ? null : disabledTextColor,
                      ),
                      child: leadingIcon!,
                    ),
                    SizedBox(width: 8.w),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      overflow: TextOverflow.ellipsis,
                      style: effectiveTextStyle,
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    SizedBox(width: 8.w),
                    IconTheme(
                      data: IconThemeData(
                        color: isEnabled ? null : disabledTextColor,
                      ),
                      child: trailingIcon!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      buttonContent = AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: effectiveHeight,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: isEnabled ? solidColor : disabledBgColor,
          borderRadius: effectiveBorderRadius,
          image: isEnabled && solidColor == null
              ? DecorationImage(
                  image: AssetImage(backgroundImage ?? AppAssets.btnRectangle),
                  fit: BoxFit.fill,
                )
              : null,
          boxShadow: isEnabled ? boxShadow : null,
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
                    IconTheme(
                      data: IconThemeData(
                        color: isEnabled ? null : disabledTextColor,
                      ),
                      child: leadingIcon!,
                    ),
                    SizedBox(width: 8.w),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      overflow: TextOverflow.ellipsis,
                      style: effectiveTextStyle,
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    SizedBox(width: 8.w),
                    IconTheme(
                      data: IconThemeData(
                        color: isEnabled ? null : disabledTextColor,
                      ),
                      child: trailingIcon!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    return buttonContent;
  }
}
