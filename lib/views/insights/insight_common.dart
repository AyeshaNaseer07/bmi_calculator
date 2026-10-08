import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/constants/app_assets.dart';
import '../widgets/app_background.dart';

const Color kInk = Color(0xFF111B2E);
const Color kGreen = Color(0xFF09B389);
const Color kGreenDark = Color(0xFF006B4E);
const Color kMuted = Color(0xFF6B7280);
const Color kMintBorder = Color(0xFFD5F2E8);
const Color kMintBg = Color(0xFFE6F8F1);
const String kHeadFont = 'Plus Jakarta Sans';

TextStyle headStyle(
  double size, {
  Color color = kInk,
  FontWeight weight = FontWeight.w800,
}) => TextStyle(
  fontSize: size.sp,
  fontFamily: kHeadFont,
  fontWeight: weight,
  color: color,
);

TextStyle bodyStyle(
  double size, {
  Color color = kMuted,
  FontWeight weight = FontWeight.w400,
  double? height,
}) => TextStyle(
  fontSize: size.sp,
  fontFamily: 'Inter',
  fontWeight: weight,
  color: color,
  height: height,
);

/// White rounded card with the soft mint border/shadow used on every screen.
class InsightCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color? color;
  final Color? borderColor;
  final Color? shadowColor;
  final VoidCallback? onTap;

  const InsightCard({
    super.key,
    required this.child,
    this.padding,
    this.radius = 18,
    this.color,
    this.borderColor,
    this.shadowColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        shadows: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: card,
    );
  }
}

/// Shows [asset] when the file exists, otherwise a soft placeholder, so
/// screens look right now and pick the real photo up as soon as it is added.
class AssetOrPlaceholder extends StatelessWidget {
  final String asset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double radius;
  final bool circle;
  final IconData icon;

  const AssetOrPlaceholder({
    super.key,
    required this.asset,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = 16,
    this.circle = false,
    this.icon = Icons.restaurant_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEAF9F3), Color(0xFFCDEFE2)],
          ),
        ),
        child: Icon(
          icon,
          color: kGreen.withValues(alpha: 0.55),
          size: ((width ?? height ?? 60) * 0.38).clamp(18.0, 60.0),
        ),
      ),
    );
    if (circle) return ClipOval(child: image);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius.r),
      child: image,
    );
  }
}

/// Back button + centred title, used by all the tip screens.
class InsightHeader extends StatelessWidget {
  final String title;
  final IconData? titleIcon;

  const InsightHeader({super.key, required this.title, this.titleIcon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 10.h),
      child: SizedBox(
        height: 44.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Get.back(),
                child: Image.asset(
                  AppAssets.insightBackIcon,
                  height: 36.h,
                  width: 36.w,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.w),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xFF141B2B),
                    fontSize: 26,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    height: 1.08,
                    letterSpacing: -0.55,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Page frame: app background, header, scrollable body.
class InsightScaffold extends StatelessWidget {
  final String title;
  final IconData? titleIcon;
  final Widget body;
  final Widget? bottom;

  const InsightScaffold({
    super.key,
    required this.title,
    required this.body,
    this.titleIcon,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              InsightHeader(title: title, titleIcon: titleIcon),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                  child: body,
                ),
              ),
              if (bottom != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                  child: bottom,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: 6.h, bottom: 10.h),
    child: Text(text, style: headStyle(17, weight: FontWeight.w700)),
  );
}

/// Icon tile + title + subtitle (+ optional chevron) row card.
class InfoRowCard extends StatelessWidget {
  final IconData? icon;
  final String? iconAsset;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool chevron;
  final bool circleIcon;
  final Color tileColor;
  final Color iconColor;
  final Color? cardColor;
  final Color? borderColor;
  final Color? chevronColor;

  const InfoRowCard({
    super.key,
    this.icon,
    this.iconAsset,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.chevron = false,
    this.circleIcon = false,
    this.tileColor = const Color(0xFFE8F8F1),
    this.iconColor = kGreen,
    this.cardColor,
    this.borderColor,
    this.chevronColor,
  }) : assert(
         icon != null || iconAsset != null,
         'Provide either icon or iconAsset',
       );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InsightCard(
        onTap: onTap,
        color: cardColor,
        borderColor: borderColor,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
        child: Row(
          children: [
            Image.asset(iconAsset!, height: 44.h, fit: BoxFit.contain),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: const Color(0xFF111827),
                      fontSize: 15,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(subtitle, style: bodyStyle(12, height: 1.35)),
                ],
              ),
            ),
            if (chevron)
              Icon(
                Icons.chevron_right_rounded,
                color: chevronColor ?? const Color(0xFF9CA3AF),
                size: 22.sp,
              ),
          ],
        ),
      ),
    );
  }
}

/// Mint tip banner with a lightbulb-style icon.
class TipBanner extends StatelessWidget {
  final String text;
  final IconData icon;
  final String? iconAsset;
  final bool bold;

  const TipBanner({
    super.key,
    required this.text,
    this.icon = Icons.lightbulb_outline_rounded,
    this.iconAsset,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE9FBF3),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFBFEBDA)),
      ),
      child: Row(
        children: [
          if (iconAsset != null)
            Image.asset(iconAsset!, width: 30.w, height: 30.w)
          else
            Container(
              width: 30.w,
              height: 30.w,
              decoration: const BoxDecoration(
                color: Color(0xFFCDF3E4),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16.sp, color: kGreen),
            ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: bodyStyle(
                13,
                color: kGreenDark,
                weight: bold ? FontWeight.w600 : FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-width green gradient button (Mark as Eaten / View Your Progress).
class GradientActionButton extends StatelessWidget {
  final String text;
  final IconData? leading;
  final IconData? trailing;
  final VoidCallback onTap;

  const GradientActionButton({
    super.key,
    required this.text,
    required this.onTap,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52.h,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1BD19E), Color(0xFF0AA37D)],
          ),
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4D09B389),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) ...[
              Icon(leading, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
            ],
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
            if (trailing != null) ...[
              SizedBox(width: 8.w),
              Icon(trailing, color: Colors.white, size: 20.sp),
            ],
          ],
        ),
      ),
    );
  }
}
