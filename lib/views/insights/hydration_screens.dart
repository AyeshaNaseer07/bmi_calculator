import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/constants/app_assets.dart';
import 'hydration_goal_screens.dart';
import 'insight_common.dart';

export 'hydration_goal_screens.dart';

const Color _kDeep = Color(0xFF006B4E);
const Color _kSub = Color(0xFF6B7280);

class _Benefit extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color bg;
  final Color border;
  final Color chevron;
  final VoidCallback onTap;
  const _Benefit({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.bg,
    required this.border,
    required this.chevron,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: border, width: 1.2),
          ),
          child: Row(
            children: [
              Image.asset(icon, width: 46.w, height: 46.w),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: headStyle(16, weight: FontWeight.w700),
                    ),
                    SizedBox(height: 2.h),
                    Text(subtitle, style: bodyStyle(12.5, color: _kSub, height: 1.3)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: chevron, size: 22.sp),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Stay Hydrated" hub.
class StayHydratedScreen extends StatelessWidget {
  const StayHydratedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InsightScaffold(
      title: 'Stay Hydrated',
      titleIcon: Icons.water_drop_outlined,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              AppAssets.waterHero,
              width: 250.w,
              fit: BoxFit.contain,
            ),
          ),
          Center(
            child: Text(
              'Drink enough water daily.',
              style: bodyStyle(14, color: _kSub),
            ),
          ),
          SizedBox(height: 10.h),
          Text('Benefits', style: headStyle(18, weight: FontWeight.w600)),
          SizedBox(height: 10.h),
          _Benefit(
            icon: AppAssets.waterBoostIcon,
            title: 'Boosts Your Energy',
            subtitle: 'Water helps your body and mind work better.',
            bg: const Color(0xFFEAFBF3),
            border: const Color(0xFFC8F0DE),
            chevron: const Color(0xFF10B981),
            onTap: () => Get.to(() => const BoostsEnergyScreen()),
          ),
          _Benefit(
            icon: AppAssets.waterSupportIcon,
            title: 'Supports Digestion',
            subtitle: 'Helps your digestive system work smoothly.',
            bg: const Color(0xFFEBF3FE),
            border: const Color(0xFFD3E4FB),
            chevron: const Color(0xFF3B82F6),
            onTap: () => Get.to(() => const SupportsDigestionScreen()),
          ),
          _Benefit(
            icon: AppAssets.waterGoodIcon,
            title: 'Good for Your Skin',
            subtitle: 'Staying hydrated helps maintain healthy skin.',
            bg: const Color(0xFFF3EEFE),
            border: const Color(0xFFE2D6FB),
            chevron: const Color(0xFF8B5CF6),
            onTap: () => Get.to(() => const GoodForSkinScreen()),
          ),
          _Benefit(
            icon: AppAssets.waterDailyIcon,
            title: 'Your Daily Goal',
            subtitle: 'Find out how much water you may need each day.',
            bg: const Color(0xFFF8F9FB),
            border: const Color(0xFFD7F0E6),
            chevron: const Color(0xFF4B5563),
            onTap: () => Get.to(() => const DailyGoalScreen()),
          ),
        ],
      ),
    );
  }
}

class _MintRow extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  const _MintRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFDDF7EE),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: icon,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: headStyle(16, weight: FontWeight.w700)),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: bodyStyle(13, color: _kSub, height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _asset(String path, {double size = 24}) =>
    Image.asset(path, width: size.w, height: size.w, fit: BoxFit.contain);

/// "Boosts Your Energy".
class BoostsEnergyScreen extends StatelessWidget {
  const BoostsEnergyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InsightScaffold(
      title: 'Boosts Your Energy',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28.r),
              child: Image.asset(
                AppAssets.waterEnergy,
                width: 296.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Center(
            child: Text(
              'Stay hydrated to help your body feel its best.',
              style: bodyStyle(13, color: _kSub),
            ),
          ),
          SizedBox(height: 12.h),
          Text('How Water Helps', style: headStyle(18, weight: FontWeight.w600)),
          SizedBox(height: 10.h),
          _MintRow(
            icon: _asset(AppAssets.brainIcon, size: 26),
            title: 'Supports Focus',
            subtitle: 'Drinking enough water helps you stay focused '
                'throughout the day.',
          ),
          _MintRow(
            icon: _asset(AppAssets.moonIcon, size: 26),
            title: 'Helps Reduce Tiredness',
            subtitle: 'Dehydration can make you feel tired.',
          ),
          _MintRow(
            icon: _asset(AppAssets.pulseIcon, size: 26),
            title: 'Supports Daily Activity',
            subtitle: 'Water helps your body function during everyday '
                'activities.',
          ),
          SizedBox(height: 14.h),
          const _TipStrip(
            text: 'Simple Tip: Keep a glass of water nearby and sip regularly.',
          ),
        ],
      ),
    );
  }
}

class _TipStrip extends StatelessWidget {
  final String text;
  final Widget? icon;
  const _TipStrip({required this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFCF6),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFD3F3E6)),
      ),
      child: Row(
        children: [
          icon ??
              Container(
                width: 34.w,
                height: 34.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFCDF3E4),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 18.sp,
                  color: kGreen,
                ),
              ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: bodyStyle(
                14,
                color: _kDeep,
                weight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Supports Digestion".
class SupportsDigestionScreen extends StatelessWidget {
  const SupportsDigestionScreen({super.key});

  Widget _card(Widget icon, String title, String sub) => Padding(
    padding: EdgeInsets.only(bottom: 12.h),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFCDEFE2), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2633D2AB),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFE8FBF3),
              shape: BoxShape.circle,
            ),
            child: icon,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: headStyle(16, weight: FontWeight.w700)),
                SizedBox(height: 2.h),
                Text(sub, style: bodyStyle(13, color: _kSub, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return InsightScaffold(
      title: 'Supports Digestion',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Water plays an important role in healthy digestion.',
              style: bodyStyle(12, color: _kSub),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Why Water Matters',
            style: headStyle(17, color: const Color(0xFF0B2B2B)),
          ),
          SizedBox(height: 8.h),
          _card(
            Icon(Icons.restaurant_rounded, size: 24.sp, color: kGreen),
            'Helps Digestion',
            'Water helps your body digest food.',
          ),
          _card(
            _asset(AppAssets.pulseIcon, size: 26),
            'Supports Regularity',
            'Drinking enough water helps prevent constipation.',
          ),
          _card(
            Icon(Icons.eco_outlined, size: 24.sp, color: kGreen),
            'Helps Nutrient Absorption',
            'Water supports the normal processes your body uses to absorb '
                'nutrients.',
          ),
          SizedBox(height: 4.h),
          _TipStrip(
            icon: Image.asset(AppAssets.glassTipIcon, width: 36.w, height: 36.w),
            text: 'Drink water regularly throughout the day, especially with '
                'meals.',
          ),
        ],
      ),
    );
  }
}

/// "Good for Your Skin".
class GoodForSkinScreen extends StatelessWidget {
  const GoodForSkinScreen({super.key});

  Widget _card(Widget icon, Color tile, String title, String sub) => Padding(
    padding: EdgeInsets.only(bottom: 12.h),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFD5F2E8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A33D2AB),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tile,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: icon,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(title, style: headStyle(16, weight: FontWeight.w700)),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(sub, style: bodyStyle(13, color: _kSub, height: 1.35)),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return InsightScaffold(
      title: 'Good for Your Skin',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              AppAssets.waterSkin,
              width: 230.w,
              fit: BoxFit.contain,
            ),
          ),
          Center(
            child: Text(
              'Hydration is part of a healthy skincare routine.',
              style: bodyStyle(13, color: _kSub),
            ),
          ),
          SizedBox(height: 12.h),
          Text('How Hydration Helps', style: headStyle(18, weight: FontWeight.w600)),
          SizedBox(height: 10.h),
          _card(
            Icon(Icons.favorite_border_rounded, size: 19.sp, color: const Color(0xFF3B82F6)),
            const Color(0xFFEAF3FE),
            'Supports Skin Health',
            'Water helps your body maintain normal skin function.',
          ),
          _card(
            _asset(AppAssets.pulseIcon, size: 20),
            const Color(0xFFE6F8F1),
            'Maintains Fluid Balance',
            'Drinking enough water helps maintain your body’s fluid balance.',
          ),
          _card(
            Icon(Icons.auto_awesome_rounded, size: 19.sp, color: const Color(0xFF8B5CF6)),
            const Color(0xFFF1ECFD),
            'Build Healthy Habits',
            'Regular hydration is one part of caring for your skin.',
          ),
        ],
      ),
    );
  }
}
