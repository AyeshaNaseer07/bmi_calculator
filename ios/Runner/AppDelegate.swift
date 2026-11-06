import Flutter
import UIKit
import UserNotifications
import StoreKit
import FirebaseAnalytics

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    if let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
      SceneDelegate.pendingShortcutType = shortcutItem.type
    }
    SceneDelegate.clearDynamicShortcuts()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  private var transactionChannel: FlutterMethodChannel?
  private var transactionUpdatesTask: Task<Void, Never>?

  private func setupTransactionChannel(messenger: FlutterBinaryMessenger) {
    let transactionChannel = FlutterMethodChannel(
      name: "bmi.calculator/log_transaction",
      binaryMessenger: messenger
    )
    self.transactionChannel = transactionChannel
    transactionChannel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { return }

      if call.method == "logStoreKitTransaction" {
        if let productId = call.arguments as? String {

          if #available(iOS 15.0, *) {
            Task {
              await self.fetchActiveSubscription(productId: productId)
            }
            result(nil)
          } else {
            result(FlutterError(
              code: "UNSUPPORTED_IOS_VERSION",
              message: "Requires iOS 15.0+",
              details: nil
            ))
          }

        } else {
          result(FlutterError(
            code: "INVALID_ARGUMENT",
            message: "Expected productId String",
            details: nil
          ))
        }

      } else if call.method == "finishUnfinishedTransactions" {
        if #available(iOS 15.0, *) {
          Task {
            result(await self.finishUnfinishedTransactions())
          }
        } else {
          result(0)
        }

      } else if call.method == "getSubscriptionStatus" {
        guard let productIds = call.arguments as? [String] else {
          result(FlutterError(
            code: "INVALID_ARGUMENT",
            message: "Expected list of product ids",
            details: nil
          ))
          return
        }
        if #available(iOS 15.0, *) {
          Task {
            result(await self.subscriptionStatus(productIds: productIds))
          }
        } else {
          result("unknown")
        }

      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }

  /// Finishes every verified unfinished transaction. Premium is decided from
  /// `Transaction.currentEntitlements`, which still includes finished
  /// transactions, so this is always safe. An unfinished transaction for a
  /// product blocks buying it again ("storekit_duplicate_product_object").
  @available(iOS 15.0, *)
  func finishUnfinishedTransactions() async -> Int {
    var count = 0
    for await result in Transaction.unfinished {
      if case .verified(let transaction) = result {
        await transaction.finish()
        count += 1
        print("[IAP] finished unfinished transaction \(transaction.id) (\(transaction.productID))")
      }
    }
    return count
  }

  /// Refunds, revocations, renewals and expiries arrive here while the app is
  /// running. Dart re-checks the entitlement when told.
  @available(iOS 15.0, *)
  func listenForTransactionUpdates() {
    transactionUpdatesTask?.cancel()
    transactionUpdatesTask = Task { [weak self] in
      for await result in Transaction.updates {
        if case .verified(let transaction) = result {
          print("[IAP] transaction update \(transaction.productID) revoked=\(transaction.revocationDate != nil)")
          await transaction.finish()
        }
        await MainActor.run {
          self?.transactionChannel?.invokeMethod("entitlementsChanged", arguments: nil)
        }
      }
    }
  }

  /// `active`, `revoked`, `expired`, `none` or `unknown` for [productIds].
  @available(iOS 15.0, *)
  func subscriptionStatus(productIds: [String]) async -> String {
    let ids = Set(productIds)
    var sawInactive: String?

    for await result in Transaction.currentEntitlements {
      guard case .verified(let transaction) = result,
            ids.contains(transaction.productID) else { continue }
      if transaction.revocationDate != nil { sawInactive = "revoked"; continue }
      if let expiry = transaction.expirationDate, expiry < Date() {
        sawInactive = "expired"; continue
      }
      return "active"
    }
    if let sawInactive = sawInactive { return sawInactive }

    // Not a current entitlement: look at the latest transaction per product.
    for id in ids {
      guard let latest = await Transaction.latest(for: id),
            case .verified(let transaction) = latest else { continue }
      if transaction.revocationDate != nil { return "revoked" }
      if let expiry = transaction.expirationDate, expiry < Date() { return "expired" }
    }
    return "none"
  }

  @available(iOS 15.0, *)
  func fetchActiveSubscription(productId: String) async {
    do {
      for await result in Transaction.currentEntitlements {
        switch result {

        case .verified(let transaction):
          if transaction.productID == productId {

            let isFirstPurchase = transaction.originalPurchaseDate == transaction.purchaseDate

            if isFirstPurchase {
              logPurchase(transaction)
              print("🆕 First Purchase: \(transaction.productID)")
            } else {
              print("🔄 Restored Purchase: \(transaction.productID)")
            }

            return
          }

        case .unverified(_, let error):
          print("⚠️ Unverified transaction: \(error.localizedDescription)")
        }
      }

      print("🚫 No entitlement found for product: \(productId)")

    } catch {
      print("🚫 Error: \(error.localizedDescription)")
    }
  }

  @available(iOS 15.0, *)
  private func logPurchase(_ transaction: Transaction) {
    Analytics.logEvent(AnalyticsEventPurchase, parameters: [
      AnalyticsParameterItemID: transaction.productID,
      AnalyticsParameterTransactionID: String(transaction.id),
    ])
  }

  override func application(
    _ application: UIApplication,
    performActionFor shortcutItem: UIApplicationShortcutItem,
    completionHandler: @escaping (Bool) -> Void
  ) {
    SceneDelegate.handleShortcut(type: shortcutItem.type)
    completionHandler(true)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    setupTransactionChannel(messenger: engineBridge.applicationRegistrar.messenger())
    if #available(iOS 15.0, *) {
      listenForTransactionUpdates()
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "MaxNativeAdPlugin") {
      MaxNativeAdPlugin.register(with: registrar)
    }
  }
}
