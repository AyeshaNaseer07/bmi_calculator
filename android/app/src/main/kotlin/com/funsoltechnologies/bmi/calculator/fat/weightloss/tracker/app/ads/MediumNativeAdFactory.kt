package com.funsoltechnologies.bmi.calculator.fat.weightloss.tracker.app.ads

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import com.funsoltechnologies.bmi.calculator.fat.weightloss.tracker.app.R
import com.google.android.gms.ads.nativead.AdChoicesView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

/**
 * Renders the medium/bottom native ad card used on the language + BMI onboarding
 * screens: icon + headline row, "AD" badge + body row, media, full-width CTA.
 */
class MediumNativeAdFactory(private val context: Context) :
    GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?,
    ): NativeAdView {
        val adView = LayoutInflater.from(context)
            .inflate(R.layout.medium_native_ad, null) as NativeAdView

        val iconView = adView.findViewById<ImageView>(R.id.ad_app_icon)
        val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
        val bodyView = adView.findViewById<TextView>(R.id.ad_body)
        val mediaView = adView.findViewById<MediaView>(R.id.ad_media)
        val ctaView = adView.findViewById<Button>(R.id.ad_cta)
        val adChoicesContainer = adView.findViewById<FrameLayout>(R.id.ad_choices_container)

        headlineView.text = nativeAd.headline
        adView.headlineView = headlineView

        bodyView.text = nativeAd.body ?: nativeAd.advertiser ?: ""
        adView.bodyView = bodyView

        val icon = nativeAd.icon
        if (icon != null) {
            iconView.setImageDrawable(icon.drawable)
            iconView.visibility = View.VISIBLE
        } else {
            iconView.visibility = View.GONE
        }
        adView.iconView = iconView

        val cta = nativeAd.callToAction
        ctaView.text = if (!cta.isNullOrEmpty()) cta else "Install"
        adView.callToActionView = ctaView

        mediaView.mediaContent = nativeAd.mediaContent
        mediaView.setImageScaleType(ImageView.ScaleType.CENTER_CROP)
        adView.mediaView = mediaView

        val adChoicesView = AdChoicesView(context)
        adChoicesContainer.removeAllViews()
        adChoicesContainer.addView(adChoicesView)
        adView.adChoicesView = adChoicesView

        adView.setNativeAd(nativeAd)
        return adView
    }
}
