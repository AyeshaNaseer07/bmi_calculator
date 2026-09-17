import 'dart:async';
import 'dart:developer';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

PurchaseConnector? afPurchaseClient;
AppsflyerSdk? appsflyerSdk;

int dashboardAdCount = 0;
bool isFirstDashboardAdShown = false;

Future<void> showCMP() async {
  final completer = Completer<void>();
  try {
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(tagForUnderAgeOfConsent: false),
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          await ConsentForm.loadAndShowConsentFormIfRequired((
            FormError? error,
          ) async {
            if (error != null) {
              log('CMP form error: $error');
            }
            completer.complete();
          });
        } else {
          completer.complete();
        }
      },
      (FormError error) {
        log(
          'Consent info update failed: ${error.errorCode} - ${error.message}',
        );
        completer.complete();
      },
    );
  } catch (e) {
    log('CMP Error: $e');
    completer.complete();
  }
  return completer.future;
}
