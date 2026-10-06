import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/constants/app_assets.dart';
import 'insight_common.dart';
import 'meal_screens.dart';

export 'meal_screens.dart';

/// "Eat Balanced Meals" hub.
class EatBalancedMealsScreen extends StatelessWidget {
  const EatBalancedMealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InsightScaffold(
      title: 'Eat Balanced Meals',
      titleIcon: Icons.restaurant_rounded,
      body: Column(
        children: [
          SizedBox(height: 8.h),
          AssetOrPlaceholder(
            asset: AppAssets.tipMeals,
            width: 150.w,
            height: 150.w,
            circle: true,
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: kMintBg,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'NUTRITION GUIDE',
              style: bodyStyle(11, color: kGreen, weight: FontWeight.w700),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Build healthy plates, one meal at a time.',
            textAlign: TextAlign.center,
            style: headStyle(20),
          ),
          SizedBox(height: 18.h),
          InfoRowCard(
            icon: Icons.eco_rounded,
            title: 'Eat More Vegetables',
            subtitle: 'Add colour and fibre to every meal',
            chevron: true,
            onTap: () => Get.to(() => const EatVegetablesScreen()),
          ),
          InfoRowCard(
            icon: Icons.set_meal_rounded,
            title: 'Choose Lean Protein',
            subtitle: 'Keep you full and support muscles',
            chevron: true,
            onTap: () => Get.to(() => const LeanProteinScreen()),
          ),
          InfoRowCard(
            icon: Icons.pie_chart_outline_rounded,
            title: 'Watch Portion Sizes',
            subtitle: 'Enjoy food without overeating',
            chevron: true,
            onTap: () => Get.to(() => const PortionSizesScreen()),
          ),
          InfoRowCard(
            icon: Icons.calendar_month_rounded,
            title: 'Daily Meal Plan',
            subtitle: 'Simple ideas for your day',
            chevron: true,
            onTap: () => Get.to(() => const DailyMealPlanScreen()),
          ),
        ],
      ),
    );
  }
}

class EatVegetablesScreen extends StatelessWidget {
  const EatVegetablesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InsightScaffold(
      title: 'Eat More Vegetables',
      titleIcon: Icons.eco_rounded,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AssetOrPlaceholder(
            asset: AppAssets.photoVegetables,
            width: double.infinity,
            height: 170.h,
            radius: 20,
            icon: Icons.eco_rounded,
          ),
          SizedBox(height: 14.h),
          Text('Fill half your plate with vegetables.', style: headStyle(19)),
          SizedBox(height: 14.h),
          const TipBanner(
            text: 'Aim for a mix of colours — each one brings different nutrients.',
          ),
          SizedBox(height: 14.h),
          const SectionTitle('Why it helps'),
          const InfoRowCard(
            icon: Icons.grain_rounded,
            title: 'Rich in Fibre',
            subtitle: 'Helps you feel full for longer',
          ),
          const InfoRowCard(
            icon: Icons.favorite_border_rounded,
            title: 'Packed with Vitamins',
            subtitle: 'Supports overall health',
          ),
          const InfoRowCard(
            icon: Icons.local_fire_department_outlined,
            title: 'Low in Calories',
            subtitle: 'Eat more while staying balanced',
          ),
        ],
      ),
    );
  }
}

class LeanProteinScreen extends StatelessWidget {
  const LeanProteinScreen({super.key});

  Widget _choice(String emoji, String label) => InsightCard(
    padding: EdgeInsets.symmetric(vertical: 18.h),
    child: Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: 34.sp)),
        SizedBox(height: 8.h),
        Text(label, style: headStyle(14, weight: FontWeight.w700)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return InsightScaffold(
      title: 'Choose Lean Protein',
      titleIcon: Icons.set_meal_rounded,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AssetOrPlaceholder(
            asset: AppAssets.photoBalancedMeal,
            width: double.infinity,
            height: 150.h,
            radius: 20,
          ),
          SizedBox(height: 14.h),
          const TipBanner(
            text: 'Include a source of protein in every main meal.',
          ),
          SizedBox(height: 14.h),
          const SectionTitle('Good choices'),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 1.35,
            children: [
              _choice('🥚', 'Eggs'),
              _choice('🐟', 'Fish'),
              _choice('🫘', 'Beans & Lentils'),
              _choice('🍗', 'Chicken'),
            ],
          ),
        ],
      ),
    );
  }
}

class PortionSizesScreen extends StatelessWidget {
  const PortionSizesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InsightScaffold(
      title: 'Watch Portion Sizes',
      titleIcon: Icons.pie_chart_outline_rounded,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AssetOrPlaceholder(
            asset: AppAssets.photoPortionVeg,
            width: double.infinity,
            height: 160.h,
            radius: 20,
            icon: Icons.pie_chart_outline_rounded,
          ),
          SizedBox(height: 14.h),
          Text('Enjoy your food, mindfully.', style: headStyle(19)),
          SizedBox(height: 14.h),
          const SectionTitle('Simple ways to start'),
          const InfoRowCard(
            icon: Icons.dinner_dining_rounded,
            title: 'Use Smaller Plates',
            subtitle: 'Helps keep portions in check',
          ),
          const InfoRowCard(
            icon: Icons.timer_outlined,
            title: 'Eat Slowly',
            subtitle: 'Notice when you feel full',
          ),
          const InfoRowCard(
            icon: Icons.back_hand_outlined,
            title: 'Use Your Hand',
            subtitle: 'A palm of protein, a fist of carbs',
          ),
          SizedBox(height: 4.h),
          const TipBanner(
            text: 'Stop eating when you feel comfortably full.',
          ),
        ],
      ),
    );
  }
}
