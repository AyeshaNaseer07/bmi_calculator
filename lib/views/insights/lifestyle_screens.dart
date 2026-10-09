import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/activity_plan_controller.dart';
import '../../controllers/meal_plan_controller.dart';
import '../../core/constants/app_assets.dart';
import 'activity_plan_data.dart';
import 'insight_common.dart';

export 'sleep_screens.dart';

const Color _kDeep = Color(0xFF006B4E);
const Color _kLav = Color(0xFFE8EBFB);
const Color _kPill = Color(0xFF5CF2C0);

/// "Stay Active".
class StayActiveScreen extends StatelessWidget {
  const StayActiveScreen({super.key});

  Widget _row(
    String iconAsset,
    String title,
    String sub,
    String chip,
    bool all,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Get.to(() => const ActivityRoutineScreen()),
        child: Container(
          padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Image.asset(iconAsset, fit: BoxFit.contain, width: 38.w),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: headStyle(16, weight: FontWeight.w600),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: all ? _kLav : _kPill,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            chip,
                            style: bodyStyle(
                              11.5,
                              color: _kDeep,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: bodyStyle(
                        13,
                        color: const Color(0xFF4B5563),
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mc = MealPlanController.to;
    final today = ActivityPlanData.today(mc.category, mc.activity);
    return InsightScaffold(
      title: 'Stay Active',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              AppAssets.activeHero,
              width: 280.w,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 6.h),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: _kLav,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: const BoxDecoration(
                      color: _kDeep,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'STAY ACTIVE',
                    style: bodyStyle(
                      12,
                      color: _kDeep,
                      weight: FontWeight.w800,
                    ).copyWith(letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Center(
            child: Text(
              'Small movements, healthier habits.',
              style: bodyStyle(13.5, color: const Color(0xFF4B5563)),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'TODAY’S ACTIVITY',
            style: headStyle(15, weight: FontWeight.w800),
          ),
          SizedBox(height: 10.h),
          _row(
            AppAssets.easyWalkIcon,
            today.title,
            today.blurb,
            today.chip,
            false,
          ),
          _row(
            AppAssets.stretchBreakIcon,
            'Stretch Break',
            'Loosen up with a few gentle stretches.',
            '10 min',
            false,
          ),
          _row(
            AppAssets.dailyMovementIcon,
            'Daily Movement',
            'Stay active throughout the day. Take breaks.',
            'All-day',
            true,
          ),
          SizedBox(height: 6.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF9F4),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFC9F0DF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.eco_outlined, size: 16.sp, color: _kDeep),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'YOUR DAILY TIP',
                        style: bodyStyle(
                          12,
                          color: _kDeep,
                          weight: FontWeight.w800,
                        ).copyWith(letterSpacing: 0.3),
                      ),
                      Text(
                        ActivityPlanData.tipFor(mc.category),
                        style: bodyStyle(
                          13,
                          color: kInk,
                          weight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          const _SafetyNote(),
        ],
      ),
    );
  }
}

/// Short safety reminder shown under the activity screens.
class _SafetyNote extends StatelessWidget {
  const _SafetyNote();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Stop if you feel pain, dizziness or chest discomfort. Check with a '
      'doctor before starting if you have a heart or joint condition, are '
      'pregnant, or have not exercised in a long time.',
      style: bodyStyle(
        11,
        color: const Color(0xFF6B7280),
      ).copyWith(height: 1.4),
    );
  }
}

/// "Your Activity Routine" — weekly plan.
class ActivityRoutineScreen extends StatelessWidget {
  const ActivityRoutineScreen({super.key});

  Widget _pill(IconData i, String t) => Expanded(
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          Icon(i, size: 16.sp, color: _kDeep),
          SizedBox(height: 2.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              t,
              style: bodyStyle(12, color: _kDeep, weight: FontWeight.w800),
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final mc = MealPlanController.to;
    final ac = ActivityPlanController.to;
    final week = ActivityPlanData.weekFor(mc.category, mc.activity);
    final total = ActivityPlanData.weeklyMinutes(mc.category, mc.activity);
    return InsightScaffold(
      title: 'Your Activity Routine',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Obx(
              () => Text(
                '${ac.doneCount(week.map((d) => d.key))} of 7 days done  •  '
                '$total min this week',
                style: bodyStyle(13, color: _kDeep, weight: FontWeight.w700),
              ),
            ),
          ),
          for (final d in week)
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Container(
                padding: EdgeInsets.fromLTRB(10.w, 8.h, 12.w, 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(color: const Color(0xFFDDF4EC)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F33D2AB),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFFC8F7E4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(d.icon, size: 20.sp, color: _kDeep),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      d.dayLabel,
                      style: headStyle(15, weight: FontWeight.w800),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        d.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: bodyStyle(
                          15,
                          color: kInk,
                          weight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: _kLav,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        d.chip,
                        style: bodyStyle(
                          12,
                          color: _kDeep,
                          weight: FontWeight.w800,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => ac.toggle(d.key),
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Obx(() {
                          final done = ac.isDone(d.key);
                          return Container(
                            width: 22.w,
                            height: 22.w,
                            decoration: BoxDecoration(
                              color: done ? _kPill : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: done ? _kPill : const Color(0xFFD1D5DB),
                              ),
                            ),
                            child: done
                                ? Icon(
                                    Icons.check_rounded,
                                    size: 14.sp,
                                    color: _kDeep,
                                  )
                                : null,
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: 14.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(10.w, 12.h, 10.w, 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFD9FBEC),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 2.w),
                  child: Row(
                    children: [
                      Icon(Icons.eco_rounded, size: 18.sp, color: _kDeep),
                      SizedBox(width: 6.w),
                      Text(
                        'Stay Consistent',
                        style: headStyle(19, weight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    _pill(Icons.directions_walk_rounded, 'Walking breaks'),
                    _pill(Icons.water_drop_outlined, 'Drink water'),
                    _pill(Icons.nightlight_outlined, 'Enough sleep'),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          const _SafetyNote(),
        ],
      ),
    );
  }
}
