import 'package:bmi_calculator/data/services/logger_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCat {
  static Future<void> configStore() async {
    if (await Purchases.isConfigured) return;

    StoreConfig(
      store: Store.appStore,
      apiKey: "b3d10db7-db40-4a70-8bcd-17be60a6bd5a",
    );

    await _configureSDK();
  }

  static Future<void> _configureSDK() async {
    try {
      await Purchases.setLogLevel(LogLevel.info);

      final configuration = PurchasesConfiguration(StoreConfig.instance.apiKey)
        ..appUserID = null
        ..purchasesAreCompletedBy = PurchasesAreCompletedByMyApp(
          storeKitVersion: StoreKitVersion.storeKit2,
        );

      await Purchases.configure(configuration);

      if (await Purchases.isConfigured) {
        await _setFirebaseAppInstanceId();
      } else {
        AppLogger.w("Purchases failed to configure.");
      }
    } catch (e, stack) {
      AppLogger.e("RevenueCat _configureSDK failed: $e", e, stack);
    }
  }

  static Future<void> _setFirebaseAppInstanceId() async {
    try {
      final analytics = FirebaseAnalytics.instance;
      final String? appInstanceId = await analytics.appInstanceId;

      if (appInstanceId != null && appInstanceId.isNotEmpty) {
        AppLogger.i("Firebase App Instance ID: $appInstanceId");

        await Purchases.setFirebaseAppInstanceId(appInstanceId);

        AppLogger.i("Firebase App Instance ID set in RevenueCat");
      } else {
        AppLogger.w("Firebase App Instance ID not found");
      }
    } catch (e, stack) {
      AppLogger.e("Error setting Firebase App Instance ID: $e", e, stack);
    }
  }
}

/// Store Configuration
class StoreConfig {
  final Store store;
  final String apiKey;

  static StoreConfig? _instance;

  factory StoreConfig({required Store store, required String apiKey}) {
    _instance ??= StoreConfig._internal(store, apiKey);
    return _instance!;
  }

  StoreConfig._internal(this.store, this.apiKey);

  static StoreConfig get instance => _instance!;

  static bool isForAppleStore() => instance.store == Store.appStore;
  static bool isForGooglePlay() => instance.store == Store.playStore;
  static bool isForAmazonAppstore() => instance.store == Store.amazon;
}
