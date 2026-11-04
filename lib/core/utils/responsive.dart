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
