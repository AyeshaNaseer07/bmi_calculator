import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/meal_plan_controller.dart';
import '../../core/constants/app_assets.dart';
import 'insight_common.dart';

class MealInfo {
  final String key;
  final String slot;
  final String name;
  final int kcal;
  final String photo;
  final int protein, carbs, fat;
  final int proteinPct, carbsPct, fatPct;
  final List<List<String>> ingredients;

  const MealInfo({
    required this.key,
    required this.slot,
    required this.name,
    required this.kcal,
    required this.photo,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.proteinPct,
    required this.carbsPct,
    required this.fatPct,
    required this.ingredients,
  });
}

const List<MealInfo> kMeals = [
  MealInfo(
    key: 'breakfast',
    slot: 'Breakfast',
    name: 'Greek Yogurt Bowl',
    kcal: 380,
    photo: AppAssets.photoBreakfast,
    protein: 24,
    carbs: 42,
    fat: 12,
    proteinPct: 31,
    carbsPct: 44,
    fatPct: 25,
    ingredients: [
      ['Greek yogurt', '200g'],
      ['Mixed berries', '1/2 cup'],
      ['Oats', '30g'],
      ['Honey', '1 tsp'],
    ],
  ),
  MealInfo(
    key: 'lunch',
    slot: 'Lunch',
    name: 'Grilled Chicken Salad',
    kcal: 450,
    photo: AppAssets.photoLunch,
    protein: 38,
    carbs: 20,
    fat: 18,
    proteinPct: 35,
    carbsPct: 18,
    fatPct: 47,
    ingredients: [
      ['Grilled chicken', '150g'],
      ['Leafy greens', '2 cups'],
      ['Cucumber', '1/2 cup sliced'],
      ['Tomatoes', '6 cherry halved'],
      ['Avocado', '1/4 fruit'],
    ],
  ),
  MealInfo(
    key: 'dinner',
    slot: 'Dinner',
    name: 'Salmon & Vegetables',
    kcal: 520,
    photo: AppAssets.photoDinner,
    protein: 36,
    carbs: 30,
    fat: 24,
    proteinPct: 28,
    carbsPct: 23,
    fatPct: 49,
    ingredients: [
      ['Salmon fillet', '150g'],
      ['Broccoli', '1 cup'],
      ['Sweet potato', '100g'],
      ['Olive oil', '1 tsp'],
    ],
  ),
];

class DailyMealPlanScreen extends StatelessWidget {
  const DailyMealPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = MealPlanController.to;
    return InsightScaffold(
      title: 'Daily Meal Plan',
      titleIcon: Icons.calendar_month_rounded,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AssetOrPlaceholder(
            asset: AppAssets.photoMealHero,
            width: double.infinity,
            height: 140.h,
            radius: 20,
          ),
          SizedBox(height: 14.h),
          Text('Simple ideas for your day', style: headStyle(19)),
          SizedBox(height: 14.h),
          for (final m in kMeals)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: InsightCard(
                padding: EdgeInsets.all(12.w),
                child: Row(
                  children: [
                    AssetOrPlaceholder(
                      asset: m.photo,
                      width: 64.w,
                      height: 64.w,
                      radius: 14,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.slot.toUpperCase(),
                            style: bodyStyle(
                              11,
                              color: kGreen,
                              weight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            m.name,
                            style: headStyle(15, weight: FontWeight.w700),
                          ),
                          Text('${m.kcal} kcal', style: bodyStyle(12)),
                        ],
                      ),
                    ),
                    Obx(() {
                      final done = c.isEaten(m.key);
                      return GestureDetector(
                        onTap: () => Get.to(() => MealDetailScreen(meal: m)),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: done ? kGreen : kMintBg,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            done ? 'Done' : 'View',
                            style: bodyStyle(
                              13,
                              color: done ? Colors.white : kGreen,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MealDetailScreen extends StatelessWidget {
  final MealInfo meal;
  const MealDetailScreen({super.key, required this.meal});

  Widget _macro(String label, String value, Color color) => Expanded(
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Text(value, style: headStyle(14, color: color)),
          SizedBox(height: 2.h),
          Text(label, style: bodyStyle(11)),
        ],
      ),
    ),
  );

  Widget _chip(String t) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
    decoration: BoxDecoration(
      color: kMintBg,
      borderRadius: BorderRadius.circular(20.r),
    ),
    child: Text(
      t,
      style: bodyStyle(12, color: kGreen, weight: FontWeight.w600),
    ),
  );

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF3B82F6);
    const orange = Color(0xFFF59E0B);
    const purple = Color(0xFF8B5CF6);
    return InsightScaffold(
      title: meal.name,
      titleIcon: Icons.restaurant_rounded,
      bottom: GradientActionButton(
        text: 'Mark as Eaten',
        leading: Icons.check_circle_outline_rounded,
        onTap: () {
          MealPlanController.to.markEaten(meal.key);
          Get.to(() => MealCompletedScreen(meal: meal));
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.w,
            children: [_chip(meal.slot), _chip('${meal.kcal} kcal')],
          ),
          SizedBox(height: 12.h),
          AssetOrPlaceholder(
            asset: meal.key == 'lunch' ? AppAssets.photoLunchHero : meal.photo,
            width: double.infinity,
            height: 180.h,
            radius: 20,
          ),
          SizedBox(height: 16.h),
          const SectionTitle('Nutrition Summary'),
          InsightCard(
            padding: EdgeInsets.all(12.w),
            child: Column(
              children: [
                Row(
                  children: [
                    _macro('Calories', '${meal.kcal}', kGreen),
                    _macro('Protein', '${meal.protein}g', blue),
                    _macro('Carbs', '${meal.carbs}g', orange),
                    _macro('Fat', '${meal.fat}g', purple),
                  ],
                ),
                SizedBox(height: 12.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: SizedBox(
                    height: 10.h,
                    child: Row(
                      children: [
                        Expanded(
                          flex: meal.proteinPct,
                          child: Container(color: blue),
                        ),
                        Expanded(
                          flex: meal.carbsPct,
                          child: Container(color: orange),
                        ),
                        Expanded(
                          flex: meal.fatPct,
                          child: Container(color: purple),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Protein ${meal.proteinPct}%', style: bodyStyle(11)),
                    Text('Carbs ${meal.carbsPct}%', style: bodyStyle(11)),
                    Text('Fat ${meal.fatPct}%', style: bodyStyle(11)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          InfoRowCard(
            icon: Icons.shopping_basket_outlined,
            title: 'Ingredients',
            subtitle: '${meal.ingredients.length} items',
            chevron: true,
            onTap: () => Get.to(() => IngredientsScreen(meal: meal)),
          ),
        ],
      ),
    );
  }
}

class IngredientsScreen extends StatelessWidget {
  final MealInfo meal;
  const IngredientsScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return InsightScaffold(
      title: 'Ingredients',
      titleIcon: Icons.shopping_basket_outlined,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(meal.name, style: headStyle(19)),
          SizedBox(height: 14.h),
          InsightCard(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            child: Column(
              children: [
                for (int i = 0; i < meal.ingredients.length; i++) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: kGreen,
                          size: 20.sp,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            meal.ingredients[i][0],
                            style: bodyStyle(
                              14,
                              color: kInk,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(meal.ingredients[i][1], style: bodyStyle(13)),
                      ],
                    ),
                  ),
                  if (i != meal.ingredients.length - 1)
                    const Divider(height: 1, color: kMintBorder),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MealCompletedScreen extends StatelessWidget {
  final MealInfo meal;
  const MealCompletedScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    final c = MealPlanController.to;
    return InsightScaffold(
      title: 'Meal Completed',
      titleIcon: Icons.check_circle_outline_rounded,
      bottom: GradientActionButton(
        text: 'View Your Progress',
        trailing: Icons.arrow_forward_rounded,
        onTap: () => Get.to(() => const MealProgressScreen()),
      ),
      body: Column(
        children: [
          SizedBox(height: 24.h),
          Container(
            width: 110.w,
            height: 110.w,
            decoration: const BoxDecoration(
              color: kMintBg,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: kGreen, size: 60.sp),
          ),
          SizedBox(height: 18.h),
          Text(
            '${meal.slot} Completed!',
            style: headStyle(22),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: kMintBg,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'Milestone reached 🎉',
              style: bodyStyle(12, color: kGreen, weight: FontWeight.w700),
            ),
          ),
          SizedBox(height: 22.h),
          Obx(() {
            final done = c.completedCount.clamp(0, 3);
            return InsightCard(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Day 1 of 7', style: headStyle(16)),
                  SizedBox(height: 4.h),
                  Text('$done of 3 meals logged today', style: bodyStyle(13)),
                  SizedBox(height: 12.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: LinearProgressIndicator(
                      value: done / 3,
                      minHeight: 10.h,
                      backgroundColor: kMintBg,
                      valueColor: const AlwaysStoppedAnimation(kGreen),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class MealProgressScreen extends StatelessWidget {
  const MealProgressScreen({super.key});

  Widget _stat(String label, String value, IconData icon) => Expanded(
    child: InsightCard(
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kGreen, size: 22.sp),
          SizedBox(height: 8.h),
          Text(value, style: headStyle(17)),
          SizedBox(height: 2.h),
          Text(label, style: bodyStyle(12)),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final c = MealPlanController.to;
    return InsightScaffold(
      title: 'Your Progress',
      titleIcon: Icons.insights_rounded,
      body: Column(
        children: [
          SizedBox(height: 8.h),
          SizedBox(
            width: 170.w,
            height: 170.w,
            child: CustomPaint(
              painter: _RingPainter(12 / 30),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('12/30', style: headStyle(28)),
                    Text('days', style: bodyStyle(13)),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 18.h),
          Obx(
            () => Row(
              children: [
                _stat(
                  'Meals Logged',
                  '${27 + c.completedCount}/90',
                  Icons.restaurant_rounded,
                ),
                SizedBox(width: 12.w),
                _stat(
                  'Current Streak',
                  '5 Days',
                  Icons.local_fire_department_rounded,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          InsightCard(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overall Plan Progress',
                      style: headStyle(14, weight: FontWeight.w700),
                    ),
                    Text('40%', style: headStyle(14, color: kGreen)),
                  ],
                ),
                SizedBox(height: 10.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: LinearProgressIndicator(
                    value: 0.4,
                    minHeight: 10.h,
                    backgroundColor: kMintBg,
                    valueColor: const AlwaysStoppedAnimation(kGreen),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          const TipBanner(
            icon: Icons.format_quote_rounded,
            text: 'Daily Wisdom: Small, consistent choices create lasting change.',
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 14.0;
    final rect = Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);
    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = kMintBg;
    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..color = kGreen;
    canvas.drawArc(rect, 0, math.pi * 2, false, bg);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}
