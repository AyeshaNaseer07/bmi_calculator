import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdLogHelper {
  static String explainErrorCode(int code) {
    switch (code) {
      case 0:
        return 'INTERNAL_ERROR (Something happened internally, e.g. invalid response from ad server or format mismatch)';
      case 1:
        return 'INVALID_REQUEST (The ad request was invalid, e.g. invalid/empty ad unit ID, missing test device ID, or unapproved ad unit)';
      case 2:
        return 'NETWORK_ERROR (Network connectivity failure or timeout while communicating with ad server)';
      case 3:
        return 'NO_FILL (The ad request was successful, but AdMob had no available ad inventory to serve)';
      case 8:
        return 'APP_ID_MISSING (Google Mobile Ads SDK was initialized without a valid App ID in Info.plist / AndroidManifest)';
      case 9:
        return 'MEDIATION_NO_FILL (None of the configured mediation networks returned an ad)';
      default:
        return 'UNKNOWN_CODE ($code)';
    }
  }

  static void logRequest({
    required String tag,
    required String adUnitId,
    required String factoryId,
  }) {
    debugPrint('════════════════════════════════════════════════════════');
    debugPrint('📢 [$tag] REQUESTING NATIVE AD...');
    debugPrint('   • Ad Unit ID : $adUnitId');
    debugPrint('   • Factory ID : $factoryId');
    debugPrint('   • Platform   : ${defaultTargetPlatform.name}');
    debugPrint('════════════════════════════════════════════════════════');
  }

  static void logLoaded({
    required String tag,
    required NativeAd ad,
  }) {
    debugPrint('════════════════════════════════════════════════════════');
    debugPrint('✅ [$tag] NATIVE AD LOADED SUCCESSFULLY!');
    debugPrint('   • Ad Unit ID : ${ad.adUnitId}');
    debugPrint('   • Response ID: ${ad.responseInfo?.responseId ?? "N/A"}');
    debugPrint('   • Mediation  : ${ad.responseInfo?.mediationAdapterClassName ?? "None"}');
    debugPrint('════════════════════════════════════════════════════════');
  }

  static void logFailed({
    required String tag,
    required NativeAd ad,
    required LoadAdError error,
  }) {
    debugPrint('════════════════════════════════════════════════════════');
    debugPrint('❌ [$tag] NATIVE AD FAILED TO LOAD!');
    debugPrint('   • Ad Unit ID : ${ad.adUnitId}');
    debugPrint('   • Error Code : ${error.code} -> ${explainErrorCode(error.code)}');
    debugPrint('   • Domain     : ${error.domain}');
    debugPrint('   • Message    : ${error.message}');
    if (error.responseInfo != null) {
      debugPrint('   • Response ID: ${error.responseInfo?.responseId ?? "N/A"}');
      debugPrint('   • Mediation  : ${error.responseInfo?.mediationAdapterClassName ?? "None"}');
      final adapterResponses = error.responseInfo?.adapterResponses;
      if (adapterResponses != null && adapterResponses.isNotEmpty) {
        debugPrint('   • Adapter Responses:');
        for (final resp in adapterResponses) {
          debugPrint('     - Adapter: ${resp.adapterClassName}');
          debugPrint('       Latency: ${resp.latencyMillis}ms');
          if (resp.adError != null) {
            debugPrint('       Error  : [${resp.adError?.code}] ${resp.adError?.message}');
          }
        }
      }
    }
    debugPrint('════════════════════════════════════════════════════════');
  }
}
