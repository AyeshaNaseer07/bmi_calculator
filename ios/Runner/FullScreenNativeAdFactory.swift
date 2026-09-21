import UIKit
import GoogleMobileAds
import google_mobile_ads

class FullScreenNativeAdFactory: NSObject, FLTNativeAdFactory {
    func createNativeAd(_ nativeAd: NativeAd, customOptions: [AnyHashable : Any]? = nil) -> NativeAdView? {
        print("📢 [FullScreenNativeAdFactory] createNativeAd invoked: headline='\(nativeAd.headline ?? "N/A")', advertiser='\(nativeAd.advertiser ?? "N/A")', hasCallToAction='\(nativeAd.callToAction ?? "N/A")'")
        let nativeAdView = NativeAdView()
        nativeAdView.backgroundColor = .white
        nativeAdView.clipsToBounds = true
        nativeAdView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // 1. Top Section: Media Container (takes ~65% of screen)
        let topMediaContainer = UIView()
        topMediaContainer.translatesAutoresizingMaskIntoConstraints = false
        topMediaContainer.backgroundColor = UIColor(red: 0xEE/255.0, green: 0xF0/255.0, blue: 0xF0/255.0, alpha: 1.0)
        topMediaContainer.clipsToBounds = true
        nativeAdView.addSubview(topMediaContainer)

        let mediaView = FullScreenAdMediaView()
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        mediaView.contentMode = .scaleAspectFill
        mediaView.clipsToBounds = true
        topMediaContainer.addSubview(mediaView)

        // AD Badge - Top Left
        let adBadge = UILabel()
        adBadge.translatesAutoresizingMaskIntoConstraints = false
        adBadge.text = "AD"
        adBadge.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        adBadge.textColor = .white
        adBadge.backgroundColor = UIColor(red: 0x1B/255.0, green: 0xD7/255.0, blue: 0x76/255.0, alpha: 1.0) // Bright Teal
        adBadge.textAlignment = .center
        adBadge.layer.cornerRadius = 4
        adBadge.layer.masksToBounds = true
        topMediaContainer.addSubview(adBadge)

        // Close Button - Top Right (Gray circle with X)
        let closeButton = UIButton(type: .system)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.backgroundColor = UIColor(white: 0.5, alpha: 0.7)
        closeButton.layer.cornerRadius = 16
        closeButton.layer.masksToBounds = true
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .white
        closeButton.isUserInteractionEnabled = false // Let GADNativeAdView handle
        topMediaContainer.addSubview(closeButton)

        // 2. Bottom Section: Details & CTA (takes ~35% of screen)
        let bottomCard = UIView()
        bottomCard.translatesAutoresizingMaskIntoConstraints = false
        bottomCard.backgroundColor = .white
        bottomCard.clipsToBounds = true
        nativeAdView.addSubview(bottomCard)

        // Icon ImageView - Centered
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.layer.cornerRadius = 28
        iconImageView.layer.masksToBounds = true
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.backgroundColor = UIColor(red: 0xF5/255.0, green: 0xF5/255.0, blue: 0xF5/255.0, alpha: 1.0)
        bottomCard.addSubview(iconImageView)

        // Headline Label
        let headlineLabel = UILabel()
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        headlineLabel.textColor = UIColor(red: 0x1A/255.0, green: 0x25/255.0, blue: 0x2C/255.0, alpha: 1.0)
        headlineLabel.numberOfLines = 1
        headlineLabel.lineBreakMode = .byTruncatingTail
        headlineLabel.textAlignment = .center
        bottomCard.addSubview(headlineLabel)

        // VERIFIED: Stars Rating Stack
        let starsStack = UIStackView()
        starsStack.translatesAutoresizingMaskIntoConstraints = false
        starsStack.axis = .horizontal
        starsStack.spacing = 2
        starsStack.alignment = .center
        starsStack.distribution = .fillEqually
        bottomCard.addSubview(starsStack)

        let starRating = nativeAd.starRating?.doubleValue ?? 4.0
        let fullStars = Int(starRating)
        for _ in 0..<fullStars {
            let starLabel = UILabel()
            starLabel.text = "★"
            starLabel.textColor = UIColor(red: 0xFA/255.0, green: 0xB0/255.0, blue: 0x05/255.0, alpha: 1.0) // Gold
            starLabel.font = UIFont.systemFont(ofSize: 14)
            starsStack.addArrangedSubview(starLabel)
        }
        for _ in fullStars..<5 {
            let starLabel = UILabel()
            starLabel.text = "★"
            starLabel.textColor = UIColor(white: 0.88, alpha: 1.0)
            starLabel.font = UIFont.systemFont(ofSize: 14)
            starsStack.addArrangedSubview(starLabel)
        }

        // Body Label
        let bodyLabel = UILabel()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        bodyLabel.textColor = UIColor(red: 0x5F/255.0, green: 0x6B/255.0, blue: 0x78/255.0, alpha: 1.0)
        bodyLabel.numberOfLines = 3
        bodyLabel.lineBreakMode = .byTruncatingTail
        bodyLabel.textAlignment = .center
        bottomCard.addSubview(bodyLabel)

        // Gradient Install Button
        let ctaButton = GradientButton(type: .custom)
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.layer.cornerRadius = 24
        ctaButton.layer.masksToBounds = true
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        ctaButton.isUserInteractionEnabled = false
        bottomCard.addSubview(ctaButton)

        // Constraints
        NSLayoutConstraint.activate([
            // Top Media Container (occupies top 65% of view)
            topMediaContainer.topAnchor.constraint(equalTo: nativeAdView.topAnchor),
            topMediaContainer.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor),
            topMediaContainer.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor),
            topMediaContainer.heightAnchor.constraint(equalTo: nativeAdView.heightAnchor, multiplier: 0.65),

            // Media View fills entire top container
            mediaView.topAnchor.constraint(equalTo: topMediaContainer.topAnchor),
            mediaView.leadingAnchor.constraint(equalTo: topMediaContainer.leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: topMediaContainer.trailingAnchor),
            mediaView.bottomAnchor.constraint(equalTo: topMediaContainer.bottomAnchor),

            // AD Badge - Top Left
            adBadge.topAnchor.constraint(equalTo: topMediaContainer.topAnchor, constant: 12),
            adBadge.leadingAnchor.constraint(equalTo: topMediaContainer.leadingAnchor, constant: 12),
            adBadge.widthAnchor.constraint(equalToConstant: 36),
            adBadge.heightAnchor.constraint(equalToConstant: 24),

            // Close Button - Top Right
            closeButton.topAnchor.constraint(equalTo: topMediaContainer.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: topMediaContainer.trailingAnchor, constant: -12),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),

            // Bottom Card below media
            bottomCard.topAnchor.constraint(equalTo: topMediaContainer.bottomAnchor),
            bottomCard.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor),
            bottomCard.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor),
            bottomCard.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor),

            // Icon centered at top of bottom card
            iconImageView.topAnchor.constraint(equalTo: bottomCard.topAnchor, constant: 16),
            iconImageView.centerXAnchor.constraint(equalTo: bottomCard.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 56),
            iconImageView.heightAnchor.constraint(equalToConstant: 56),

            // Headline centered below icon
            headlineLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 12),
            headlineLabel.leadingAnchor.constraint(equalTo: bottomCard.leadingAnchor, constant: 16),
            headlineLabel.trailingAnchor.constraint(equalTo: bottomCard.trailingAnchor, constant: -16),

            // Stars centered below headline
            starsStack.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 6),
            starsStack.centerXAnchor.constraint(equalTo: bottomCard.centerXAnchor),
            starsStack.widthAnchor.constraint(equalToConstant: 85),

            // Body text centered below stars
            bodyLabel.topAnchor.constraint(equalTo: starsStack.bottomAnchor, constant: 6),
            bodyLabel.leadingAnchor.constraint(equalTo: bottomCard.leadingAnchor, constant: 16),
            bodyLabel.trailingAnchor.constraint(equalTo: bottomCard.trailingAnchor, constant: -16),

            // CTA Button at bottom
            ctaButton.leadingAnchor.constraint(equalTo: bottomCard.leadingAnchor, constant: 20),
            ctaButton.trailingAnchor.constraint(equalTo: bottomCard.trailingAnchor, constant: -20),
            ctaButton.heightAnchor.constraint(equalToConstant: 48),
            ctaButton.bottomAnchor.constraint(equalTo: bottomCard.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        // Register views
        nativeAdView.headlineView = headlineLabel
        nativeAdView.bodyView = bodyLabel
        nativeAdView.iconView = iconImageView
        nativeAdView.mediaView = mediaView
        nativeAdView.callToActionView = ctaButton
        nativeAdView.starRatingView = starsStack

        // Populate content
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
        print("✅ [FullScreenNativeAdFactory] nativeAdView successfully configured and returned")
        return nativeAdView
    }
}

// MediaView subclass enforcing aspect-fill scaling on all image/video subviews to fill container edge-to-edge
private class FullScreenAdMediaView: MediaView {
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

// Gradient button for CTA
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