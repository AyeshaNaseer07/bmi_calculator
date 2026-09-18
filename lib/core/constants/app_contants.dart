import 'dart:async';
import 'dart:developer';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_2_wrappers.dart';

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

String getPriceWithPlan(ProductDetails productDetails) {
  try {
    if (productDetails is! AppStoreProduct2Details) {
      return productDetails.price;
    }

    final product = productDetails.sk2Product;
    final subscription = product.subscription;

    if (subscription == null) {
      return "${product.displayPrice}/Lifetime";
    }

    final planName = _getPlanName(subscription.subscriptionPeriod);

    if (subscription.promotionalOffers.isNotEmpty) {
      final offer = subscription.promotionalOffers.first;

      final offerPeriod = _getPlanName(offer.period);

      if (offer.price == 0) {
        return "Free for $offerPeriod, then ${product.displayPrice}/$planName";
      }

      final introPrice =
          "${productDetails.currencySymbol}${offer.price.toStringAsFixed(2)}";

      return "$introPrice/$offerPeriod, then ${product.displayPrice}/$planName";
    }

    return "${product.displayPrice}/$planName";
  } catch (e) {
    log("Subscription format error: $e");
    return productDetails.price;
  }
}

bool getAutoRenewalText(ProductDetails? productDetails) {
  try {
    if (productDetails == null) {
      return true;
    }
    if (productDetails is! AppStoreProduct2Details) {
      return true;
    }

    final product = productDetails.sk2Product;
    final subscription = product.subscription;

    if (subscription == null) {
      return false;
    }

    return true;
  } catch (e) {
    return true;
  }
}

String _getPlanName(SK2SubscriptionPeriod period) {
  switch (period.unit) {
    case SK2SubscriptionPeriodUnit.day:
      return period.value == 1
          ? "Daily"
          : period.value < 7
          ? "${period.value} Days"
          : "Weekly";
    case SK2SubscriptionPeriodUnit.week:
      return period.value == 1 ? "Weekly" : "${period.value} Weeks";
    case SK2SubscriptionPeriodUnit.month:
      return period.value == 1 ? "Monthly" : "${period.value} Months";
    case SK2SubscriptionPeriodUnit.year:
      return period.value == 1 ? "Yearly" : "${period.value} Years";
    // ignore: unreachable_switch_default
    default:
      return "";
  }
}
