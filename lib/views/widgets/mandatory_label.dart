import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class MandatoryLabel extends StatelessWidget {
  final String text;
  final String? unitText;
  final bool isMandatory;
  final TextStyle? style;
  final TextStyle? unitStyle;
  final TextStyle? asteriskStyle;
  final EdgeInsetsGeometry? padding;

  const MandatoryLabel({
    super.key,
    required this.text,
    this.unitText,
    this.isMandatory = true,
    this.style,
    this.unitStyle,
    this.asteriskStyle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle =
        style ??
        const TextStyle(
          color: Color(0xFF111827),
          fontSize: 13,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w900,
        );

    final effectiveUnitStyle =
        unitStyle ??
        effectiveStyle.copyWith(
          color: const Color(0xFF6B7280),
          fontWeight: FontWeight.w400,
        );

    final effectiveAsteriskStyle =
        asteriskStyle ??
        effectiveStyle.copyWith(
          color: AppColors.error,
          fontWeight: FontWeight.w700,
        );

    final content = Text.rich(
      TextSpan(
        text: text,
        style: effectiveStyle,
        children: [
          if (unitText != null && unitText!.isNotEmpty) ...[
            const TextSpan(text: ' '),
            TextSpan(text: unitText, style: effectiveUnitStyle),
          ],
          if (isMandatory) TextSpan(text: ' *', style: effectiveAsteriskStyle),
        ],
      ),
    );

    if (padding != null) {
      return Padding(padding: padding!, child: content);
    }
    return content;
  }
}
