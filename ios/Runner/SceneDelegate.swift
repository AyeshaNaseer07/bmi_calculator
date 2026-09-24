import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  static let channelName = "com.funsoltechnologies.bmi/quick_actions"
  static var pendingShortcutType: String?
  static var methodChannel: FlutterMethodChannel?

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    if let shortcutItem = connectionOptions.shortcutItem {
      SceneDelegate.pendingShortcutType = shortcutItem.type
    }
    setupChannel()
    SceneDelegate.updateDynamicShortcuts()
  }

  override func windowScene(
    _ windowScene: UIWindowScene,
    performActionFor shortcutItem: UIApplicationShortcutItem,
    completionHandler: @escaping (Bool) -> Void
  ) {
    SceneDelegate.handleShortcut(type: shortcutItem.type)
    completionHandler(true)
  }

  private func setupChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
        self?.setupChannel()
      }
      return
    }

    if SceneDelegate.methodChannel == nil {
      let channel = FlutterMethodChannel(name: SceneDelegate.channelName, binaryMessenger: controller.binaryMessenger)
      SceneDelegate.methodChannel = channel

      channel.setMethodCallHandler { (call, result) in
        if call.method == "getInitialShortcut" {
          let pending = SceneDelegate.pendingShortcutType
          SceneDelegate.pendingShortcutType = nil
          result(pending)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }

      if let pending = SceneDelegate.pendingShortcutType {
        SceneDelegate.pendingShortcutType = nil
        channel.invokeMethod("onShortcut", arguments: pending)
      }
    }
  }

  static func handleShortcut(type: String) {
    if let channel = methodChannel {
      channel.invokeMethod("onShortcut", arguments: type)
    } else {
      pendingShortcutType = type
    }
  }

  static func updateDynamicShortcuts() {
    if #available(iOS 13.0, *) {
      let calculateIcon = UIApplicationShortcutIcon(systemImageName: "speedometer")
      let progressIcon: UIApplicationShortcutIcon
      if #available(iOS 14.0, *) {
        progressIcon = UIApplicationShortcutIcon(systemImageName: "chart.line.uptrend.xyaxis")
      } else {
        progressIcon = UIApplicationShortcutIcon(systemImageName: "chart.bar.fill")
      }
      let insightsIcon = UIApplicationShortcutIcon(systemImageName: "lightbulb.fill")

      let itemCalculate = UIApplicationShortcutItem(
        type: "calculate_bmi",
        localizedTitle: "Calculate BMI",
        localizedSubtitle: nil,
        icon: calculateIcon,
        userInfo: nil
      )

      let itemTrack = UIApplicationShortcutItem(
        type: "track_progress",
        localizedTitle: "Track Progress",
        localizedSubtitle: nil,
        icon: progressIcon,
        userInfo: nil
      )

      let itemInsights = UIApplicationShortcutItem(
        type: "insights",
        localizedTitle: "Insights",
        localizedSubtitle: nil,
        icon: insightsIcon,
        userInfo: nil
      )

      UIApplication.shared.shortcutItems = [itemCalculate, itemTrack, itemInsights]
    }
  }
}
