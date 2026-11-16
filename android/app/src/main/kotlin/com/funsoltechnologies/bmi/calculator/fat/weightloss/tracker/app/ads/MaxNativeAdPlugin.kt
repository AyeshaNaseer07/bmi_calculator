package com.funsoltechnologies.bmi.calculator.fat.weightloss.tracker.app.ads

import android.app.Activity
import android.content.Context
import android.graphics.Typeface
import android.util.Log
import android.view.View
import android.widget.TextView
import com.applovin.mediation.MaxAd
import com.applovin.mediation.MaxError
import com.applovin.mediation.nativeAds.MaxNativeAdListener
import com.applovin.mediation.nativeAds.MaxNativeAdLoader
import com.applovin.mediation.nativeAds.MaxNativeAdView
import com.applovin.mediation.nativeAds.MaxNativeAdViewBinder
import com.funsoltechnologies.bmi.calculator.fat.weightloss.tracker.app.R
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * Android port of ios/Runner/MaxNativeAdPlugin.swift.
 *
 * Same channel ("max_native_ad"), same methods (preload, destroy), same events
 * (onAdLoaded, onAdLoadFailed, onAdExpired, onAdClicked, onAdRevenuePaid) and
 * the same view type ("max_native_ad_view"), so lib/views/widgets/ads/
 * max_native_ad.dart drives both platforms with one code path.
 */
class MaxNativeAdPlugin : FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler {
    private var channel: MethodChannel? = null
    private var appContext: Context? = null
    private var activity: Activity? = null
    private val placements = mutableMapOf<String, PreloadedMaxNativeAd>()

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        appContext = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL).also {
            it.setMethodCallHandler(this)
        }
        binding.platformViewRegistry.registerViewFactory(VIEW_TYPE, MaxNativeAdViewFactory(this))
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
        placements.values.forEach { it.release() }
        placements.clear()
        appContext = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val placement = call.argument<String>("placement")
        if (placement.isNullOrEmpty()) {
            result.error("invalid_args", "placement is required", null)
            return
        }
        when (call.method) {
            "preload" -> {
                val adUnitId = call.argument<String>("adUnitId")
                if (adUnitId.isNullOrEmpty()) {
                    result.error("invalid_args", "adUnitId is required", null)
                    return
                }
                val context = activity ?: appContext
                if (context == null) {
                    result.error("no_context", "plugin is not attached", null)
                    return
                }
                val ad = placements.getOrPut(placement) { PreloadedMaxNativeAd(placement, this) }
                ad.preload(adUnitId, context)
                result.success(null)
            }
            "destroy" -> {
                placements[placement]?.destroyAd()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    /** Renders [placement]'s preloaded ad into [adView]. Returns false if there is none. */
    fun render(placement: String, adView: MaxNativeAdView): Boolean =
        placements[placement]?.render(adView) ?: false

    internal fun send(method: String, placement: String, arguments: Map<String, Any?> = emptyMap()) {
        channel?.invokeMethod(method, arguments + ("placement" to placement))
    }

    companion object {
        const val CHANNEL = "max_native_ad"
        const val VIEW_TYPE = "max_native_ad_view"
        internal const val TAG = "MaxNativeAd"
    }
}

/** One placement's preloaded native ad. */
internal class PreloadedMaxNativeAd(
    private val placement: String,
    private val plugin: MaxNativeAdPlugin,
) {
    private var adLoader: MaxNativeAdLoader? = null
    private var adUnitId: String? = null
    private var loadedAd: MaxAd? = null
    private var isLoading = false
    private var isRendered = false

    private val listener = object : MaxNativeAdListener() {
        override fun onNativeAdLoaded(nativeAdView: MaxNativeAdView?, ad: MaxAd) {
            isLoading = false
            loadedAd = ad
            send("onAdLoaded")
        }

        override fun onNativeAdLoadFailed(adUnitId: String, error: MaxError) {
            isLoading = false
            send("onAdLoadFailed", mapOf("code" to error.code, "message" to error.message))
        }

        override fun onNativeAdClicked(ad: MaxAd) {
            send("onAdClicked")
        }

        override fun onNativeAdExpired(ad: MaxAd) {
            // Only an ad still waiting to be shown is dropped; one on screen stays
            if (ad !== loadedAd || isRendered) return
            destroyAd()
            send("onAdExpired")
        }
    }

    fun preload(adUnitId: String, context: Context) {
        if (isLoading) return
        val ad = loadedAd
        if (ad != null && ad.nativeAd?.isExpired == false) {
            send("onAdLoaded")
            return
        }
        destroyAd()
        if (this.adUnitId != adUnitId || adLoader == null) {
            adLoader?.destroy()
            adLoader = MaxNativeAdLoader(adUnitId, context).apply {
                setNativeAdListener(listener)
                setRevenueListener { paid ->
                    send(
                        "onAdRevenuePaid",
                        mapOf(
                            "networkName" to paid.networkName,
                            "revenue" to paid.revenue,
                            "adUnitId" to paid.adUnitId,
                        ),
                    )
                }
            }
            this.adUnitId = adUnitId
        }
        isLoading = true
        adLoader?.loadAd()
    }

    fun render(adView: MaxNativeAdView): Boolean {
        val loader = adLoader ?: return false
        val ad = loadedAd ?: return false
        if (ad.nativeAd?.isExpired == true) return false
        isRendered = loader.render(adView, ad)
        return isRendered
    }

    fun destroyAd() {
        loadedAd?.let { adLoader?.destroy(it) }
        loadedAd = null
        isRendered = false
    }

    fun release() {
        destroyAd()
        adLoader?.destroy()
        adLoader = null
        adUnitId = null
        isLoading = false
    }

    private fun send(method: String, arguments: Map<String, Any?> = emptyMap()) {
        plugin.send(method, placement, arguments)
    }
}

internal class MaxNativeAdViewFactory(
    private val plugin: MaxNativeAdPlugin,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val placement = (args as? Map<*, *>)?.get("placement") as? String ?: ""
        return MaxNativeAdPlatformView(context, placement, plugin)
    }
}

/**
 * Same card as the iOS MaxNativeAdPlatformView: media on the top 70% (shown
 * whole, never cropped), then icon, title, an "Ad" badge with the description,
 * and a full-width pill call to action. The layout itself lives in
 * [NativeAdCardLayout] and res/layout/max_native_ad_card.xml.
 */
internal class MaxNativeAdPlatformView(
    context: Context,
    placement: String,
    plugin: MaxNativeAdPlugin,
) : PlatformView {
    private val adView: MaxNativeAdView = makeMediaAdView(context)

    init {
        if (!plugin.render(placement, adView)) {
            Log.w(MaxNativeAdPlugin.TAG, "No preloaded native ad to render for $placement")
        }
    }

    override fun getView(): View = adView

    override fun dispose() {}

    private fun makeMediaAdView(context: Context): MaxNativeAdView {
        val binder = MaxNativeAdViewBinder.Builder(R.layout.max_native_ad_card)
            .setTitleTextViewId(R.id.native_ad_title)
            .setBodyTextViewId(R.id.native_ad_body)
            .setIconImageViewId(R.id.native_ad_icon)
            .setOptionsContentViewGroupId(R.id.native_ad_options)
            .setMediaContentViewGroupId(R.id.native_ad_media)
            .setCallToActionButtonId(R.id.native_ad_cta)
            .build()
        val adView = MaxNativeAdView(binder, context)

        // iOS draws this card in the system font; the app uses Inter as its
        // stand-in on Android (see pubspec.yaml), so use it here too.
        AppFonts.apply(adView.findViewById(R.id.native_ad_title), AppFonts.bold(context))
        AppFonts.apply(adView.findViewById(R.id.native_ad_badge), AppFonts.bold(context))
        AppFonts.apply(adView.findViewById(R.id.native_ad_body), AppFonts.regular(context))
        AppFonts.apply(adView.findViewById(R.id.native_ad_cta), AppFonts.bold(context))
        return adView
    }
}

/** Inter, loaded from the Flutter asset bundle (assets/fonts). */
internal object AppFonts {
    private var regular: Typeface? = null
    private var bold: Typeface? = null

    fun regular(context: Context): Typeface =
        regular ?: load(context, "Inter-Regular.ttf", Typeface.DEFAULT).also { regular = it }

    fun bold(context: Context): Typeface =
        bold ?: load(context, "Inter-Bold.ttf", Typeface.DEFAULT_BOLD).also { bold = it }

    fun apply(view: TextView?, typeface: Typeface) {
        view?.typeface = typeface
    }

    private fun load(context: Context, file: String, fallback: Typeface): Typeface = try {
        val key = FlutterInjector.instance().flutterLoader()
            .getLookupKeyForAsset("assets/fonts/$file")
        Typeface.createFromAsset(context.assets, key)
    } catch (e: Exception) {
        Log.w(MaxNativeAdPlugin.TAG, "Could not load $file: ${e.message}")
        fallback
    }
}
