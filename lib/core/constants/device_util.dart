import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';

class DeviceUtils {
  static bool isIPad = false;

  static Future<void> init() async {
    try {
      if (Platform.isIOS) {
        final iosInfo = await DeviceInfoPlugin().iosInfo;
        isIPad = iosInfo.model.toLowerCase().contains('ipad');
      }
    } catch (e) {
      isIPad = false;
    }
  }

  static bool isTablet([BuildContext? context]) {
    if (context != null) {
      return MediaQuery.of(context).size.shortestSide >= 600 || isIPad;
    }
    return isIPad;
  }
}
