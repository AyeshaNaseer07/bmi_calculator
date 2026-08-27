import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final List<BoxShadow>? shadows;
  final bool showBorder;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.shadows,
    this.showBorder = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius != null ? borderRadius!.r : 18.r;

    final defaultShadows = [
      BoxShadow(
        color: Color(0x4C33D2AB),
        blurRadius: 4.70,
        offset: Offset(0, 2),
        spreadRadius: 0,
      ),
    ];

    final cardContent = Container(
      width: width,
      height: height,
      margin: margin,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        border: showBorder
            ? Border.all(color: borderColor ?? Colors.transparent, width: 1.2.w)
            : null,
        boxShadow: shadows ?? defaultShadows,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: cardContent);
    }

    return cardContent;
  }
}
