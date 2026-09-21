import UIKit
import GoogleMobileAds
import google_mobile_ads

class MediumNativeAdFactory: NSObject, FLTNativeAdFactory {
    func createNativeAd(_ nativeAd: NativeAd, customOptions: [AnyHashable : Any]? = nil) -> NativeAdView? {
        print("📢 [MediumNativeAdFactory] createNativeAd invoked: headline='\(nativeAd.headline ?? "N/A")', advertiser='\(nativeAd.advertiser ?? "N/A")', hasCallToAction='\(nativeAd.callToAction ?? "N/A")'")
        let nativeAdView = NativeAdView()
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

        // 2. Media View (centered landscape display)
        let mediaView = MediumAdMediaView()
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        mediaView.layer.cornerRadius = 10
        mediaView.layer.masksToBounds = true
        mediaView.backgroundColor = UIColor(red: 0xF3/255.0, green: 0xF4/255.0, blue: 0xF6/255.0, alpha: 1.0)
        mediaView.contentMode = .scaleAspectFill
        mediaView.clipsToBounds = true
        containerView.addSubview(mediaView)

        // 3. CTA Button: Solid Vibrant Blue with rounded pill shape
        let ctaButton = UIButton(type: .custom)
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.layer.cornerRadius = 23
        ctaButton.layer.masksToBounds = true
        ctaButton.backgroundColor = UIColor(red: 0x0E/255.0, green: 0x8C/255.0, blue: 0xE0/255.0, alpha: 1.0) // Solid vibrant blue #0E8CE0
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        ctaButton.isUserInteractionEnabled = false // Let GADNativeAdView handle touch events
        containerView.addSubview(ctaButton)

        // Layout Constraints
        let mediaTopConstraint = mediaView.topAnchor.constraint(equalTo: textStack.bottomAnchor, constant: 8)
        mediaTopConstraint.priority = UILayoutPriority(999)

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

            // Media View
            mediaTopConstraint,
            mediaView.topAnchor.constraint(greaterThanOrEqualTo: iconImageView.bottomAnchor, constant: 8),
            mediaView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            mediaView.bottomAnchor.constraint(equalTo: ctaButton.topAnchor, constant: -10),

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
        print("✅ [MediumNativeAdFactory] nativeAdView successfully configured and returned")
        return nativeAdView
    }
}

// MediaView subclass enforcing aspect-fill scaling on all image/video subviews to fill container edge-to-edge
private class MediumAdMediaView: MediaView {
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        applyAspectFill(to: subview)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        for subview in subviews {
            applyAspectFill(to: subview)
        }
    }

    private func applyAspectFill(to view: UIView) {
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        for child in view.subviews {
            child.contentMode = .scaleAspectFill
            child.clipsToBounds = true
        }
    }
}

// Helper gradient button kept for compatibility with FullScreenNativeAdFactory
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
            UIColor(red: 0x24/255.0, green: 0xCC/255.0, blue: 0xA7/255.0, alpha: 1.0).cgColor, // App Teal
            UIColor(red: 0x02/255.0, green: 0x88/255.0, blue: 0xD1/255.0, alpha: 1.0).cgColor  // Sky Blue
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