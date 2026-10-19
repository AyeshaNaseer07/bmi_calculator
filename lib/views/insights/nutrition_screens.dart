import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../core/constants/app_assets.dart';
import '../onboarding/soft_paywall_screen.dart';
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
          // Photo with the soft mint glow behind it (Figma).
          SizedBox(
            width: 230.w,
            height: 170.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 230.w,
                  height: 170.w,
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      radius: 0.62,
                      colors: [
                        Color(0x6633D2AB),
                        Color(0x2233D2AB),
                        Color(0x0033D2AB),
                      ],
                      stops: [0.35, 0.7, 1.0],
                    ),
                  ),
                ),
                AssetOrPlaceholder(
                  asset: AppAssets.tipMeals,
                  width: 140.w,
                  height: 140.w,
                  circle: true,
                ),
              ],
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
            pro: !Get.find<AppController>().isPremium.value,
            onTap: () {
              if (Get.find<AppController>().isPremium.value) {
                Get.to(() => const DailyMealPlanScreen());
              } else {
                Get.to(
                  () => SoftPaywallScreen(
                    onUnlocked: () => Get.to(() => const DailyMealPlanScreen()),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Card used on the Eat Balanced Meals hub (Figma): white card with a mint
/// border, icon tile, bold title, grey subtitle and a chevron. [pro] adds a
/// small gold crown after the title.
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
          padding: const EdgeInsets.all(14),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            shadows: [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 12,
                offset: Offset(0, 4),
                spreadRadius: 0,
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

  /// Figma card: white, mint border, rounded 20, soft mint shadow.
  static BoxDecoration get _cardDeco => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20.r),
    border: Border.all(color: const Color(0xFFCDEFE3), width: 1.2),
    boxShadow: const [
      BoxShadow(color: Color(0x1233D2AB), blurRadius: 10, offset: Offset(0, 3)),
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
    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
    decoration: _cardDeco,
    child: Row(
      children: [
        Image.asset(icon, width: 42.w, height: 42.w),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
    // No scroll view: every block takes a share of the screen height so the
    // whole page fits on one screen.
    return InsightScaffold(
      title: 'Eat More Vegetables',
      scroll: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo inside a mint-bordered card with a soft mint gradient.
          Expanded(
            flex: 5,
            child: Center(
              child: Container(
                width: 280.w,
                height: 250.h,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: Image.asset(
                  AppAssets.photoVegetables,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
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
          Expanded(
            flex: 10,
            child: Column(
              children: [
                Expanded(
                  child: _why(
                    AppAssets.tipRichInFiber,
                    'Rich in Fiber',
                    'Fiber helps you feel full and supports digestion.',
                  ),
                ),
                SizedBox(height: 10.h),
                Expanded(
                  child: _why(
                    AppAssets.tipFullOfNutrients,
                    'Full of Nutrients',
                    'Vegetables provide vitamins and minerals.',
                  ),
                ),
                SizedBox(height: 10.h),
                Expanded(
                  child: _why(
                    AppAssets.tipAddMoreColor,
                    'Add More Color',
                    'Choose different vegetables for variety.',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Text('Try This Today', style: _section),
          SizedBox(height: 10.h),
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: _cardDeco,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  Flexible(
                    child: Text(
                      'Start by adding vegetables to one meal. You can build up to more over time.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _sub.copyWith(color: const Color(0xFF4B5563)),
                    ),
                  ),
                ],
              ),
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
