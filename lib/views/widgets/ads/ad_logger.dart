import 'package:flutter/foundation.dart';

class AdLogHelper {
  static void logRequest({required String tag, required String adUnitId}) {
    debugPrint('════════════════════════════════════════════════════════');
    debugPrint('📢 [$tag] REQUESTING AD...');
    debugPrint('   • Ad Unit ID : $adUnitId');
    debugPrint('   • Platform   : ${defaultTargetPlatform.name}');
    debugPrint('════════════════════════════════════════════════════════');
  }
}
