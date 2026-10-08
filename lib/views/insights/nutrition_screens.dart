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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: ShapeDecoration(
              color: const Color(0x666CF8BB).withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(AppAssets.leafIcon, width: 12.w, height: 12.h),
                SizedBox(width: 5.w),
                Text(
                  'NUTRITION GUIDE',
                  style: TextStyle(
                    color: const Color(0xFF00714D),
                    fontSize: 11,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    height: 1.27,
                    letterSpacing: 0.55,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Build healthy eating habits, one meal at a time.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
              height: 1.80,
              letterSpacing: 0.06,
            ),
          ),
          SizedBox(height: 18.h),
          InfoRowCard(
            iconAsset: AppAssets.tipMoreVeggies,
            title: 'Eat More Vegetables',
            subtitle: 'Add vegetables and fiber to your meals.',
            chevron: true,
            onTap: () => Get.to(() => const EatVegetablesScreen()),
          ),
          InfoRowCard(
            iconAsset: AppAssets.tipLeanProtein,
            title: 'Choose Lean Protein',
            subtitle: 'Include eggs, fish, beans or chicken.',
            chevron: true,
            onTap: () => Get.to(() => const LeanProteinScreen()),
          ),
          InfoRowCard(
            iconAsset: AppAssets.tipPortionControl,
            title: 'Control Portion Sizes',
            subtitle: 'Enjoy balanced portions at every meal.',
            chevron: true,
            onTap: () => Get.to(() => const PortionSizesScreen()),
          ),
          InfoRowCard(
            iconAsset: AppAssets.tipDailyMealPlan,
            title: '1 Week Meal Plan',
            subtitle: 'Explore simple ideas for balanced meals.',
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AssetOrPlaceholder(
            asset: AppAssets.photoVegetables,
            width: double.infinity,
            height: 180.h,
            radius: 20,
            icon: Icons.eco_rounded,
          ),
          SizedBox(height: 12.h),
          Text(
            'Add more color and fiber to your meals.',
            textAlign: TextAlign.center,
            style: bodyStyle(13, color: kMuted, weight: FontWeight.w500),
          ),
          SizedBox(height: 16.h),
          const SectionTitle('Why Vegetables Matter'),
          const InfoRowCard(
            icon: Icons.favorite_border_rounded,
            title: 'Rich in Fiber',
            subtitle: 'Fiber helps you feel full and supports digestion.',
          ),
          const InfoRowCard(
            icon: Icons.auto_awesome_rounded,
            title: 'Full of Nutrients',
            subtitle: 'Vegetables provide vitamins and minerals.',
          ),
          const InfoRowCard(
            icon: Icons.palette_outlined,
            title: 'Add More Color',
            subtitle: 'Choose different vegetables for variety.',
          ),
          SizedBox(height: 4.h),
          const SectionTitle('Try This Today'),
          InfoRowCard(
            iconAsset: AppAssets.photoVegetables,
            title: 'Simple Meal',
            subtitle:
                'Half plate of vegetables, quarter protein, quarter grains.',
          ),
          SizedBox(height: 4.h),
          Text(
            'Start by adding vegetables to one meal. You can build up to more over time.',
            style: bodyStyle(12.5, color: kMuted, height: 1.4),
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
          const TipBanner(text: 'Stop eating when you feel comfortably full.'),
        ],
      ),
    );
  }
}
