import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const double kPhoneDesignWidth = 375;

bool isTablet(BuildContext context) =>
    MediaQuery.sizeOf(context).shortestSide >= 600;

EdgeInsets phoneWidthDialogInset(BuildContext context, double inset) {
  final double screenWidth = MediaQuery.sizeOf(context).width;
  final double dialogWidth = kPhoneDesignWidth.w - 2 * inset;
  return EdgeInsets.symmetric(
    horizontal: math.max(inset, (screenWidth - dialogWidth) / 2),
  );
}

/// Screen height the layouts are designed around (iPhone X / 12 mini class).
const double kReferencePhoneHeight = 812;

/// iPhone SE class phones (and phones in landscape): short enough that a
/// screen designed for [kReferencePhoneHeight] gets squeezed or clipped.
bool isShortPhone(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  return size.shortestSide < 600 && size.height < 700;
}

/// Keeps [child]'s layout exactly as is on normal phones and tablets. On
/// short phones the child is laid out with the height it would have on a
/// [kReferencePhoneHeight] phone (so `Expanded`, `Spacer` and `FittedBox`
/// inside it keep working) and the whole thing scrolls.
class ScrollOnShortPhones extends StatelessWidget {
  final Widget child;

  const ScrollOnShortPhones({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!isShortPhone(context)) return child;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedHeight) return child;
        final extra = kReferencePhoneHeight - MediaQuery.sizeOf(context).height;
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: SizedBox(height: constraints.maxHeight + extra, child: child),
        );
      },
    );
  }
}
