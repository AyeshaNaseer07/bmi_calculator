import 'dart:convert';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:bmi_calculator/data/services/logger_service.dart';
import 'package:flutter/foundation.dart';

class PurchaseManager {
  static PurchaseManager? _instance;
  static PurchaseConnector? _afPurchaseClient;
  static bool _isConfigured = false;
  static PurchaseManager get instance {
    _instance ??= PurchaseManager._internal();
    return _instance!;
  }

  PurchaseManager._internal();

  Future<void> initialize() async {
    if (_isConfigured) {
      AppLogger.i(
        'PurchaseConnector already configured, skipping initialization',
      );
      return;
    }
    try {
      _afPurchaseClient = PurchaseConnector(
        config: PurchaseConnectorConfiguration(
          logSubscriptions: true,
          logInApps: true,
          storeKitVersion: StoreKitVersion.SK2,
          sandbox: (kDebugMode || kProfileMode),
        ),
      );
      _afPurchaseClient!.setDidReceivePurchaseRevenueValidationInfo((
        validationInfo,
        error,
      ) {
        var validationInfoMsg = validationInfo != null
            ? jsonEncode(validationInfo)
            : null;
        var errMsg = error != null ? jsonEncode(error.toJson()) : null;
        AppLogger.i(
          "iOS Validation Result\n\t validationInfo: $validationInfoMsg\n\terror: $errMsg",
        );
        if (validationInfo != null && error == null) {
          final productId = validationInfo['product_id'];
          final revenue = validationInfo['revenue'];
          final currency = validationInfo['currency'];
          AppLogger.i(
            'Purchase tracked: $productId, Revenue: $revenue $currency',
          );
        } else {
          AppLogger.w(
            "Purchase validation failed. Skipping analytics logging.",
          );
        }
      });
      _afPurchaseClient?.startObservingTransactions();
      _isConfigured = true;
    } catch (e) {
      rethrow;
    }
  }
}
