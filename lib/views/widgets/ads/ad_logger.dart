import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/foundation.dart';

class AdLogHelper {
  static void logRequest({required String tag, required String adUnitId}) {
    debugPrint('════════════════════════════════════════════════════════');
    debugPrint('📢 [$tag] REQUESTING AD...');
    debugPrint('   • Ad Unit ID : $adUnitId');
    debugPrint('   • Platform   : ${defaultTargetPlatform.name}');
    debugPrint('════════════════════════════════════════════════════════');
  }

  static void logLoaded({required String tag, required MaxAd ad}) {
    debugPrint('════════════════════════════════════════════════════════');
    debugPrint('✅ [$tag] AD LOADED SUCCESSFULLY!');
    debugPrint('   • Ad Unit ID : ${ad.adUnitId}');
    debugPrint('   • Network    : ${ad.networkName}');
    debugPrint('   • Creative ID: ${ad.creativeId}');
    debugPrint('════════════════════════════════════════════════════════');
  }

  static void logFailed({
    required String tag,
    required String adUnitId,
    required MaxError error,
  }) {
    debugPrint('════════════════════════════════════════════════════════');
    debugPrint('❌ [$tag] AD FAILED TO LOAD!');
    debugPrint('   • Ad Unit ID : $adUnitId');
    debugPrint('   • Error Code : ${error.code}');
    debugPrint('   • Message    : ${error.message}');
    final responses = error.waterfall?.networkResponses;
    if (responses != null && responses.isNotEmpty) {
      debugPrint('   • Network Responses:');
      for (final resp in responses) {
        debugPrint(
          '     - ${resp.mediatedNetwork.name}: '
          '${resp.adLoadState.name} (${resp.latencyMillis}ms)'
          '${resp.error != null ? ' ${resp.error!.message}' : ''}',
        );
      }
    }
    debugPrint('════════════════════════════════════════════════════════');
  }
}
