import UIKit
import GoogleMobileAds
import google_mobile_ads

/// Full-screen native ad shown between onboarding pages.
///
/// Geometry measured from the design (375 x 812 pt):
///   - white header, 52pt tall below the top inset: AD badge on the left
///     (the countdown / close control on the right is drawn by Flutter in
///     full_screen_native_ad_page.dart, aligned to the same row)
///   - media region filling the space between header and details, image
///     aspect-fit so the creative is never cropped
///   - 80pt rounded icon (centered), 9pt below the media
///   - star row (centered), headline 22 bold + body 13 (left-aligned, 16pt margins)
///   - 48pt gradient pill CTA, 53pt side margins, 15pt above the bottom safe area
class FullScreenNativeAdFactory: NSObject, FLTNativeAdFactory {

    private enum Layout {
        static let minTopInset: CGFloat = 20
        static let headerHeight: CGFloat = 52
        static let sideMargin: CGFloat = 16
        static let badgeTop: CGFloat = 21
        static let badgeSize = CGSize(width: 36, height: 23)
        static let mediaToIcon: CGFloat = 9
        static let iconSize: CGFloat = 80
        static let iconCornerRadius: CGFloat = 12
        static let iconToStars: CGFloat = 10
        static let starsToHeadline: CGFloat = 9
        static let headlineToBody: CGFloat = 11
        static let bodyToCTA: CGFloat = 20
        static let ctaHeight: CGFloat = 48
        static let ctaSideMargin: CGFloat = 53
        static let ctaBottom: CGFloat = 15
    }

    private enum Palette {
        static let badge = UIColor(red: 0x26/255.0, green: 0xF1/255.0, blue: 0xA5/255.0, alpha: 1)
        static let iconBackground = UIColor(red: 0xF6/255.0, green: 0xF6/255.0, blue: 0xF6/255.0, alpha: 1)
        static let starFilled = UIColor(red: 0xF9/255.0, green: 0xAE/255.0, blue: 0x0E/255.0, alpha: 1)
        static let starEmpty = UIColor(red: 0xE8/255.0, green: 0xE7/255.0, blue: 0xE8/255.0, alpha: 1)
        static let body = UIColor(red: 0x10/255.0, green: 0x10/255.0, blue: 0x10/255.0, alpha: 1)
    }

    func createNativeAd(_ nativeAd: NativeAd, customOptions: [AnyHashable : Any]? = nil) -> NativeAdView? {
        let adView = NativeAdView()
        adView.backgroundColor = .white
        adView.clipsToBounds = true
        adView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // MARK: Header (AD badge)
        let header = UIView()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = .white
        adView.addSubview(header)

        let adBadge = UILabel()
        adBadge.translatesAutoresizingMaskIntoConstraints = false
        adBadge.text = "AD"
        adBadge.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        adBadge.textColor = .black
        adBadge.textAlignment = .center
        adBadge.backgroundColor = Palette.badge
        adBadge.layer.cornerRadius = 3
        adBadge.layer.masksToBounds = true
        header.addSubview(adBadge)

        // MARK: Media
        let mediaContainer = UIView()
        mediaContainer.translatesAutoresizingMaskIntoConstraints = false
        mediaContainer.backgroundColor = .white
        mediaContainer.clipsToBounds = true
        adView.addSubview(mediaContainer)

        let mediaView = FullScreenAdMediaView()
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        mediaView.contentMode = .scaleAspectFit
        mediaView.clipsToBounds = true
        mediaContainer.addSubview(mediaView)

        let adChoicesView = AdChoicesView()
        adChoicesView.translatesAutoresizingMaskIntoConstraints = false
        mediaContainer.addSubview(adChoicesView)

        // MARK: Details
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.backgroundColor = Palette.iconBackground
        iconImageView.layer.cornerRadius = Layout.iconCornerRadius
        iconImageView.layer.masksToBounds = true
        adView.addSubview(iconImageView)

        let starsLabel = UILabel()
        starsLabel.translatesAutoresizingMaskIntoConstraints = false
        starsLabel.textAlignment = .center
        adView.addSubview(starsLabel)

        let headlineLabel = UILabel()
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        headlineLabel.textColor = .black
        headlineLabel.textAlignment = .left
        headlineLabel.numberOfLines = 1
        headlineLabel.lineBreakMode = .byTruncatingTail
        adView.addSubview(headlineLabel)

        let bodyLabel = UILabel()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        bodyLabel.textColor = Palette.body
        bodyLabel.textAlignment = .left
        bodyLabel.numberOfLines = 3
        bodyLabel.lineBreakMode = .byTruncatingTail
        adView.addSubview(bodyLabel)

        let ctaButton = GradientButton(type: .custom)
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.layer.cornerRadius = Layout.ctaHeight / 2
        ctaButton.layer.masksToBounds = true
        ctaButton.setTitleColor(.black, for: .normal)
        ctaButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        ctaButton.isUserInteractionEnabled = false // NativeAdView handles the click
        adView.addSubview(ctaButton)

        // MARK: Constraints
        // Header sits under the status bar / notch, but never closer than 20pt
        // to the top (matches the design on devices without a notch).
        let headerToSafeArea = header.topAnchor.constraint(equalTo: adView.safeAreaLayoutGuide.topAnchor)
        headerToSafeArea.priority = .defaultHigh

        var constraints: [NSLayoutConstraint] = [
            headerToSafeArea,
            header.topAnchor.constraint(greaterThanOrEqualTo: adView.topAnchor, constant: Layout.minTopInset),
            header.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: Layout.headerHeight),

            adBadge.topAnchor.constraint(equalTo: header.topAnchor, constant: Layout.badgeTop),
            adBadge.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: Layout.sideMargin),
            adBadge.widthAnchor.constraint(equalToConstant: Layout.badgeSize.width),
            adBadge.heightAnchor.constraint(equalToConstant: Layout.badgeSize.height),

            mediaContainer.topAnchor.constraint(equalTo: header.bottomAnchor),
            mediaContainer.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
            mediaContainer.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
            mediaContainer.bottomAnchor.constraint(equalTo: iconImageView.topAnchor, constant: -Layout.mediaToIcon),

            adChoicesView.topAnchor.constraint(equalTo: mediaContainer.topAnchor, constant: 4),
            adChoicesView.trailingAnchor.constraint(equalTo: mediaContainer.trailingAnchor, constant: -4),

            iconImageView.centerXAnchor.constraint(equalTo: adView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: Layout.iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: Layout.iconSize),

            starsLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: Layout.iconToStars),
            starsLabel.centerXAnchor.constraint(equalTo: adView.centerXAnchor),

            headlineLabel.topAnchor.constraint(equalTo: starsLabel.bottomAnchor, constant: Layout.starsToHeadline),
            headlineLabel.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: Layout.sideMargin),
            headlineLabel.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -Layout.sideMargin),

            bodyLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: Layout.headlineToBody),
            bodyLabel.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: Layout.sideMargin),
            bodyLabel.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -Layout.sideMargin),

            ctaButton.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: Layout.bodyToCTA),
            ctaButton.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: Layout.ctaSideMargin),
            ctaButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -Layout.ctaSideMargin),
            ctaButton.heightAnchor.constraint(equalToConstant: Layout.ctaHeight),
            ctaButton.bottomAnchor.constraint(equalTo: adView.safeAreaLayoutGuide.bottomAnchor, constant: -Layout.ctaBottom),
        ]

        // Media: centered in its region at the creative's own aspect ratio,
        // as large as fits -> full width for tall creatives, never cropped.
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

        // MARK: Register asset views
        adView.headlineView = headlineLabel
        adView.bodyView = bodyLabel
        adView.iconView = iconImageView
        adView.mediaView = mediaView
        adView.callToActionView = ctaButton
        adView.starRatingView = starsLabel
        adView.adChoicesView = adChoicesView

        // MARK: Populate
        headlineLabel.text = nativeAd.headline
        bodyLabel.text = nativeAd.body

        if let icon = nativeAd.icon?.image {
            iconImageView.image = icon
            iconImageView.isHidden = false
        } else {
            iconImageView.image = nil
        }

        // Only show a rating the advertiser actually supplied.
        if let rating = nativeAd.starRating?.doubleValue, rating > 0 {
            starsLabel.attributedText = Self.stars(for: rating)
            starsLabel.isHidden = false
        } else {
            starsLabel.attributedText = nil
            starsLabel.isHidden = true
        }

        ctaButton.setTitle("Next", for: .normal)

        mediaView.mediaContent = nativeAd.mediaContent

        adView.nativeAd = nativeAd
        return adView
    }

    private static func stars(for rating: Double) -> NSAttributedString {
        let filled = max(0, min(5, Int(rating.rounded())))
        let font = UIFont.systemFont(ofSize: 12)
        let result = NSMutableAttributedString()
        for index in 0..<5 {
            let color = index < filled ? Palette.starFilled : Palette.starEmpty
            result.append(NSAttributedString(string: "\u{2605}", attributes: [
                .font: font,
                .foregroundColor: color,
            ]))
        }
        return result
    }
}

// MediaView subclass forcing aspect-fit on the image/video subviews the SDK
// inserts, so the creative is always shown in full, never cropped.
private class FullScreenAdMediaView: MediaView {
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

// Gradient pill for the CTA — app brand gradient (#2FD1A6 -> #168EE2).
class GradientButton: UIButton {
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }

    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 0x2F/255.0, green: 0xD1/255.0, blue: 0xA6/255.0, alpha: 1).cgColor,
            UIColor(red: 0x16/255.0, green: 0x8E/255.0, blue: 0xE2/255.0, alpha: 1).cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(gradientLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
    }
}
