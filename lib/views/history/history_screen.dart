import 'package:bmi_calculator/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/bmi_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../data/models/bmi_record_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_card.dart';
import 'widgets/calendar_bottom_sheet.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _selectedDate = DateTime.now();

  void _openCalendar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CalendarBottomSheet(
        selectedDate: _selectedDate,
        onDateSelected: (date) {
          setState(() => _selectedDate = date);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final BMIController bmiController = Get.find<BMIController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: const CustomAppBar(title: 'History'),
      body: SafeArea(
        child: Obx(() {
          final records = bmiController.bmiHistory;
          final hasRecords = records.isNotEmpty;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top "Your Progress" Card
                CustomCard(
                  borderRadius: 24.r,
                  padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
                  shadows: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 18.r,
                      offset: Offset(0, 4.h),
                    ),
                    BoxShadow(
                      color: const Color(0xFF1DB59B).withValues(alpha: 0.05),
                      blurRadius: 12.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            AppAssets.historyUp,
                            width: 32.w,
                            height: 32.h,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Progress',
                                  style: TextStyle(
                                    color: const Color(0xFF111827),
                                    fontSize: 15,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                Opacity(
                                  opacity: 0.71,
                                  child: Text(
                                    'Keep tracking to reach \nyour health goals.',
                                    style: TextStyle(
                                      color: const Color(0xFF111827),
                                      fontSize: 11,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Graphic clipboard
                          SizedBox(
                            width: 98.w,
                            height: 98.h,
                            child: OverflowBox(
                              maxWidth: 190.w,
                              maxHeight: 190.h,
                              child: Image.asset(
                                AppAssets.historyIcon,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 14.h,
                          horizontal: 8.w,
                        ),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFF0F9F8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildSummaryItem(
                                label: 'Records',
                                value: '${records.length}',
                                subtitle: 'Total',
                              ),
                            ),
                            _buildDivider(),
                            Expanded(
                              child: _buildSummaryItem(
                                label: 'BMI',
                                value: hasRecords
                                    ? records.first.bmiValue.toStringAsFixed(1)
                                    : '22.5',
                                subtitle: hasRecords
                                    ? records.first.category.label
                                    : 'Normal',
                              ),
                            ),
                            _buildDivider(),
                            Expanded(
                              child: _buildSummaryItem(
                                label: 'Latest',
                                value: hasRecords
                                    ? records.first.bmiValue.toStringAsFixed(1)
                                    : '23.4',
                                subtitle: hasRecords
                                    ? _getLatestSubtitle(records.first.date)
                                    : 'Today',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // BMI History Header with Calendar Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'BMI History',
                      style: TextStyle(
                        color: const Color(0xFF111827),
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openCalendar(context),
                      child: Image.asset(
                        AppAssets.historyCalander,
                        width: 32.w,
                        height: 32.h,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // List of Records or Empty State
                if (hasRecords)
                  ...records.map((record) => _buildHistoryRow(record))
                else ...[
                  _buildEmptyHistorySection(),
                ],

                SizedBox(height: 24.h),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHistoryRow(BMIRecord record) {
    final dayStr = DateFormat('dd').format(record.date);
    final monthYearStr = DateFormat('MMM yyyy').format(record.date);
    final isNormal = record.category == BMICategory.normal;
    final statusColor = isNormal
        ? const Color(0xFF1DB59B)
        : const Color(0xFFEF4444);

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FAF6),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2F3ED)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Date column
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  dayStr,
                  style: TextStyle(
                    color: const Color(0xFF33D2AB),
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  monthYearStr,
                  style: TextStyle(
                    color: const Color(0xFF111827).withValues(alpha: 0.44),
                    fontSize: 8,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            // BMI value column
            Column(
              children: [
                Text(
                  'BMI',
                  style: TextStyle(
                    color: const Color(0xFF111827).withValues(alpha: .62),
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  record.bmiValue.toStringAsFixed(1),
                  style: TextStyle(
                    color: const Color(0xFF33D2AB),
                    fontSize: 13,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            // Weight value column
            Column(
              children: [
                Text(
                  'Weight',
                  style: TextStyle(
                    color: const Color(0xFF111827).withValues(alpha: .62),
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${record.weightKg.toStringAsFixed(1)}kg',
                  style: TextStyle(
                    color: const Color(0xFF33D2AB),
                    fontSize: 13,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            // Status label
            Text(
              record.category.label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required String subtitle,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF111827),
            fontSize: 13,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF33D2AB),
            fontSize: 20,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          subtitle,
          style: TextStyle(
            color: const Color(0xFF111827).withValues(alpha: .44),
            fontSize: 8,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 38.h, width: 1.w, color: const Color(0xFFD1E7DD));
  }

  String _getLatestSubtitle(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    return DateFormat('MMM d').format(date);
  }

  Widget _buildEmptyHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top empty card with clipboard graphic
        CustomCard(
          borderRadius: 22.r,
          padding: EdgeInsets.fromLTRB(18.w, 18.h, 0, 18.h),
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16.r,
              offset: Offset(0, 4.h),
            ),
            BoxShadow(
              color: const Color(0xFF1DB59B).withValues(alpha: 0.06),
              blurRadius: 12.r,
              offset: Offset(0, 2.h),
            ),
          ],
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Circular history icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppAssets.historyRestart,
                          width: 36.w,
                          height: 36.w,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(
                          width: 12.w,
                        ), // Add spacing between image and text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'No records yet',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Calculate your BMI to see\nyour history here.',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColors.textLight,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.bmiCalculator),
                      child: Container(
                        width: 117,
                        height: 36,
                        decoration: ShapeDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(0.50, 0.00),
                            end: Alignment(0.50, 1.00),
                            colors: [
                              const Color(0xFF33D2AB),
                              const Color(0xFF00946F),
                            ],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Calculate BMI',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // BMI illustration — overflows card edge like in the image
              SizedBox(
                width: 110.w,
                height: 110.w,
                child: OverflowBox(
                  maxWidth: 160.w,
                  maxHeight: 160.w,
                  child: Image.asset(
                    AppAssets.historyIcon,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 18.h),

        // About History Section
        Text(
          'About History',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FAF6),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE2F3ED)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(AppAssets.historyUp, height: 30.h, width: 30.w),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Your BMI history helps you understand your health journey over time and stay on track with your goals.',
                  style: TextStyle(
                    color: const Color(0xFF111827),
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 18.h),

        // What you'll see here Section
        Text(
          "What you'll see here",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 10.h),
        _buildFeatureItem(
          icon: Icons.trending_up,
          title: 'BMI',
          subtitle: 'See how your BMI changes over time.',
        ),
        SizedBox(height: 8.h),
        _buildFeatureItem(
          icon: Icons.shopping_bag_outlined,
          title: 'Weight Records',
          subtitle: 'Track your weight history.',
        ),
        SizedBox(height: 8.h),
        _buildFeatureItem(
          icon: Icons.flag_outlined,
          title: 'Goal Progress',
          subtitle: 'Monitor your progress towards your goals.',
        ),
        SizedBox(height: 20.h),

        // Unlock Premium Banner (Screenshot 19)
        Container(
          width: 343,
          padding: const EdgeInsets.all(20),
          decoration: ShapeDecoration(
            color: const Color(0xFFFDFDFE),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            shadows: [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                color: const Color(0xFFFFD700),
                size: 26.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unlock Premium',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Get advanced insights, reports &\nmore',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10.sp,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => Get.toNamed(AppRoutes.paywall),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1DB59B),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                ),
                child: Text(
                  'Go Premium',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FAF6),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2F3ED)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF1DB59B), size: 18.sp),
          ),
          SizedBox(width: 14.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
