import 'dart:developer';

import 'package:flutter/services.dart';

class PlatformCode {
  PlatformCode._();

  static const _channel = MethodChannel("bmi.calculator/log_transaction");
  static final Set<String> _loggedTransactionIds = {};

  /// StoreKit 2 entitlement state for [productIds]: `active`, `revoked`,
  /// `expired`, `none` or `unknown`. Returns `unknown` on any failure.
  static Future<String> getSubscriptionStatus(List<String> productIds) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'getSubscriptionStatus',
        productIds,
      );
      return result ?? 'unknown';
    } catch (e) {
      log("⚠️ Failed to read subscription status: $e");
      return 'unknown';
    }
  }

  static Future<void> logTransactionToFirebase({
    required String txt,
    String? transactionId,
  }) async {
    final dedupeKey = transactionId ?? txt;
    if (_loggedTransactionIds.contains(dedupeKey)) return;
    _loggedTransactionIds.add(dedupeKey);
    try {
      final result = await _channel.invokeMethod('logStoreKitTransaction', txt);
      log("✅ StoreKit2 logged: $result");
    } catch (e) {
      log("⚠️ Failed to log StoreKit2 transaction: $e");
    }
  }
}
