import UIKit
import Flutter
import GoogleMobileAds
import google_mobile_ads

class MediumNativeAdFactory: NSObject, FLTNativeAdFactory {
    func createNativeAd(_ nativeAd: NativeAd, customOptions: [AnyHashable : Any]? = nil) -> NativeAdView? {
        print("📢 [MediumNativeAdFactory] createNativeAd invoked: headline='\(nativeAd.headline ?? "N/A")', advertiser='\(nativeAd.advertiser ?? "N/A")', hasCallToAction='\(nativeAd.callToAction ?? "N/A")'")
        let nativeAdView = NativeAdView(frame: CGRect(x: 0, y: 0, width: 375, height: 350))
        nativeAdView.backgroundColor = .white
        nativeAdView.layer.cornerRadius = 16
        nativeAdView.clipsToBounds = true
        nativeAdView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Main content container with margins
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.clipsToBounds = true
        nativeAdView.addSubview(containerView)

        // 1. Icon ImageView (left)
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.layer.cornerRadius = 10
        iconImageView.layer.masksToBounds = true
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        containerView.addSubview(iconImageView)

        // AdChoices View (top trailing corner)
        let adChoicesView = AdChoicesView()
        adChoicesView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(adChoicesView)

        // Text Stack: Headline on line 1, [AD] badge + Body on line 2
        let textStack = UIStackView()
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 3
        textStack.alignment = .fill
        textStack.distribution = .fill
        containerView.addSubview(textStack)

        let headlineLabel = UILabel()
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        headlineLabel.textColor = UIColor(red: 0x1A/255.0, green: 0x20/255.0, blue: 0x2C/255.0, alpha: 1.0)
        headlineLabel.numberOfLines = 1
        headlineLabel.lineBreakMode = .byTruncatingTail
        textStack.addArrangedSubview(headlineLabel)

        // Body Row: [AD] outline badge + bodyLabel next to it
        let bodyRow = UIStackView()
        bodyRow.translatesAutoresizingMaskIntoConstraints = false
        bodyRow.axis = .horizontal
        bodyRow.alignment = .top
        bodyRow.spacing = 6
        bodyRow.distribution = .fill

        let adBadge = UILabel()
        adBadge.translatesAutoresizingMaskIntoConstraints = false
        adBadge.text = "AD"
        adBadge.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        adBadge.textColor = UIColor(white: 0.50, alpha: 1.0)
        adBadge.backgroundColor = .clear
        adBadge.textAlignment = .center
        adBadge.layer.borderColor = UIColor(white: 0.75, alpha: 1.0).cgColor
        adBadge.layer.borderWidth = 1.0
        adBadge.layer.cornerRadius = 3.5
        adBadge.layer.masksToBounds = true
        adBadge.setContentHuggingPriority(.required, for: .horizontal)
        adBadge.setContentCompressionResistancePriority(.required, for: .horizontal)
        bodyRow.addArrangedSubview(adBadge)

        let bodyLabel = UILabel()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        bodyLabel.textColor = UIColor(red: 0x6B/255.0, green: 0x72/255.0, blue: 0x80/255.0, alpha: 1.0)
        bodyLabel.numberOfLines = 2
        bodyLabel.lineBreakMode = .byTruncatingTail
        bodyRow.addArrangedSubview(bodyLabel)

        textStack.addArrangedSubview(bodyRow)

        // 2. Media View (centered landscape display) - FILLS EDGE TO EDGE
        let mediaView = MediumAdMediaView()
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        mediaView.layer.cornerRadius = 12
        mediaView.layer.masksToBounds = true
        mediaView.backgroundColor = UIColor(red: 0xF3/255.0, green: 0xF4/255.0, blue: 0xF6/255.0, alpha: 1.0)
        mediaView.contentMode = .scaleAspectFill
        mediaView.clipsToBounds = true
        mediaView.setContentHuggingPriority(UILayoutPriority(240), for: .vertical)
        mediaView.setContentCompressionResistancePriority(UILayoutPriority(240), for: .vertical)
        containerView.addSubview(mediaView)

        // 3. CTA Button: Using btn.webp asset from Flutter
        let ctaButton = CTAImageButton(type: .custom)
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.layer.cornerRadius = 23
        ctaButton.layer.masksToBounds = true
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        ctaButton.isUserInteractionEnabled = false // Let GADNativeAdView handle touch events
        containerView.addSubview(ctaButton)

        NSLayoutConstraint.activate([
            // Container edges inside nativeAdView
            containerView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 12),
            containerView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 14),
            containerView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -14),
            containerView.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor, constant: -12),

            // Icon
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 46),
            iconImageView.heightAnchor.constraint(equalToConstant: 46),

            // AdChoices View (top trailing)
            adChoicesView.topAnchor.constraint(equalTo: containerView.topAnchor),
            adChoicesView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            adChoicesView.widthAnchor.constraint(greaterThanOrEqualToConstant: 16),
            adChoicesView.heightAnchor.constraint(equalToConstant: 16),

            // AD Badge size
            adBadge.widthAnchor.constraint(equalToConstant: 24),
            adBadge.heightAnchor.constraint(equalToConstant: 15),

            // Text Stack (between icon and AdChoices)
            textStack.topAnchor.constraint(equalTo: containerView.topAnchor),
            textStack.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: adChoicesView.leadingAnchor, constant: -6),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: mediaView.topAnchor, constant: -8),

            // Media View - EDGE TO EDGE (NO SIDE PADDING)
            mediaView.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 10),
            mediaView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
            mediaView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0),
            mediaView.bottomAnchor.constraint(equalTo: ctaButton.topAnchor, constant: -8),

            // CTA Button pinned to bottom
            ctaButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            ctaButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            ctaButton.heightAnchor.constraint(equalToConstant: 46),
            ctaButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        // Register views to GADNativeAdView
        nativeAdView.headlineView = headlineLabel
        nativeAdView.bodyView = bodyLabel
        nativeAdView.iconView = iconImageView
        nativeAdView.mediaView = mediaView
        nativeAdView.callToActionView = ctaButton
        nativeAdView.adChoicesView = adChoicesView

        // Populate Native Ad Content
        headlineLabel.text = nativeAd.headline
        bodyLabel.text = nativeAd.body ?? nativeAd.advertiser ?? ""

        if let icon = nativeAd.icon?.image {
            iconImageView.image = icon
            iconImageView.isHidden = false
        } else {
            iconImageView.isHidden = true
        }

        if let cta = nativeAd.callToAction, !cta.isEmpty {
            ctaButton.setTitle(cta, for: .normal)
        } else {
            ctaButton.setTitle("Install", for: .normal)
        }

        mediaView.mediaContent = nativeAd.mediaContent

        nativeAdView.nativeAd = nativeAd
        nativeAdView.layoutIfNeeded()
        print("✅ [MediumNativeAdFactory] nativeAdView successfully configured and returned")
        return nativeAdView
    }
}

// MediaView subclass enforcing aspect-fit scaling so media is never cropped from top or bottom
private class MediumAdMediaView: MediaView {
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

// CTA Button rendering btn.webp asset from Flutter
class CTAImageButton: UIButton {
    private let backgroundImageView = UIImageView()
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackground()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBackground()
    }

    private func setupBackground() {
        clipsToBounds = true
        layer.cornerRadius = 23

        // Gradient Layer fallback matching the solid blue button color (#2B87E8)
        gradientLayer.colors = [
            UIColor(red: 0x2B/255.0, green: 0x87/255.0, blue: 0xE8/255.0, alpha: 1.0).cgColor,
            UIColor(red: 0x2B/255.0, green: 0x87/255.0, blue: 0xE8/255.0, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(gradientLayer, at: 0)

        // Background Image View for btn.webp
        backgroundImageView.contentMode = .scaleToFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundImageView)
        sendSubviewToBack(backgroundImageView)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        // Load btn.webp from Flutter assets
        let assetKey = FlutterDartProject.lookupKey(forAsset: "assets/images/btn.webp")
        if let path = Bundle.main.path(forResource: assetKey, ofType: nil),
           let img = UIImage(contentsOfFile: path) {
            backgroundImageView.image = img
            gradientLayer.isHidden = true
        } else if let img = UIImage(named: "btn.webp") ?? UIImage(named: "btn") {
            backgroundImageView.image = img
            gradientLayer.isHidden = true
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
        backgroundImageView.layer.cornerRadius = layer.cornerRadius
    }
}
