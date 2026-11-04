import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/services/logger_service.dart';
import '../../views/widgets/ads/app_open_ad_manager.dart';

abstract class ShareHelper {
  static Future<void> shareText(
    String text, {
    String? subject,
    BuildContext? context,
  }) async {
    try {
      AppOpenAdManager.instance.skipNextResume();
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: subject,
          sharePositionOrigin: _originFor(context),
        ),
      );
    } catch (e) {
      AppLogger.e('Share failed', e);
      Get.snackbar(
        'share_error'.tr,
        'could_not_open_share'.trParams({'error': '$e'}),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  static Rect? _originFor(BuildContext? context) {
    final ctx = context ?? Get.context;
    if (ctx == null) return null;

    final box = ctx.findRenderObject();
    if (box is RenderBox && box.hasSize) {
      return box.localToGlobal(Offset.zero) & box.size;
    }

    final size = MediaQuery.maybeSizeOf(ctx);
    return size == null
        ? null
        : Rect.fromLTWH(0, 0, size.width, size.height / 2);
  }
}
