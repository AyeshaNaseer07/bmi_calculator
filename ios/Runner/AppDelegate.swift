import Flutter
import UIKit
import google_mobile_ads

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
