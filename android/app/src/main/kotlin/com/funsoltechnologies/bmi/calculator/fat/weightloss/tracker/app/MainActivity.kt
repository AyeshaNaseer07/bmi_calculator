package com.funsoltechnologies.bmi.calculator.fat.weightloss.tracker.app

import android.content.Intent
import android.os.Bundle
import com.funsoltechnologies.bmi.calculator.fat.weightloss.tracker.app.ads.MaxNativeAdPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var quickActionsChannel: MethodChannel? = null

    /** Cold-start shortcut, handed to Dart when it asks (like SceneDelegate). */
    private var pendingShortcut: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        // A recreated activity still carries the old intent: only a fresh
        // launch counts as a shortcut tap.
        if (savedInstanceState == null) pendingShortcut = takeShortcut(intent)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Android counterpart of ios/Runner/MaxNativeAdPlugin.swift.
        flutterEngine.plugins.add(MaxNativeAdPlugin())

        // Same channel and methods as ios/Runner/SceneDelegate.swift.
        quickActionsChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            QUICK_ACTIONS_CHANNEL,
        ).apply {
            setMethodCallHandler { call, result ->
                if (call.method == "getInitialShortcut") {
                    val pending = pendingShortcut
                    pendingShortcut = null
                    result.success(pending)
                } else {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val type = takeShortcut(intent) ?: return
        val channel = quickActionsChannel
        if (channel == null) {
            pendingShortcut = type
            return
        }
        // Do not push the shortcut until Dart's handler exists; until then it
        // stays pending and Dart pulls it via "getInitialShortcut".
        channel.invokeMethod("onShortcut", type, object : MethodChannel.Result {
            override fun success(result: Any?) {}
            override fun error(code: String, message: String?, details: Any?) {}
            override fun notImplemented() {
                pendingShortcut = type
            }
        })
    }

    private fun takeShortcut(intent: Intent?): String? {
        val type = intent?.getStringExtra(ShortcutActivity.EXTRA_SHORTCUT_TYPE)
        intent?.removeExtra(ShortcutActivity.EXTRA_SHORTCUT_TYPE)
        return type?.takeIf { it.isNotEmpty() }
    }

    companion object {
        const val QUICK_ACTIONS_CHANNEL = "com.funsoltechnologies.bmi/quick_actions"
    }
}
