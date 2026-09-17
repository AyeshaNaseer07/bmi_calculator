import UIKit
import GoogleMobileAds
import google_mobile_ads

class MediumNativeAdFactory: NSObject, FLTNativeAdFactory {
    func createNativeAd(_ nativeAd: NativeAd, customOptions: [AnyHashable : Any]? = nil) -> NativeAdView? {
        let nativeAdView = NativeAdView()
        nativeAdView.backgroundColor = .white
        nativeAdView.layer.cornerRadius = 18
        nativeAdView.layer.masksToBounds = true
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false

        // Card Container with padding
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
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
        textStack.alignment = .leading
        textStack.distribution = .fill
        containerView.addSubview(textStack)

        let headlineLabel = UILabel()
        headlineLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        headlineLabel.textColor = UIColor(red: 0x1A/255.0, green: 0x25/255.0, blue: 0x2C/255.0, alpha: 1.0)
        headlineLabel.numberOfLines = 1
        textStack.addArrangedSubview(headlineLabel)

        let bodyLabel = UILabel()
        bodyLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        bodyLabel.textColor = UIColor(red: 0x7A/255.0, green: 0x8B/255.0, blue: 0x94/255.0, alpha: 1.0)
        bodyLabel.numberOfLines = 2
        bodyLabel.lineBreakMode = .byTruncatingTail
        textStack.addArrangedSubview(bodyLabel)

        // 2. Media View
        let mediaView = MediaView()
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        mediaView.layer.cornerRadius = 14
        mediaView.layer.masksToBounds = true
        mediaView.backgroundColor = UIColor(red: 0xEE/255.0, green: 0xF2/255.0, blue: 0xF2/255.0, alpha: 1.0)
        mediaView.contentMode = .scaleAspectFill
        containerView.addSubview(mediaView)

        // 3. CTA Button
        let ctaButton = UIButton(type: .custom)
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.layer.cornerRadius = 23
        ctaButton.layer.masksToBounds = true
        ctaButton.backgroundColor = UIColor(red: 0x02/255.0, green: 0x88/255.0, blue: 0xD1/255.0, alpha: 1.0) // Blue Pill
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        ctaButton.isUserInteractionEnabled = false // Let GADNativeAdView handle touch events
        containerView.addSubview(ctaButton)

        // Constraints
        NSLayoutConstraint.activate([
            // Container edges
            containerView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 12),
            containerView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -12),
            containerView.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor, constant: -12),

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

            // Media View
            mediaView.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 10),
            mediaView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            mediaView.heightAnchor.constraint(equalToConstant: 136),

            // CTA Button
            ctaButton.topAnchor.constraint(equalTo: mediaView.bottomAnchor, constant: 10),
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
        return nativeAdView
    }
}
