package com.funsoltechnologies.bmi.calculator.fat.weightloss.tracker.app.ads

import android.content.Context
import android.graphics.Color
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import com.funsoltechnologies.bmi.calculator.fat.weightloss.tracker.app.R
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import kotlin.math.roundToInt

/**
 * Renders the full-screen interstitial-style native ad shown between onboarding
 * pages: large top media, centered icon/headline/stars/body card, full-width CTA.
 */
class FullScreenNativeAdFactory(private val context: Context) :
    GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?,
    ): NativeAdView {
        val adView = LayoutInflater.from(context)
            .inflate(R.layout.full_screen_native_ad, null) as NativeAdView

        val mediaView = adView.findViewById<MediaView>(R.id.ad_media)
        val iconView = adView.findViewById<ImageView>(R.id.ad_app_icon)
        val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
        val bodyView = adView.findViewById<TextView>(R.id.ad_body)
        val ctaView = adView.findViewById<Button>(R.id.ad_cta)
        val starsContainer = adView.findViewById<LinearLayout>(R.id.ad_stars)

        headlineView.text = nativeAd.headline
        adView.headlineView = headlineView

        bodyView.text = nativeAd.body ?: ""
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
        adView.mediaView = mediaView

        // Star rating: filled gold stars up to the rating, remainder light gray (default 4.0)
        val rating = nativeAd.starRating?.toDouble() ?: 4.0
        val fullStars = rating.roundToInt().coerceIn(0, 5)
        starsContainer.removeAllViews()
        for (i in 0 until 5) {
            val star = TextView(context).apply {
                text = "★"
                textSize = 14f
                setTextColor(if (i < fullStars) Color.parseColor("#FAB005") else Color.parseColor("#E0E0E0"))
            }
            starsContainer.addView(star)
        }
        adView.starRatingView = starsContainer

        adView.setNativeAd(nativeAd)
        return adView
    }
}
