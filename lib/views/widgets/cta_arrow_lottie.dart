import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../core/constants/app_assets.dart';
import '../../core/utils/rtl.dart';

class CtaArrowLottie extends StatelessWidget {
  final double size;
  final Color color;

  const CtaArrowLottie({
    super.key,
    required this.size,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return MirrorOnRtl(
      child: Lottie.asset(
        AppAssets.forwardArrowLottie,
        width: size,
        height: size,
        fit: BoxFit.contain,
        animate: !MediaQuery.disableAnimationsOf(context),
        delegates: LottieDelegates(
          values: [
            ValueDelegate.color(const ['**'], value: color),
          ],
        ),
        errorBuilder: (_, _, _) =>
            Icon(Icons.arrow_forward_rounded, color: color, size: size * 0.8),
      ),
    );
  }
}
