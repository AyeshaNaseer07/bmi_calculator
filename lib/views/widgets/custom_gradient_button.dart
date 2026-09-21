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
  final bool alignTrailingToEnd;
  final EdgeInsetsGeometry? contentPadding;

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
    this.alignTrailingToEnd = true,
    this.contentPadding,
  });

  Widget _buildButtonChild({required TextStyle effectiveTextStyle}) {
    final effectivePadding =
        contentPadding ??
        EdgeInsets.symmetric(
          horizontal:
              (alignTrailingToEnd &&
                  (leadingIcon != null || trailingIcon != null))
              ? 20.w
              : 16.w,
        );

    if (alignTrailingToEnd && (leadingIcon != null || trailingIcon != null)) {
      return Padding(
        padding: effectivePadding,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (leadingIcon != null)
              Align(alignment: Alignment.centerLeft, child: leadingIcon!),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 36.w),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: effectiveTextStyle,
                ),
              ),
            ),
            if (trailingIcon != null)
              Align(alignment: Alignment.centerRight, child: trailingIcon!),
          ],
        ),
      );
    }

    return Padding(
      padding: effectivePadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leadingIcon != null) ...[leadingIcon!, SizedBox(width: 8.w)],
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: effectiveTextStyle,
            ),
          ),
          if (trailingIcon != null) ...[SizedBox(width: 8.w), trailingIcon!],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? 54.h;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12.r);
    final isEnabled = onPressed != null;

    Widget buttonContent;

    if (isOutlined) {
      buttonContent = Container(
        height: effectiveHeight,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: effectiveBorderRadius,
          border: Border.all(
            color: outlineColor ?? AppColors.primaryTeal,
            width: 1.5.w,
          ),
          boxShadow: isEnabled ? boxShadow : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: effectiveBorderRadius,
            onTap: onPressed,
            child: _buildButtonChild(
              effectiveTextStyle:
                  textStyle ??
                  AppTypography.buttonText.copyWith(
                    color: outlineColor ?? const Color(0xFF2EC4B6),
                  ),
            ),
          ),
        ),
      );
    } else {
      buttonContent = Container(
        height: effectiveHeight,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: solidColor,
          gradient: gradient,
          borderRadius: effectiveBorderRadius,
          image: (solidColor == null && gradient == null)
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
            child: _buildButtonChild(
              effectiveTextStyle: textStyle ?? AppTypography.buttonText,
            ),
          ),
        ),
      );
    }

    return AnimatedOpacity(
      opacity: isEnabled ? 1.0 : 0.45,
      duration: const Duration(milliseconds: 200),
      child: buttonContent,
    );
  }
}
