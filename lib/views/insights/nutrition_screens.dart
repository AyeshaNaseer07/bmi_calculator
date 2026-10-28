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
          SizedBox(height: 4.h),
          // Photo with the soft mint glow around it (Figma). The glow is a
          // blurred shadow on the circle so it shows outside the photo edge.
          SizedBox(
            height: 170.w,
            child: Center(
              child: Container(
                width: 140.w,
                height: 140.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x6633D2AB),
                      blurRadius: 36,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: AssetOrPlaceholder(
                  asset: AppAssets.tipMeals,
                  width: 140.w,
                  height: 140.w,
                  circle: true,
                ),
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: ShapeDecoration(
              color: const Color(0x666CF8BB).withValues(alpha: 0.3),
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
              fontSize: 11.5,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w400,
              height: 1.6,
              letterSpacing: 0.06,
            ),
          ),
          SizedBox(height: 16.h),
          _HubCard(
            iconAsset: AppAssets.tipMoreVeggies,
            title: 'Eat More Vegetables',
            subtitle: 'Add vegetables and fiber to your meals.',
            onTap: () => Get.to(() => const EatVegetablesScreen()),
          ),
          _HubCard(
            iconAsset: AppAssets.tipLeanProtein,
            title: 'Choose Lean Protein',
            subtitle: 'Include eggs, fish, beans or chicken.',
            onTap: () => Get.to(() => const LeanProteinScreen()),
          ),
          _HubCard(
            iconAsset: AppAssets.tipPortionControl,
            title: 'Control Portion Sizes',
            subtitle: 'Enjoy balanced portions at every meal.',
            onTap: () => Get.to(() => const PortionSizesScreen()),
          ),
          _HubCard(
            iconAsset: AppAssets.tipDailyMealPlan,
            title: '1 Week Meal Plan',
            subtitle: 'Explore simple ideas for balanced meals.',
            // Always marked as a Pro feature, premium or not.
            pro: true,
            onTap: () {
              Get.to(() => const DailyMealPlanScreen());
              // if (Get.find<AppController>().isPremium.value) {
              //   Get.to(() => const DailyMealPlanScreen());
              // } else {
              //   Get.to(
              //     () => SoftPaywallScreen(
              //       onUnlocked: () => Get.to(() => const DailyMealPlanScreen()),
              //     ),
              //   );
              // }
            },
          ),
        ],
      ),
    );
  }
}

/// Card used on the Eat Balanced Meals hub (Figma): white card with a soft
/// mint glow, icon tile, bold title, grey subtitle and a chevron. [pro] adds
/// a small gold crown after the title.
class _HubCard extends StatelessWidget {
  final String iconAsset;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool pro;

  const _HubCard({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.pro = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3333D2AB),
                blurRadius: 8,
                offset: Offset.zero,
              ),
            ],
          ),
          child: Row(
            children: [
              Image.asset(iconAsset, width: 50.w, height: 50.w),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: const Color(0xFF111827),
                              fontSize: 15.5,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (pro) ...[
                          SizedBox(width: 6.w),
                          Image.asset(
                            AppAssets.weekPro,
                            width: 20.w,
                            height: 20.w,
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: const Color(0xFF6B7280),
                        fontSize: 12.5,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFF9CA3AF),
                size: 26.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EatVegetablesScreen extends StatelessWidget {
  const EatVegetablesScreen({super.key});

  /// Figma card: white, rounded 20, soft mint glow all round (no border).
  static BoxDecoration get _cardDeco => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20.r),
    boxShadow: const [
      BoxShadow(color: Color(0x3333D2AB), blurRadius: 8, offset: Offset.zero),
    ],
  );

  static TextStyle _title(double size) => TextStyle(
    color: const Color(0xFF111827),
    fontSize: size,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
  );

  static TextStyle get _sub => TextStyle(
    color: const Color(0xFF6B7280),
    fontSize: 13,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static TextStyle get _section => TextStyle(
    color: const Color(0xFF111827),
    fontSize: 18,
    fontFamily: 'Plus Jakarta Sans',
    fontWeight: FontWeight.w700,
  );

  Widget _why(String icon, String title, String subtitle) => Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: 10.h),
    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
    decoration: _cardDeco,
    child: Row(
      children: [
        Image.asset(icon, width: 42.w, height: 42.w),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, maxLines: 1, style: _title(15)),
              SizedBox(height: 3.h),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _sub,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    // No scroll view: the cards keep their natural height and the photo
    // takes whatever height is left, so the page always fits one screen.
    return InsightScaffold(
      title: 'Eat More Vegetables',
      scroll: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The asset already has its mint border and rounded corners baked
          // in, so show it whole (contain) at its own 869×569 ratio.
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 869 / 569,
                child: Image.asset(
                  AppAssets.photoVegetables,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Center(
            child: Text(
              'Add more color and fiber to your meals.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 12.5,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text('Why Vegetables Matter', style: _section),
          SizedBox(height: 10.h),
          _why(
            AppAssets.tipRichInFiber,
            'Rich in Fiber',
            'Fiber helps you feel full and supports digestion.',
          ),
          _why(
            AppAssets.tipFullOfNutrients,
            'Full of Nutrients',
            'Vegetables provide vitamins and minerals.',
          ),
          _why(
            AppAssets.tipAddMoreColor,
            'Add More Color',
            'Choose different vegetables for variety.',
          ),
          SizedBox(height: 4.h),
          Text('Try This Today', style: _section),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: _cardDeco,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Image.asset(
                        AppAssets.tipSimpleMeal,
                        width: 58.w,
                        height: 58.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Simple Meal', style: _title(16.5)),
                          SizedBox(height: 3.h),
                          Text(
                            'Half plate of vegetables, quarter protein, quarter grains.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: _sub,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  'Start by adding vegetables to one meal. You can build up to more over time.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _sub.copyWith(color: const Color(0xFF4B5563)),
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
    padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 14.h),
    decoration: BoxDecoration(
      color: const Color(0xFFD9F5EC),
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: const Color(0xFF2CC99E)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // The asset includes its own light grey circle.
        Image.asset(asset, width: 40.w, height: 40.w, fit: BoxFit.contain),
        SizedBox(height: 12.h),
        Text(
          title,
          style: TextStyle(
            color: const Color(0xFF111827),
            fontSize: 15,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: TextStyle(
            color: const Color(0xFF6B7280),
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
      ],
    ),
  );

  /// Two cards side by side, both as tall as the taller one.
  Widget _choiceRow(Widget left, Widget right) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: left),
        SizedBox(width: 16.w),
        Expanded(child: right),
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
            height: 182.h,
            radius: 20.r,
          ),
          SizedBox(height: 14.h),
          const TipBanner(
            text: 'Include a source of protein in your main meals.',
          ),
          SizedBox(height: 14.h),
          const SectionTitle('Healthy Protein Choices'),
          _choiceRow(
            _choice(AppAssets.proteinEgg, 'Eggs', 'An easy source of protein.'),
            _choice(
              AppAssets.proteinFish,
              'Fish',
              'Provides protein and important nutrients.',
            ),
          ),
          SizedBox(height: 18.h),
          _choiceRow(
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
          ),
        ],
      ),
    );
  }
}

class PortionSizesScreen extends StatelessWidget {
  const PortionSizesScreen({super.key});

  Widget _step(String icon, String title, String subtitle) => Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: 12.h),
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
    // Soft mint glow all round (no border), same as the other nutrition cards.
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18.r),
      boxShadow: const [
        BoxShadow(color: Color(0x3333D2AB), blurRadius: 8, offset: Offset.zero),
      ],
    ),
    child: Row(
      children: [
        Image.asset(icon, width: 52.w, height: 52.w, fit: BoxFit.contain),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF111827),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: TextStyle(
                  color: const Color(0xFF6B7280),
                  fontSize: 13.5,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

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
          _step(
            AppAssets.tipMoreVeggies,
            'Half Your Plate',
            'Fill half your plate with vegetables.',
          ),
          _step(
            AppAssets.portionAddProtein,
            'Add Protein',
            'Use one quarter of your plate for protein.',
          ),
          _step(
            AppAssets.portionWholeGrain,
            'Include Whole Grains',
            'Fill the remaining quarter with whole grains.',
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
