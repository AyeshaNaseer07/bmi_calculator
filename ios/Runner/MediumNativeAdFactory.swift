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

        // Card Container with padding
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.clipsToBounds = true
        nativeAdView.addSubview(containerView)

        // 1. Top Row: Icon, Headline/Body Stack, AD Badge
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.layer.cornerRadius = 10
        iconImageView.layer.masksToBounds = true
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        containerView.addSubview(iconImageView)

        let adBadge = UILabel()
        adBadge.translatesAutoresizingMaskIntoConstraints = false
        adBadge.text = "AD"
        adBadge.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        adBadge.textColor = .white
        adBadge.backgroundColor = UIColor(red: 0x24/255.0, green: 0xCC/255.0, blue: 0xA7/255.0, alpha: 1.0) // App Teal
        adBadge.textAlignment = .center
        adBadge.layer.cornerRadius = 4
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
        headlineLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        headlineLabel.textColor = UIColor(red: 0x1A/255.0, green: 0x25/255.0, blue: 0x2C/255.0, alpha: 1.0)
        headlineLabel.numberOfLines = 1
        headlineLabel.lineBreakMode = .byTruncatingTail
        textStack.addArrangedSubview(headlineLabel)

        // ADDED: Stars Rating Stack
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
            starLabel.font = UIFont.systemFont(ofSize: 13)
            starsStack.addArrangedSubview(starLabel)
        }
        for _ in fullStars..<5 {
            let starLabel = UILabel()
            starLabel.text = "★"
            starLabel.textColor = UIColor(white: 0.85, alpha: 1.0)
            starLabel.font = UIFont.systemFont(ofSize: 13)
            starsStack.addArrangedSubview(starLabel)
        }

        let bodyLabel = UILabel()
        bodyLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        bodyLabel.textColor = UIColor(red: 0x7A/255.0, green: 0x8B/255.0, blue: 0x94/255.0, alpha: 1.0)
        bodyLabel.numberOfLines = 1
        bodyLabel.lineBreakMode = .byTruncatingTail
        textStack.addArrangedSubview(bodyLabel)

        // 2. Media View
        let mediaView = MediaView()
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        mediaView.layer.cornerRadius = 14
        mediaView.layer.masksToBounds = true
        mediaView.backgroundColor = UIColor(red: 0xEE/255.0, green: 0xF2/255.0, blue: 0xF2/255.0, alpha: 1.0)
        mediaView.contentMode = .scaleAspectFill
        mediaView.clipsToBounds = true
        containerView.addSubview(mediaView)

        // 3. CTA Button with Gradient
        let ctaButton = GradientButton(type: .custom)
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.layer.cornerRadius = 23
        ctaButton.layer.masksToBounds = true
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        ctaButton.isUserInteractionEnabled = false // Let GADNativeAdView handle touch events
        containerView.addSubview(ctaButton)

        // Constraints
        NSLayoutConstraint.activate([
            // Container edges pinned to nativeAdView bounds
            containerView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 10),
            containerView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -12),
            containerView.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor, constant: -10),

            // Icon
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 44),
            iconImageView.heightAnchor.constraint(equalToConstant: 44),

            // AD Badge
            adBadge.topAnchor.constraint(equalTo: containerView.topAnchor),
            adBadge.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            adBadge.widthAnchor.constraint(equalToConstant: 30),
            adBadge.heightAnchor.constraint(equalToConstant: 18),

            // Text Stack
            textStack.topAnchor.constraint(equalTo: containerView.topAnchor),
            textStack.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
            textStack.trailingAnchor.constraint(equalTo: adBadge.leadingAnchor, constant: -8),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: iconImageView.bottomAnchor),

            // Media View (flexibly fills space between icon row and CTA button)
            mediaView.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8),
            mediaView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            mediaView.bottomAnchor.constraint(equalTo: ctaButton.topAnchor, constant: -8),

            // CTA Button pinned to bottom of container
            ctaButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            ctaButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            ctaButton.heightAnchor.constraint(equalToConstant: 44),
            ctaButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        // Register views to GADNativeAdView
        nativeAdView.headlineView = headlineLabel
        nativeAdView.bodyView = bodyLabel
        nativeAdView.iconView = iconImageView
        nativeAdView.mediaView = mediaView
        nativeAdView.callToActionView = ctaButton
        nativeAdView.starRatingView = starsStack

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