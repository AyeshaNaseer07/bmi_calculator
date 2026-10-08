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
          Center(
            child: Text(
              'Add more color and fiber to your meals.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          const SectionTitle('Why Vegetables Matter'),
          const InfoRowCard(
            iconAsset: AppAssets.tipRichInFiber,
            title: 'Rich in Fiber',
            subtitle: 'Fiber helps you feel full and supports digestion.',
          ),
          const InfoRowCard(
            iconAsset: AppAssets.tipFullOfNutrients,
            title: 'Full of Nutrients',
            subtitle: 'Vegetables provide vitamins and minerals.',
          ),
          const InfoRowCard(
            iconAsset: AppAssets.tipAddMoreColor,
            title: 'Add More Color',
            subtitle: 'Choose different vegetables for variety.',
          ),
          SizedBox(height: 4.h),
          const SectionTitle('Try This Today'),
          InsightCard(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.asset(
                        AppAssets.tipSimpleMeal,
                        width: 48.w,
                        height: 48.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Simple Meal',
                            style: TextStyle(
                              color: const Color(0xFF111827),
                              fontSize: 15,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Half plate of vegetables, quarter protein, quarter grains.',
                            style: TextStyle(
                              color: const Color(0xFF6B7280),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.40,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  'Start by adding vegetables to one meal. You can build up to more over time.',
                  style: bodyStyle(12.5, color: kMuted, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LeanProteinScreen extends StatelessWidget {
  const LeanProteinScreen({super.key});

  Widget _choice(String asset, String title, String subtitle) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(
      color: const Color(0xFFE3F7EC),
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(color: const Color(0xFF33D2AB), width: 1.2),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A000000),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(asset, width: 50.w, height: 50.w, fit: BoxFit.contain),
        SizedBox(height: 10.h),
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
        Text(
          subtitle,
          style: TextStyle(
            color: const Color(0xFF6B7280),
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            height: 1.0,
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return InsightScaffold(
      title: 'Choose Lean Protein',
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
            text: 'Include a source of protein in your main meals.',
          ),
          SizedBox(height: 14.h),
          const SectionTitle('Healthy Protein Choices'),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 1.15,
            children: [
              _choice(
                AppAssets.proteinEgg,
                'Eggs',
                'An easy source of protein.',
              ),
              _choice(
                AppAssets.proteinFish,
                'Fish',
                'Provides protein and important nutrients.',
              ),
              _choice(
                AppAssets.proteinBeans,
                'Beans & Lentils',
                'Offer protein and fiber.',
              ),
              _choice(
                AppAssets.proteinChicken,
                'Chicken',
                'A versatile source of lean protein.',
              ),
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
      title: 'Control Portion Sizes',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            // Matches the asset's own 1005×540 canvas so it renders at its
            // natural size instead of being cropped/stretched to a guess.
            aspectRatio: 1020 / 550,
            child: AssetOrPlaceholder(
              asset: AppAssets.portionSizeHero,
              width: double.infinity,
              fit: BoxFit.contain,
              radius: 20,
            ),
          ),
          SizedBox(height: 14.h),
          Center(
            child: Text(
              'Enjoy balanced portions without skipping meals.',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.57,
              ),
            ),
          ),
          SizedBox(height: 14.h),
          const InfoRowCard(
            iconAsset: AppAssets.tipMoreVeggies,
            title: 'Half Your Plate',
            subtitle: 'Fill half your plate with vegetables.',
          ),
          const InfoRowCard(
            iconAsset: AppAssets.portionAddProtein,
            title: 'Add Protein',
            subtitle: 'Use one quarter of your plate for protein.',
          ),
          const InfoRowCard(
            iconAsset: AppAssets.portionWholeGrain,
            title: 'Include Whole Grains',
            subtitle: 'Fill the remaining quarter with whole grains.',
          ),
          SizedBox(height: 4.h),
          const TipBanner(
            iconAsset: AppAssets.portionHeart,
            text: 'A Simple Habit: Eat slowly and pause to notice when you feel comfortably full.',
          ),
        ],
      ),
    );
  }
}
