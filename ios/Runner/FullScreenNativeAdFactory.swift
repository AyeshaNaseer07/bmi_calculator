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

        // 1. Top Section: Media Container (takes ~68% of screen)
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

        let adChoicesView = AdChoicesView()
        adChoicesView.translatesAutoresizingMaskIntoConstraints = false
        topMediaContainer.addSubview(adChoicesView)

        let adBadge = UILabel()
        adBadge.translatesAutoresizingMaskIntoConstraints = false
        adBadge.text = "AD"
        adBadge.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        adBadge.textColor = .white
        adBadge.backgroundColor = UIColor(red: 0x24/255.0, green: 0xCC/255.0, blue: 0xA7/255.0, alpha: 1.0) // App Teal
        adBadge.textAlignment = .center
        adBadge.layer.cornerRadius = 4
        adBadge.layer.masksToBounds = true
        topMediaContainer.addSubview(adBadge)

        // 2. Bottom Section: Details & CTA (takes ~32% of screen)
        let bottomCard = UIView()
        bottomCard.translatesAutoresizingMaskIntoConstraints = false
        bottomCard.backgroundColor = .white
        bottomCard.clipsToBounds = true
        nativeAdView.addSubview(bottomCard)

        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.layer.cornerRadius = 12
        iconImageView.layer.masksToBounds = true
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        bottomCard.addSubview(iconImageView)

        let textStack = UIStackView()
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 3
        textStack.alignment = .fill
        textStack.distribution = .fill
        bottomCard.addSubview(textStack)

        let headlineLabel = UILabel()
        headlineLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        headlineLabel.textColor = UIColor(red: 0x1A/255.0, green: 0x25/255.0, blue: 0x2C/255.0, alpha: 1.0)
        headlineLabel.numberOfLines = 1
        headlineLabel.lineBreakMode = .byTruncatingTail
        textStack.addArrangedSubview(headlineLabel)

        // VERIFIED: Stars Rating Stack
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
        bodyLabel.numberOfLines = 2
        bodyLabel.lineBreakMode = .byTruncatingTail
        textStack.addArrangedSubview(bodyLabel)

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
            // Top Media Container (occupies top 68% of view)
            topMediaContainer.topAnchor.constraint(equalTo: nativeAdView.topAnchor),
            topMediaContainer.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor),
            topMediaContainer.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor),
            topMediaContainer.heightAnchor.constraint(equalTo: nativeAdView.heightAnchor, multiplier: 0.68),

            // AdChoices View (safe from notch and screen corners)
            adChoicesView.topAnchor.constraint(equalTo: topMediaContainer.safeAreaLayoutGuide.topAnchor, constant: 14),
            adChoicesView.trailingAnchor.constraint(equalTo: topMediaContainer.trailingAnchor, constant: -16),
            adChoicesView.widthAnchor.constraint(greaterThanOrEqualToConstant: 16),
            adChoicesView.heightAnchor.constraint(equalToConstant: 18),

            // AD Badge to the left of AdChoices
            adBadge.centerYAnchor.constraint(equalTo: adChoicesView.centerYAnchor),
            adBadge.trailingAnchor.constraint(equalTo: adChoicesView.leadingAnchor, constant: -8),
            adBadge.widthAnchor.constraint(equalToConstant: 32),
            adBadge.heightAnchor.constraint(equalToConstant: 18),

            // Media View centered inside top container
            mediaView.topAnchor.constraint(equalTo: topMediaContainer.topAnchor),
            mediaView.leadingAnchor.constraint(equalTo: topMediaContainer.leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: topMediaContainer.trailingAnchor),
            mediaView.bottomAnchor.constraint(equalTo: topMediaContainer.bottomAnchor),

            // Bottom Card below media
            bottomCard.topAnchor.constraint(equalTo: topMediaContainer.bottomAnchor),
            bottomCard.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor),
            bottomCard.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor),
            bottomCard.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor),

            // Icon inside bottom card
            iconImageView.topAnchor.constraint(equalTo: bottomCard.topAnchor, constant: 16),
            iconImageView.leadingAnchor.constraint(equalTo: bottomCard.leadingAnchor, constant: 20),
            iconImageView.widthAnchor.constraint(equalToConstant: 48),
            iconImageView.heightAnchor.constraint(equalToConstant: 48),

            // Text Stack inside bottom card
            textStack.topAnchor.constraint(equalTo: bottomCard.topAnchor, constant: 14),
            textStack.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: bottomCard.trailingAnchor, constant: -20),

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
        nativeAdView.adChoicesView = adChoicesView

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