package com.funsoltechnologies.bmi.calculator.fat.weightloss.tracker.app

import com.funsoltechnologies.bmi.calculator.fat.weightloss.tracker.app.ads.FullScreenNativeAdFactory
import com.funsoltechnologies.bmi.calculator.fat.weightloss.tracker.app.ads.MediumNativeAdFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "mediumNativeAd",
            MediumNativeAdFactory(this),
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "fullScreenNativeAd",
            FullScreenNativeAdFactory(this),
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "mediumNativeAd")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "fullScreenNativeAd")
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
