import Flutter
import UIKit
import AppLovinSDK

final class MaxNativeAdPlugin: NSObject, FlutterPlugin {
    static let shared = MaxNativeAdPlugin()

    private var channel: FlutterMethodChannel?
    private var placements: [String: PreloadedMaxNativeAd] = [:]

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "max_native_ad", binaryMessenger: registrar.messenger())
        shared.channel = channel
        registrar.addMethodCallDelegate(shared, channel: channel)
        registrar.register(MaxNativeAdViewFactory(), withId: "max_native_ad_view")
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]
        guard let placement = args?["placement"] as? String, !placement.isEmpty else {
            result(FlutterError(code: "invalid_args", message: "placement is required", details: nil))
            return
        }
        switch call.method {
        case "preload":
            guard let adUnitId = args?["adUnitId"] as? String, !adUnitId.isEmpty else {
                result(FlutterError(code: "invalid_args", message: "adUnitId is required", details: nil))
                return
            }
            let ad = placements[placement] ?? PreloadedMaxNativeAd(placement: placement)
            placements[placement] = ad
            ad.preload(adUnitId: adUnitId)
            result(nil)
        case "destroy":
            placements[placement]?.destroyAd()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// Renders `placement`'s preloaded ad into `adView`. Returns false if there is none.
    func render(placement: String, into adView: MANativeAdView) -> Bool {
        placements[placement]?.render(into: adView) ?? false
    }

    fileprivate func send(_ method: String, placement: String, arguments: [String: Any] = [:]) {
        var payload = arguments
        payload["placement"] = placement
        channel?.invokeMethod(method, arguments: payload)
    }
}

/// One placement's preloaded native ad
final class PreloadedMaxNativeAd: NSObject, MANativeAdDelegate, MAAdRevenueDelegate {
    let placement: String

    private var adLoader: MANativeAdLoader?
    private var loadedAd: MAAd?
    private var isLoading = false
    private var isRendered = false

    init(placement: String) {
        self.placement = placement
    }

    func preload(adUnitId: String) {
        if isLoading { return }
        if let ad = loadedAd, ad.nativeAd?.isExpired == false {
            send("onAdLoaded")
            return
        }
        destroyAd()
        if adLoader?.adUnitIdentifier != adUnitId {
            let loader = MANativeAdLoader(adUnitIdentifier: adUnitId)
            loader.nativeAdDelegate = self
            loader.revenueDelegate = self
            adLoader = loader
        }
        isLoading = true
        adLoader?.loadAd()
    }

    func render(into adView: MANativeAdView) -> Bool {
        guard let loader = adLoader, let ad = loadedAd, ad.nativeAd?.isExpired == false else { return false }
        isRendered = loader.renderNativeAdView(adView, with: ad)
        return isRendered
    }

    func destroyAd() {
        if let ad = loadedAd {
            adLoader?.destroy(ad)
        }
        loadedAd = nil
        isRendered = false
    }

    private func send(_ method: String, arguments: [String: Any] = [:]) {
        MaxNativeAdPlugin.shared.send(method, placement: placement, arguments: arguments)
    }

    // MARK: MANativeAdDelegate

    func didLoadNativeAd(_ nativeAdView: MANativeAdView?, for ad: MAAd) {
        isLoading = false
        loadedAd = ad
        send("onAdLoaded")
    }

    func didFailToLoadNativeAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        isLoading = false
        send("onAdLoadFailed", arguments: [
            "code": error.code.rawValue,
            "message": error.message,
        ])
    }

    func didClickNativeAd(_ ad: MAAd) {
        send("onAdClicked")
    }

    func didExpireNativeAd(_ ad: MAAd) {
        // Only an ad still waiting to be shown is dropped; one on screen stays
        guard ad === loadedAd, !isRendered else { return }
        destroyAd()
        send("onAdExpired")
    }

    // MARK: MAAdRevenueDelegate

    func didPayRevenue(for ad: MAAd) {
        send("onAdRevenuePaid", arguments: [
            "networkName": ad.networkName,
            "revenue": ad.revenue,
            "adUnitId": ad.adUnitIdentifier,
        ])
    }
}

final class MaxNativeAdViewFactory: NSObject, FlutterPlatformViewFactory {
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let params = args as? [String: Any]
        return MaxNativeAdPlatformView(
            frame: frame,
            placement: params?["placement"] as? String ?? ""
        )
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }
}

/// The media fills the top 70% of the card and is shown whole (never
/// cropped). Below it are the icon, title, an "Ad" badge with the
/// description, and a full-width call to action.
/// The card does not clip its own bounds. Some networks (e.g. Google) put
/// their AdChoices icon in the ad view's very corner, and a rounded-corner
/// mask cuts it off. So the rounding comes from the background, and the
/// media view clips itself.
final class MaxNativeAdPlatformView: NSObject, FlutterPlatformView {
    private let adView: MANativeAdView

    init(frame: CGRect, placement: String) {
        adView = MaxNativeAdPlatformView.makeMediaAdView()
        adView.frame = frame
        super.init()
        if !MaxNativeAdPlugin.shared.render(placement: placement, into: adView) {
            NSLog("[MaxNativeAd] No preloaded native ad to render for \(placement)")
        }
    }

    func view() -> UIView {
        adView
    }

    private static let titleTag = 1001
    private static let bodyTag = 1002
    private static let iconTag = 1003
    private static let optionsTag = 1004
    private static let mediaTag = 1005
    private static let callToActionTag = 1006

    private static func makeMediaAdView() -> MANativeAdView {
        let inset: CGFloat = 14
        let cornerRadius: CGFloat = 18

        let adView = MANativeAdView(frame: .zero)
        adView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        // Rounded by the background only - see the class comment
        adView.layer.cornerRadius = cornerRadius
        adView.layer.masksToBounds = false

        // The network shows its media fitted (not cropped) inside this view
        let mediaView = UIView()
        mediaView.tag = mediaTag
        mediaView.clipsToBounds = true
        mediaView.layer.cornerRadius = cornerRadius
        mediaView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        // AdChoices goes here, inset from the rounded corner
        let optionsView = UIView()
        optionsView.tag = optionsTag

        let iconView = UIImageView()
        iconView.tag = iconTag
        iconView.contentMode = .scaleAspectFill
        iconView.layer.cornerRadius = 12
        iconView.layer.masksToBounds = true

        let titleLabel = UILabel()
        titleLabel.tag = titleTag
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail

        let adBadge = UILabel()
        adBadge.text = "Ad"
        adBadge.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        adBadge.textAlignment = .center
        adBadge.textColor = UIColor(white: 0.25, alpha: 1.0)
        adBadge.backgroundColor = UIColor(white: 0.88, alpha: 0.9)
        adBadge.layer.cornerRadius = 3
        adBadge.layer.masksToBounds = true

        let bodyLabel = UILabel()
        bodyLabel.tag = bodyTag
        bodyLabel.font = UIFont.systemFont(ofSize: 13)
        bodyLabel.textColor = UIColor(white: 0.45, alpha: 1.0)
        bodyLabel.numberOfLines = 2
        bodyLabel.lineBreakMode = .byTruncatingTail

        let callToActionButton = UIButton(type: .system)
        callToActionButton.tag = callToActionTag
        callToActionButton.backgroundColor = UIColor(red: 0x1B / 255.0, green: 0x92 / 255.0, blue: 0xD6 / 255.0, alpha: 1.0) // app CTA blue (#1B92D6)
        callToActionButton.setTitleColor(.white, for: .normal)
        callToActionButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        callToActionButton.layer.cornerRadius = 25 // pill: half the 50pt height
        callToActionButton.layer.masksToBounds = true

        for view in [mediaView, optionsView, iconView, titleLabel, adBadge, bodyLabel, callToActionButton] {
            view.translatesAutoresizingMaskIntoConstraints = false
            adView.addSubview(view)
        }

        // 70% of the card when there is room; on short cards the media gives
        // way so the details below always fit
        let mediaHeight = mediaView.heightAnchor.constraint(equalTo: adView.heightAnchor, multiplier: 0.7)
        mediaHeight.priority = .defaultHigh

        NSLayoutConstraint.activate([
            mediaView.topAnchor.constraint(equalTo: adView.topAnchor),
            mediaView.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
            mediaHeight,

            optionsView.topAnchor.constraint(equalTo: adView.topAnchor, constant: inset),
            optionsView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -inset),
            optionsView.widthAnchor.constraint(equalToConstant: 20),
            optionsView.heightAnchor.constraint(equalToConstant: 20),

            iconView.topAnchor.constraint(equalTo: mediaView.bottomAnchor, constant: 12),
            iconView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: inset),
            iconView.widthAnchor.constraint(equalToConstant: 56),
            iconView.heightAnchor.constraint(equalToConstant: 56),

            titleLabel.topAnchor.constraint(equalTo: iconView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -inset),

            // "Ad" badge leads the description, level with its first line
            adBadge.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            adBadge.topAnchor.constraint(equalTo: bodyLabel.topAnchor, constant: 1),
            adBadge.widthAnchor.constraint(equalToConstant: 22),
            adBadge.heightAnchor.constraint(equalToConstant: 14),

            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            bodyLabel.leadingAnchor.constraint(equalTo: adBadge.trailingAnchor, constant: 5),
            bodyLabel.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -inset),

            callToActionButton.topAnchor.constraint(greaterThanOrEqualTo: iconView.bottomAnchor, constant: 12),
            callToActionButton.topAnchor.constraint(greaterThanOrEqualTo: bodyLabel.bottomAnchor, constant: 12),
            callToActionButton.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: inset),
            callToActionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -inset),
            callToActionButton.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -inset),
            callToActionButton.heightAnchor.constraint(equalToConstant: 50),
        ])

        let binder = MANativeAdViewBinder { builder in
            builder.titleLabelTag = titleTag
            builder.bodyLabelTag = bodyTag
            builder.iconImageViewTag = iconTag
            builder.optionsContentViewTag = optionsTag
            builder.mediaContentViewTag = mediaTag
            builder.callToActionButtonTag = callToActionTag
        }
        adView.bindViews(with: binder)

        return adView
    }
}
