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

const double kReferencePhoneHeight = 812;

bool isShortPhone(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  return size.shortestSide < 600 && size.height < 700;
}

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
