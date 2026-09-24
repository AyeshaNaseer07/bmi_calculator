import Flutter
import UIKit
import google_mobile_ads
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    let mediumAdFactory = MediumNativeAdFactory()
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
      self,
      factoryId: "mediumNativeAd",
      nativeAdFactory: mediumAdFactory
    )

    let fullScreenAdFactory = FullScreenNativeAdFactory()
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
      self,
      factoryId: "fullScreenNativeAd",
      nativeAdFactory: fullScreenAdFactory
    )

    if let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
      SceneDelegate.pendingShortcutType = shortcutItem.type
    }
    SceneDelegate.updateDynamicShortcuts()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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

    let mediumAdFactory = MediumNativeAdFactory()
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
      engineBridge.pluginRegistry,
      factoryId: "mediumNativeAd",
      nativeAdFactory: mediumAdFactory
    )

    let fullScreenAdFactory = FullScreenNativeAdFactory()
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
      engineBridge.pluginRegistry,
      factoryId: "fullScreenNativeAd",
      nativeAdFactory: fullScreenAdFactory
    )
  }
}
