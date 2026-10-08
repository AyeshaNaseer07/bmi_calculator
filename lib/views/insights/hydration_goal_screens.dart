import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_assets.dart';
import 'insight_common.dart';

const Color _kDeep = Color(0xFF006B4E);
const Color _kSub = Color(0xFF6B7280);

/// "Your Daily Goal" with a tappable 8-glass tracker.
class DailyGoalScreen extends StatefulWidget {
  const DailyGoalScreen({super.key});

  @override
  State<DailyGoalScreen> createState() => _DailyGoalScreenState();
}

class _DailyGoalScreenState extends State<DailyGoalScreen> {
  int _glasses = 5;

  Widget _glass(int n) {
    final on = n <= _glasses;
    final current = n == _glasses;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _glasses = n == _glasses ? n - 1 : n),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          padding: EdgeInsets.symmetric(vertical: 6.h),
          decoration: BoxDecoration(
            color: on ? const Color(0xFFE9FBF3) : const Color(0xFFF4F6F9),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: on
                  ? (current ? kGreen : const Color(0xFFA8EBD0))
                  : const Color(0xFFE3E8EE),
              width: current ? 1.8 : 1.1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                on ? AppAssets.glassFull : AppAssets.glassEmpty,
                width: 20.w,
                height: 26.h,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 3.h),
              Text(
                '$n',
                style: bodyStyle(
                  11.5,
                  color: on ? _kDeep : const Color(0xFF9CA3AF),
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tipRow(Color tile, IconData icon, Color ic, String lead, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(color: tile, shape: BoxShape.circle),
            child: Icon(icon, size: 18.sp, color: ic),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$lead: ',
                    style: bodyStyle(13, color: kInk, weight: FontWeight.w800),
                  ),
                  TextSpan(
                    text: text,
                    style: bodyStyle(
                      12,
                      color: const Color(0xFF4B5563),
                      weight: FontWeight.w500,
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

  @override
  Widget build(BuildContext context) {
    return InsightScaffold(
      title: 'Your Daily Goal',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F33D2AB),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: Image.asset(
                AppAssets.waterGoalBanner,
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: const Color(0xFFDDF4EC)),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Daily Water\nIntake',
                      style: headStyle(17, weight: FontWeight.w700)
                          .copyWith(height: 1.15),
                    ),
                    SizedBox(width: 10.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F8F1),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: const Color(0xFFBFEBDA)),
                      ),
                      child: Text(
                        'RECOMMENDED',
                        style: bodyStyle(
                          11,
                          color: _kDeep,
                          weight: FontWeight.w700,
                        ).copyWith(letterSpacing: 0.4),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$_glasses / 8\nGlasses',
                      textAlign: TextAlign.left,
                      style: bodyStyle(
                        15,
                        color: kGreen,
                        weight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  'Your water needs depend on your activity, weather and '
                  'health.',
                  style: bodyStyle(14, color: _kSub, height: 1.3),
                ),
                SizedBox(height: 12.h),
                Row(children: [for (int i = 1; i <= 8; i++) _glass(i)]),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFD3F3E8),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: Container(
                    width: 7.w,
                    height: 7.w,
                    decoration: const BoxDecoration(
                      color: kGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Daily Water Intake: ',
                          style: bodyStyle(
                            12.5,
                            color: kInk,
                            weight: FontWeight.w800,
                          ),
                        ),
                        TextSpan(
                          text: 'Needs vary by activity, climate, and body '
                              'composition.',
                          style: bodyStyle(
                            12.5,
                            color: kInk,
                            weight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 4.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: const Color(0xFFD5F2E8), width: 1.4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F33D2AB),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EASY WAYS TO STAY HYDRATED',
                  style: bodyStyle(
                    12,
                    color: const Color(0xFF8A94A6),
                    weight: FontWeight.w700,
                  ).copyWith(letterSpacing: 1.0),
                ),
                SizedBox(height: 12.h),
                _tipRow(
                  const Color(0xFFFFF1C9),
                  Icons.wb_sunny_outlined,
                  const Color(0xFFE0A100),
                  'Start Your Morning',
                  'Drink a glass right after waking up.',
                ),
                _tipRow(
                  const Color(0xFFDCE9FD),
                  Icons.water_drop_outlined,
                  const Color(0xFF3B82F6),
                  'Drink Throughout the Day',
                  'Sip regularly instead of all at once.',
                ),
                _tipRow(
                  const Color(0xFFD9F5E5),
                  Icons.eco_outlined,
                  kGreen,
                  'Listen to Your Body',
                  'Drink when thirsty; adjust for activity.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
