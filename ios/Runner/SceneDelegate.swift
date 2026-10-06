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
    SceneDelegate.clearDynamicShortcuts()
  }

  override func sceneDidBecomeActive(_ scene: UIScene) {
    super.sceneDidBecomeActive(scene)
    // Old builds registered dynamic shortcuts that iOS persists across
    // launches. Only the static Info.plist shortcuts should ever be shown.
    SceneDelegate.clearDynamicShortcuts()
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

  /// Clears dynamic shortcuts so iOS only displays the static shortcuts defined in Info.plist,
  /// preventing duplicates.
  static func clearDynamicShortcuts() {
    if let items = UIApplication.shared.shortcutItems, !items.isEmpty {
      UIApplication.shared.shortcutItems = []
    }
  }
}
