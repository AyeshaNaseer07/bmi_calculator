import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  
   // MARK: 2. Transaction Log Channel
    let transactionChannel = FlutterMethodChannel(
      name: "bmi.calculator/log_transaction",
      binaryMessenger: controller.binaryMessenger
    )
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

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
              Analytics.logTransaction(transaction)
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
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "MaxNativeAdPlugin") {
      MaxNativeAdPlugin.register(with: registrar)
    }
  }
}
