package com.funsoltechnologies.bmi.calculator.fat.weightloss.tracker.app

import android.app.Activity
import android.content.Intent
import android.os.Bundle

/**
 * Target of the launcher shortcuts (res/xml/shortcuts.xml), the Android
 * version of the iOS home-screen quick actions.
 *
 * Launchers start shortcut intents with FLAG_ACTIVITY_CLEAR_TASK, which would
 * restart the app if they pointed at MainActivity. This invisible activity
 * lives in its own task instead and forwards the shortcut to the running
 * MainActivity (onNewIntent), or starts it if the app isn't running, so a
 * quick action behaves as on iOS: it opens the screen without a restart.
 */
class ShortcutActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val type = intent?.getStringExtra(EXTRA_SHORTCUT_TYPE)
        val launch = Intent(this, MainActivity::class.java).apply {
            action = Intent.ACTION_MAIN
            addCategory(Intent.CATEGORY_LAUNCHER)
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP,
            )
            if (!type.isNullOrEmpty()) putExtra(EXTRA_SHORTCUT_TYPE, type)
        }
        startActivity(launch)
        finish()
        overridePendingTransition(0, 0)
    }

    companion object {
        const val EXTRA_SHORTCUT_TYPE = "shortcut_type"
    }
}
