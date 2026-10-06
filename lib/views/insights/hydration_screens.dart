import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/constants/app_assets.dart';
import 'insight_common.dart';

const Color _blue = Color(0xFF3B82F6);
const Color _purple = Color(0xFF8B5CF6);
const Color _grey = Color(0xFF6B7280);

class StayHydratedScreen extends StatelessWidget {
  const StayHydratedScreen({super.key});

  Widget _row(
    IconData icon,
    String t,
    String s,
    Color c,
    Widget Function() page,
  ) => InfoRowCard(
    icon: icon,
    title: t,
    subtitle: s,
    chevron: true,
    iconColor: c,
    tileColor: c.withOpacity(0.12),
    onTap: () => Get.to(page),
  );

  @override
  Widget build(BuildContext context) {
    return InsightScaffold(
      title: 'Stay Hydrated',
      titleIcon: Icons.water_drop_rounded,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AssetOrPlaceholder(
            asset: AppAssets.photoWaterHero,
            width: double.infinity,
            height: 160.h,
            radius: 20,
            icon: Icons.water_drop_rounded,
          ),
          SizedBox(height: 14.h),
          Text('Drink enough water daily.', style: headStyle(20)),
          SizedBox(height: 14.h),
          const SectionTitle('Benefits'),
          _row(Icons.bolt_rounded, 'Boosts Your Energy', 'Stay fresh and focused',
              kGreen, () => const BoostsEnergyScreen()),
          _row(Icons.spa_outlined, 'Supports Digestion', 'Keeps things moving',
              _blue, () => const SupportsDigestionScreen()),
          _row(Icons.face_retouching_natural_rounded, 'Good for Your Skin',
              'Helps maintain healthy skin', _purple,
              () => const GoodForSkinScreen()),
          _row(Icons.flag_outlined, 'Your Daily Goal', 'See how much to drink',
              _grey, () => const DailyGoalScreen()),
        ],
      ),
    );
  }
}

/// Shared layout for the small hydration detail screens.
class _HydrationDetail extends StatelessWidget {
  final String title;
  final IconData icon;
  final String photo;
  final String heading;
  final List<List<dynamic>> points; // [IconData, title, subtitle]
  final String tip;
  const _HydrationDetail({
    required this.title,
    required this.icon,
    required this.photo,
    required this.heading,
    required this.points,
    required this.tip,
  });

  @override
  Widget build(BuildContext context) {
    return InsightScaffold(
      title: title,
      titleIcon: icon,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AssetOrPlaceholder(
            asset: photo,
            width: double.infinity,
            height: 150.h,
            radius: 20,
            icon: icon,
          ),
          SizedBox(height: 14.h),
          SectionTitle(heading),
          for (final p in points)
            InfoRowCard(
              icon: p[0] as IconData,
              title: p[1] as String,
              subtitle: p[2] as String,
            ),
          SizedBox(height: 4.h),
          TipBanner(text: tip),
        ],
      ),
    );
  }
}

class BoostsEnergyScreen extends StatelessWidget {
  const BoostsEnergyScreen({super.key});
  @override
  Widget build(BuildContext context) => const _HydrationDetail(
    title: 'Boosts Your Energy',
    icon: Icons.bolt_rounded,
    photo: AppAssets.photoWaterEnergy,
    heading: 'How Water Helps',
    points: [
      [Icons.center_focus_strong_rounded, 'Supports Focus', 'Stay sharp through the day'],
      [Icons.battery_charging_full_rounded, 'Helps Reduce Tiredness', 'Fight low-energy moments'],
      [Icons.directions_run_rounded, 'Supports Daily Activity', 'Keep your body moving well'],
    ],
    tip: 'Simple Tip: Keep a glass of water nearby and sip regularly.',
  );
}

class SupportsDigestionScreen extends StatelessWidget {
  const SupportsDigestionScreen({super.key});
  @override
  Widget build(BuildContext context) => const _HydrationDetail(
    title: 'Supports Digestion',
    icon: Icons.spa_outlined,
    photo: AppAssets.photoWaterHero,
    heading: 'Why Water Matters',
    points: [
      [Icons.restaurant_rounded, 'Helps Digestion', 'Breaks down food more easily'],
      [Icons.loop_rounded, 'Supports Regularity', 'Keeps your system moving'],
      [Icons.eco_rounded, 'Helps Nutrient Absorption', 'Get more from your meals'],
    ],
    tip: 'Simple Tip: Drink a glass of water with your meals.',
  );
}

class GoodForSkinScreen extends StatelessWidget {
  const GoodForSkinScreen({super.key});
  @override
  Widget build(BuildContext context) => const _HydrationDetail(
    title: 'Good for Your Skin',
    icon: Icons.face_retouching_natural_rounded,
    photo: AppAssets.photoWaterHero,
    heading: 'How Hydration Helps',
    points: [
      [Icons.spa_rounded, 'Supports Skin Health', 'Keeps skin fresh and supple'],
      [Icons.water_drop_outlined, 'Maintains Fluid Balance', 'Helps your body stay balanced'],
      [Icons.repeat_rounded, 'Build Healthy Habits', 'Small sips add up over time'],
    ],
    tip: 'Simple Tip: Start your morning with a glass of water.',
  );
}

class DailyGoalScreen extends StatelessWidget {
  const DailyGoalScreen({super.key});
  @override
  Widget build(BuildContext context) => const _HydrationDetail(
    title: 'Your Daily Goal',
    icon: Icons.flag_outlined,
    photo: AppAssets.photoWaterHero,
    heading: 'Aim For',
    points: [
      [Icons.water_drop_rounded, '2 – 3 Litres a Day', 'About 8 glasses for most adults'],
      [Icons.wb_sunny_outlined, 'Drink More When Active', 'Add extra on hot or active days'],
      [Icons.alarm_rounded, 'Set Reminders', 'Sip regularly through the day'],
    ],
    tip: 'Simple Tip: Pale-yellow urine is a good sign you are well hydrated.',
  );
}
