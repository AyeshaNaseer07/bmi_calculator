import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Phone design width the layouts are drawn against (see `main.dart`).
const double kPhoneDesignWidth = 375;

bool isTablet(BuildContext context) =>
    MediaQuery.sizeOf(context).shortestSide >= 600;

/// Horizontal dialog inset that keeps a full-width dialog at its phone design
/// width on tablets. [inset] is the phone inset, already scaled (e.g. `30.w`);
/// on phones it is returned unchanged.
EdgeInsets phoneWidthDialogInset(BuildContext context, double inset) {
  final double screenWidth = MediaQuery.sizeOf(context).width;
  final double dialogWidth = kPhoneDesignWidth.w - 2 * inset;
  return EdgeInsets.symmetric(
    horizontal: math.max(inset, (screenWidth - dialogWidth) / 2),
  );
}
