import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_assets.dart';
import 'insight_common.dart';

class _LifestyleDetail extends StatelessWidget {
  final String title;
  final IconData icon;
  final String photo;
  final String heading;
  final List<List<dynamic>> points;
  final String tip;
  const _LifestyleDetail({
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
            height: 160.h,
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

class StayActiveScreen extends StatelessWidget {
  const StayActiveScreen({super.key});
  @override
  Widget build(BuildContext context) => const _LifestyleDetail(
    title: 'Stay Active',
    icon: Icons.directions_run_rounded,
    photo: AppAssets.tipActive,
    heading: 'Move a Little Every Day',
    points: [
      [Icons.directions_walk_rounded, 'Walk Daily', '20–30 minutes is a great start'],
      [Icons.fitness_center_rounded, 'Strength Training', 'Two sessions a week build muscle'],
      [Icons.stairs_rounded, 'Take the Stairs', 'Small choices add up'],
    ],
    tip: 'Simple Tip: Start small and build up gradually.',
  );
}

class SleepWellScreen extends StatelessWidget {
  const SleepWellScreen({super.key});
  @override
  Widget build(BuildContext context) => const _LifestyleDetail(
    title: 'Sleep Well',
    icon: Icons.bedtime_rounded,
    photo: AppAssets.tipSleep,
    heading: 'Build Better Sleep',
    points: [
      [Icons.schedule_rounded, 'Keep a Schedule', 'Sleep and wake at the same time'],
      [Icons.phone_android_rounded, 'Limit Screens', 'Switch off an hour before bed'],
      [Icons.nights_stay_rounded, 'Aim for 7–9 Hours', 'Supports recovery and healthy weight'],
    ],
    tip: 'Simple Tip: Keep your bedroom cool, dark and quiet.',
  );
}
