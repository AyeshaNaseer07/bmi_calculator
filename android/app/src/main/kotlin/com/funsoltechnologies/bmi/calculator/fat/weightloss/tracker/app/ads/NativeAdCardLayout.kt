package com.funsoltechnologies.bmi.calculator.fat.weightloss.tracker.app.ads

import android.content.Context
import android.graphics.Outline
import android.util.AttributeSet
import android.view.View
import android.view.ViewOutlineProvider
import android.widget.FrameLayout
import com.funsoltechnologies.bmi.calculator.fat.weightloss.tracker.app.R
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

/**
 * Lays out the native ad card exactly like the Auto Layout constraints in
 * ios/Runner/MaxNativeAdPlugin.swift (all values in dp = iOS points):
 *
 * - media: top, full width, 70% of the card's height when there is room; on
 *   short cards it gives way so the details below always fit
 * - AdChoices: 20×20, inset 14 from the top/trailing corner
 * - icon: 56×56, 12 below the media, inset 14 from the leading edge
 * - title: level with the icon top, 12 after the icon, to the trailing inset
 * - "Ad" badge: 22×14, under the title start, 1 below the description top
 * - description: 4 below the title, 5 after the badge, to the trailing inset
 * - call to action: 50 high, full width inside the insets, 14 above the bottom
 *
 * Leading/trailing follow the layout direction, as they do on iOS.
 * The card does not clip itself (an AdChoices icon in the corner must not be
 * cut off); the rounding comes from the background and the media clips itself.
 */
class NativeAdCardLayout @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
) : FrameLayout(context, attrs) {

    private val density = resources.displayMetrics.density
    private fun dp(value: Float): Int = (value * density).roundToInt()

    private val inset = dp(14f)
    private val gap = dp(12f)
    private val iconSize = dp(56f)
    private val badgeWidth = dp(22f)
    private val badgeHeight = dp(14f)
    private val badgeGap = dp(5f)
    private val titleToBody = dp(4f)
    private val ctaHeight = dp(50f)
    private val optionsSize = dp(20f)
    private val cardRadius = dp(18f).toFloat()
    private val iconRadius = dp(12f).toFloat()

    private lateinit var media: View
    private lateinit var options: View
    private lateinit var icon: View
    private lateinit var title: View
    private lateinit var badge: View
    private lateinit var body: View
    private lateinit var cta: View

    private var mediaHeight = 0

    init {
        clipChildren = false
        clipToPadding = false
    }

    override fun onFinishInflate() {
        super.onFinishInflate()
        media = findViewById(R.id.native_ad_media)
        options = findViewById(R.id.native_ad_options)
        icon = findViewById(R.id.native_ad_icon)
        title = findViewById(R.id.native_ad_title)
        badge = findViewById(R.id.native_ad_badge)
        body = findViewById(R.id.native_ad_body)
        cta = findViewById(R.id.native_ad_cta)

        // Media: only the top corners are rounded, matching the card.
        media.outlineProvider = object : ViewOutlineProvider() {
            override fun getOutline(view: View, outline: Outline) {
                outline.setRoundRect(0, 0, view.width, view.height + cardRadius.toInt(), cardRadius)
            }
        }
        media.clipToOutline = true

        icon.outlineProvider = object : ViewOutlineProvider() {
            override fun getOutline(view: View, outline: Outline) {
                outline.setRoundRect(0, 0, view.width, view.height, iconRadius)
            }
        }
        icon.clipToOutline = true
    }

    private fun exactly(size: Int) = MeasureSpec.makeMeasureSpec(max(0, size), MeasureSpec.EXACTLY)
    private val unspecified = MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED)

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val width = MeasureSpec.getSize(widthMeasureSpec)
        val height = MeasureSpec.getSize(heightMeasureSpec)

        val textWidth = width - inset - iconSize - gap - inset
        title.measure(exactly(textWidth), unspecified)
        badge.measure(exactly(badgeWidth), exactly(badgeHeight))
        body.measure(exactly(textWidth - badgeWidth - badgeGap), unspecified)
        icon.measure(exactly(iconSize), exactly(iconSize))
        cta.measure(exactly(width - 2 * inset), exactly(ctaHeight))
        options.measure(exactly(optionsSize), exactly(optionsSize))

        // Everything below the media: 12, the taller of icon / text, at least
        // 12, the 50 CTA, and the 14 bottom inset.
        val details = max(iconSize, title.measuredHeight + titleToBody + body.measuredHeight)
        val below = gap + details + gap + ctaHeight + inset
        mediaHeight = min((height * 0.7f).roundToInt(), max(0, height - below))
        media.measure(exactly(width), exactly(mediaHeight))

        setMeasuredDimension(width, height)
    }

    override fun onLayout(changed: Boolean, left: Int, top: Int, right: Int, bottom: Int) {
        val width = right - left
        val height = bottom - top
        val rtl = layoutDirection == View.LAYOUT_DIRECTION_RTL

        // [start] is measured from the leading edge.
        fun place(view: View, start: Int, y: Int) {
            val x = if (rtl) width - start - view.measuredWidth else start
            view.layout(x, y, x + view.measuredWidth, y + view.measuredHeight)
        }

        place(media, 0, 0)

        val detailsTop = mediaHeight + gap
        val textStart = inset + iconSize + gap
        place(icon, inset, detailsTop)
        place(title, textStart, detailsTop)

        val bodyTop = detailsTop + title.measuredHeight + titleToBody
        place(badge, textStart, bodyTop + dp(1f))
        place(body, textStart + badgeWidth + badgeGap, bodyTop)

        place(cta, inset, height - inset - ctaHeight)
        place(options, width - inset - optionsSize, inset)
    }
}
