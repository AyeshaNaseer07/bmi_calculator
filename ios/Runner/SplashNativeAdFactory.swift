import UIKit
import GoogleMobileAds
import google_mobile_ads

/// Native ad on the screen shown right after the splash.
///
/// Fills whatever height Flutter gives it (splash_ad_screen.dart):
///   - media on top (black letterbox, aspect-fit so the creative is never
///     cropped), top corners rounded
///   - 56pt rounded icon on the left, headline to its right, "Ad" badge +
///     body underneath the headline
///   - full-width brand-gradient pill CTA at the bottom
/// The app's own icon/title/Continue button sit below this view in Flutter.
class SplashNativeAdFactory: NSObject, FLTNativeAdFactory {

    private enum Layout {
        static let cornerRadius: CGFloat = 20
        static let sideMargin: CGFloat = 16
        static let mediaToIcon: CGFloat = 14
        static let iconSize: CGFloat = 56
        static let iconCornerRadius: CGFloat = 14
        static let iconToText: CGFloat = 12
        static let headlineToBody: CGFloat = 5
        static let badgeSize = CGSize(width: 24, height: 17)
        static let badgeToBody: CGFloat = 6
        static let detailsToCTA: CGFloat = 14
        static let ctaHeight: CGFloat = 50
        static let ctaBottom: CGFloat = 14
        // AdChoices inset from the rounded corner (>= ~0.3 x corner radius)
        // so the rounded mask doesn't crop it.
        static let adChoicesInset: CGFloat = 8
    }

    private enum Palette {
        static let background = UIColor(red: 0xF0/255.0, green: 0xFA/255.0, blue: 0xF6/255.0, alpha: 1)
        static let headline = UIColor(red: 0x0F/255.0, green: 0x1F/255.0, blue: 0x4B/255.0, alpha: 1)
        static let body = UIColor(red: 0x4B/255.0, green: 0x55/255.0, blue: 0x63/255.0, alpha: 1)
        static let badgeBackground = UIColor(red: 0xD4/255.0, green: 0xEF/255.0, blue: 0xE6/255.0, alpha: 1)
        static let badgeText = UIColor(red: 0x13/255.0, green: 0x8A/255.0, blue: 0x76/255.0, alpha: 1)
        static let iconBackground = UIColor.white
        static let iconBorder = UIColor(red: 0xE2/255.0, green: 0xF3/255.0, blue: 0xED/255.0, alpha: 1)
    }

    func createNativeAd(_ nativeAd: NativeAd, customOptions: [AnyHashable : Any]? = nil) -> NativeAdView? {
        let adView = NativeAdView()
        adView.backgroundColor = Palette.background
        adView.layer.cornerRadius = Layout.cornerRadius
        adView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        adView.layer.masksToBounds = true
        adView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // MARK: Media
        let mediaContainer = UIView()
        mediaContainer.translatesAutoresizingMaskIntoConstraints = false
        mediaContainer.backgroundColor = .black
        mediaContainer.clipsToBounds = true
        adView.addSubview(mediaContainer)

        let mediaView = SplashAdMediaView()
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        mediaView.contentMode = .scaleAspectFit
        mediaView.clipsToBounds = true
        mediaContainer.addSubview(mediaView)

        // MARK: Details
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.backgroundColor = Palette.iconBackground
        iconImageView.layer.cornerRadius = Layout.iconCornerRadius
        iconImageView.layer.borderWidth = 1
        iconImageView.layer.borderColor = Palette.iconBorder.cgColor
        iconImageView.layer.masksToBounds = true
        adView.addSubview(iconImageView)

        let headlineLabel = UILabel()
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        headlineLabel.textColor = Palette.headline
        headlineLabel.numberOfLines = 1
        headlineLabel.lineBreakMode = .byTruncatingTail
        adView.addSubview(headlineLabel)

        let adBadge = UILabel()
        adBadge.translatesAutoresizingMaskIntoConstraints = false
        adBadge.text = "Ad"
        adBadge.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        adBadge.textColor = Palette.badgeText
        adBadge.textAlignment = .center
        adBadge.backgroundColor = Palette.badgeBackground
        adBadge.layer.cornerRadius = 4
        adBadge.layer.masksToBounds = true
        adView.addSubview(adBadge)

        let bodyLabel = UILabel()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        bodyLabel.textColor = Palette.body
        bodyLabel.numberOfLines = 2
        bodyLabel.lineBreakMode = .byTruncatingTail
        bodyLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        adView.addSubview(bodyLabel)

        let ctaButton = GradientButton(type: .custom)
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.layer.cornerRadius = Layout.ctaHeight / 2
        ctaButton.layer.masksToBounds = true
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        ctaButton.isUserInteractionEnabled = false // NativeAdView handles the click
        adView.addSubview(ctaButton)

        // Last subview so it sits above the media.
        let adChoicesView = AdChoicesView()
        adChoicesView.translatesAutoresizingMaskIntoConstraints = false
        adView.addSubview(adChoicesView)

        // MARK: Constraints
        var constraints: [NSLayoutConstraint] = [
            mediaContainer.topAnchor.constraint(equalTo: adView.topAnchor),
            mediaContainer.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
            mediaContainer.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
            mediaContainer.bottomAnchor.constraint(equalTo: iconImageView.topAnchor, constant: -Layout.mediaToIcon),

            adChoicesView.topAnchor.constraint(equalTo: adView.topAnchor, constant: Layout.adChoicesInset),
            adChoicesView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -Layout.adChoicesInset),

            iconImageView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: Layout.sideMargin),
            iconImageView.widthAnchor.constraint(equalToConstant: Layout.iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: Layout.iconSize),

            headlineLabel.topAnchor.constraint(equalTo: iconImageView.topAnchor, constant: 2),
            headlineLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: Layout.iconToText),
            headlineLabel.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -Layout.sideMargin),

            adBadge.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: Layout.headlineToBody + 1),
            adBadge.leadingAnchor.constraint(equalTo: headlineLabel.leadingAnchor),
            adBadge.widthAnchor.constraint(equalToConstant: Layout.badgeSize.width),
            adBadge.heightAnchor.constraint(equalToConstant: Layout.badgeSize.height),

            bodyLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: Layout.headlineToBody),
            bodyLabel.leadingAnchor.constraint(equalTo: adBadge.trailingAnchor, constant: Layout.badgeToBody),
            bodyLabel.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -Layout.sideMargin),

            // CTA goes below whichever is taller: the icon or the text.
            ctaButton.topAnchor.constraint(greaterThanOrEqualTo: iconImageView.bottomAnchor, constant: Layout.detailsToCTA),
            ctaButton.topAnchor.constraint(greaterThanOrEqualTo: bodyLabel.bottomAnchor, constant: Layout.detailsToCTA),
            ctaButton.topAnchor.constraint(greaterThanOrEqualTo: adBadge.bottomAnchor, constant: Layout.detailsToCTA),
            ctaButton.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: Layout.sideMargin),
            ctaButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -Layout.sideMargin),
            ctaButton.heightAnchor.constraint(equalToConstant: Layout.ctaHeight),
            ctaButton.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -Layout.ctaBottom),
        ]

        // Keep the details block tight against the CTA; the media takes the rest.
        let iconToCTA = ctaButton.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: Layout.detailsToCTA)
        iconToCTA.priority = .defaultLow
        constraints.append(iconToCTA)

        // Media: centered in its region at the creative's own aspect ratio,
        // as large as fits, never cropped.
        let aspectRatio = nativeAd.mediaContent.aspectRatio
        if aspectRatio > 0 {
            let fillWidth = mediaView.widthAnchor.constraint(equalTo: mediaContainer.widthAnchor)
            fillWidth.priority = UILayoutPriority(750)
            let fillHeight = mediaView.heightAnchor.constraint(equalTo: mediaContainer.heightAnchor)
            fillHeight.priority = UILayoutPriority(740)
            constraints += [
                mediaView.centerXAnchor.constraint(equalTo: mediaContainer.centerXAnchor),
                mediaView.centerYAnchor.constraint(equalTo: mediaContainer.centerYAnchor),
                mediaView.widthAnchor.constraint(lessThanOrEqualTo: mediaContainer.widthAnchor),
                mediaView.heightAnchor.constraint(lessThanOrEqualTo: mediaContainer.heightAnchor),
                mediaView.widthAnchor.constraint(equalTo: mediaView.heightAnchor, multiplier: aspectRatio),
                fillWidth,
                fillHeight,
            ]
        } else {
            constraints += [
                mediaView.topAnchor.constraint(equalTo: mediaContainer.topAnchor),
                mediaView.leadingAnchor.constraint(equalTo: mediaContainer.leadingAnchor),
                mediaView.trailingAnchor.constraint(equalTo: mediaContainer.trailingAnchor),
                mediaView.bottomAnchor.constraint(equalTo: mediaContainer.bottomAnchor),
            ]
        }
        NSLayoutConstraint.activate(constraints)

        // MARK: Register asset views (adChoicesView before nativeAd)
        adView.headlineView = headlineLabel
        adView.bodyView = bodyLabel
        adView.iconView = iconImageView
        adView.mediaView = mediaView
        adView.callToActionView = ctaButton
        adView.adChoicesView = adChoicesView

        // MARK: Populate
        headlineLabel.text = nativeAd.headline
        bodyLabel.text = nativeAd.body
        bodyLabel.isHidden = (nativeAd.body ?? "").isEmpty

        if let icon = nativeAd.icon?.image {
            iconImageView.image = icon
        } else {
            iconImageView.image = nil
        }

        let cta = nativeAd.callToAction ?? ""
        ctaButton.setTitle(cta.isEmpty ? "Learn More" : cta, for: .normal)

        mediaView.mediaContent = nativeAd.mediaContent

        adView.nativeAd = nativeAd
        return adView
    }
}

// MediaView subclass forcing aspect-fit on the image/video subviews the SDK
// inserts, so the creative is always shown in full, never cropped.
private class SplashAdMediaView: MediaView {
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        applyAspectFit(to: subview)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        for subview in subviews {
            applyAspectFit(to: subview)
        }
    }

    private func applyAspectFit(to view: UIView) {
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        for child in view.subviews {
            child.contentMode = .scaleAspectFit
            child.clipsToBounds = true
        }
    }
}
