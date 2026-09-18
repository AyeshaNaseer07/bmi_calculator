import UIKit
import GoogleMobileAds
import google_mobile_ads

class MediumNativeAdFactory: NSObject, FLTNativeAdFactory {
    func createNativeAd(_ nativeAd: NativeAd, customOptions: [AnyHashable : Any]? = nil) -> NativeAdView? {
        print("📢 [MediumNativeAdFactory] createNativeAd invoked: headline='\(nativeAd.headline ?? "N/A")', advertiser='\(nativeAd.advertiser ?? "N/A")', hasCallToAction='\(nativeAd.callToAction ?? "N/A")'")
        let nativeAdView = NativeAdView()
        nativeAdView.backgroundColor = .white
        nativeAdView.layer.cornerRadius = 18
        nativeAdView.clipsToBounds = true
        nativeAdView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Card Container with 14pt horizontal and 12pt vertical padding
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.clipsToBounds = true
        nativeAdView.addSubview(containerView)

        // 1. Top Row: Icon, Headline/Body Stack, AD Badge & AdChoices View
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.layer.cornerRadius = 10
        iconImageView.layer.masksToBounds = true
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        containerView.addSubview(iconImageView)

        // AdChoices View (explicitly managed so it never gets clipped by the card's corner radius)
        let adChoicesView = AdChoicesView()
        adChoicesView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(adChoicesView)

        let adBadge = UILabel()
        adBadge.translatesAutoresizingMaskIntoConstraints = false
        adBadge.text = "AD"
        adBadge.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        adBadge.textColor = .white
        adBadge.backgroundColor = UIColor(red: 0x24/255.0, green: 0xCC/255.0, blue: 0xA7/255.0, alpha: 1.0) // App Teal
        adBadge.textAlignment = .center
        adBadge.layer.cornerRadius = 3
        adBadge.layer.masksToBounds = true
        containerView.addSubview(adBadge)

        let textStack = UIStackView()
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.alignment = .fill
        textStack.distribution = .fill
        containerView.addSubview(textStack)

        let headlineLabel = UILabel()
        headlineLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        headlineLabel.textColor = UIColor(red: 0x1A/255.0, green: 0x25/255.0, blue: 0x2C/255.0, alpha: 1.0)
        headlineLabel.numberOfLines = 1
        headlineLabel.lineBreakMode = .byTruncatingTail
        textStack.addArrangedSubview(headlineLabel)

        // Stars Rating Stack
        let starsStack = UIStackView()
        starsStack.axis = .horizontal
        starsStack.spacing = 2
        starsStack.alignment = .center
        starsStack.distribution = .fillEqually
        textStack.addArrangedSubview(starsStack)

        let starRating = nativeAd.starRating?.doubleValue ?? 4.5
        let fullStars = Int(starRating.rounded())
        for _ in 0..<fullStars {
            let starLabel = UILabel()
            starLabel.text = "★"
            starLabel.textColor = UIColor(red: 0xFA/255.0, green: 0xB0/255.0, blue: 0x05/255.0, alpha: 1.0) // Gold
            starLabel.font = UIFont.systemFont(ofSize: 12)
            starsStack.addArrangedSubview(starLabel)
        }
        for _ in fullStars..<5 {
            let starLabel = UILabel()
            starLabel.text = "★"
            starLabel.textColor = UIColor(white: 0.85, alpha: 1.0)
            starLabel.font = UIFont.systemFont(ofSize: 12)
            starsStack.addArrangedSubview(starLabel)
        }

        let bodyLabel = UILabel()
        bodyLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        bodyLabel.textColor = UIColor(red: 0x7A/255.0, green: 0x8B/255.0, blue: 0x94/255.0, alpha: 1.0)
        bodyLabel.numberOfLines = 1
        bodyLabel.lineBreakMode = .byTruncatingTail
        textStack.addArrangedSubview(bodyLabel)

        // 2. Media View (scales media to aspect-fit within the container without cropping or distortion)
        let mediaView = MediumAdMediaView()
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        mediaView.layer.cornerRadius = 12
        mediaView.layer.masksToBounds = true
        mediaView.backgroundColor = UIColor(red: 0xF5/255.0, green: 0xF7/255.0, blue: 0xF8/255.0, alpha: 1.0)
        mediaView.contentMode = .scaleAspectFill
        mediaView.clipsToBounds = true
        containerView.addSubview(mediaView)

        // 3. CTA Button with Gradient
        let ctaButton = GradientButton(type: .custom)
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.layer.cornerRadius = 22
        ctaButton.layer.masksToBounds = true
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        ctaButton.isUserInteractionEnabled = false // Let GADNativeAdView handle touch events
        containerView.addSubview(ctaButton)

        // Layout Constraints
        let mediaTopConstraint = mediaView.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8)
        mediaTopConstraint.priority = UILayoutPriority(750)

        NSLayoutConstraint.activate([
            // Container edges pinned to nativeAdView bounds with 14pt leading/trailing and 12pt top/bottom
            containerView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 12),
            containerView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 14),
            containerView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -14),
            containerView.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor, constant: -12),

            // Icon
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 42),
            iconImageView.heightAnchor.constraint(equalToConstant: 42),

            // AdChoices View (pinned safely to top-trailing of containerView, completely inside corner curve)
            adChoicesView.topAnchor.constraint(equalTo: containerView.topAnchor),
            adChoicesView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            adChoicesView.widthAnchor.constraint(greaterThanOrEqualToConstant: 16),
            adChoicesView.heightAnchor.constraint(equalToConstant: 16),

            // AD Badge (placed neatly to the left of AdChoices)
            adBadge.centerYAnchor.constraint(equalTo: adChoicesView.centerYAnchor),
            adBadge.trailingAnchor.constraint(equalTo: adChoicesView.leadingAnchor, constant: -6),
            adBadge.widthAnchor.constraint(equalToConstant: 24),
            adBadge.heightAnchor.constraint(equalToConstant: 15),

            // Text Stack (occupies space between icon and AD badge)
            textStack.topAnchor.constraint(equalTo: containerView.topAnchor),
            textStack.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: adBadge.leadingAnchor, constant: -6),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: mediaView.topAnchor, constant: -4),

            // Media View (flexibly fills space between top header and CTA button)
            mediaTopConstraint,
            mediaView.topAnchor.constraint(greaterThanOrEqualTo: iconImageView.bottomAnchor, constant: 8),
            mediaView.topAnchor.constraint(greaterThanOrEqualTo: textStack.bottomAnchor, constant: 6),
            mediaView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            mediaView.bottomAnchor.constraint(equalTo: ctaButton.topAnchor, constant: -8),

            // CTA Button pinned to bottom of container
            ctaButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            ctaButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            ctaButton.heightAnchor.constraint(equalToConstant: 42),
            ctaButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        // Register views to GADNativeAdView
        nativeAdView.headlineView = headlineLabel
        nativeAdView.bodyView = bodyLabel
        nativeAdView.iconView = iconImageView
        nativeAdView.mediaView = mediaView
        nativeAdView.callToActionView = ctaButton
        nativeAdView.starRatingView = starsStack
        nativeAdView.adChoicesView = adChoicesView

        // Populate Native Ad Content
        headlineLabel.text = nativeAd.headline
        bodyLabel.text = nativeAd.body

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

// Helper gradient button matching the Onboarding Next button styling
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