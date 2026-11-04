import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_palette.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/responsive.dart';

/// The same left-to-right teal-to-blue fill as [AppAssets.btnRectangle].
const LinearGradient _kBtnRectangleGradient = LinearGradient(
  colors: [Color(0xFF33D3AB), Color(0xFF128ADB)],
);

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
  final bool alignLeadingToStart;
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
    this.alignLeadingToStart = false,
    this.contentPadding,
  });

  Widget _buildButtonChild({required TextStyle effectiveTextStyle}) {
    final shouldAlignEnds =
        (alignTrailingToEnd && trailingIcon != null) ||
        (alignLeadingToStart && leadingIcon != null);

    final effectivePadding =
        contentPadding ??
        EdgeInsets.symmetric(horizontal: shouldAlignEnds ? 20.w : 16.w);

    if (shouldAlignEnds) {
      return Padding(
        padding: effectivePadding,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 36.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (leadingIcon != null) ...[
                      leadingIcon!,
                      SizedBox(width: 8.w),
                    ],
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          softWrap: false,
                          style: effectiveTextStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (trailingIcon != null)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: trailingIcon!,
              ),
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
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                maxLines: 1,
                softWrap: false,
                style: effectiveTextStyle,
              ),
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
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(effectiveHeight / 2);
    final isEnabled = onPressed != null;

    Widget buttonContent;

    if (isOutlined) {
      buttonContent = Container(
        height: effectiveHeight,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: AppPalette.surface,
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
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      );
    } else {
      final image = backgroundImage ?? AppAssets.btnRectangle;
      final useImageGradient =
          solidColor == null &&
          gradient == null &&
          image == AppAssets.btnRectangle &&
          isTablet(context);
      final effectiveGradient = useImageGradient
          ? _kBtnRectangleGradient
          : gradient;
      buttonContent = Container(
        height: effectiveHeight,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: solidColor,
          gradient: effectiveGradient,
          borderRadius: effectiveBorderRadius,
          image: (solidColor == null && effectiveGradient == null)
              ? DecorationImage(image: AssetImage(image), fit: BoxFit.fill)
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

    return IgnorePointer(
      ignoring: !isEnabled,
      child: AnimatedOpacity(
        opacity: isEnabled ? 1.0 : 0.40,
        duration: const Duration(milliseconds: 200),
        child: buttonContent,
      ),
    );
  }
}
