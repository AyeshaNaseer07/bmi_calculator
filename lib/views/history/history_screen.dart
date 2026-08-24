import 'package:flutter/cupertino.dart';
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
import '../widgets/custom_gradient_button.dart';
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
                  borderRadius: 22.r,
                  padding: EdgeInsets.all(18.w),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36.w,
                            height: 36.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD3F4EA),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.trending_up,
                              color: const Color(0xFF0F766E),
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Progress',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Keep tracking to reach\nyour health goals.',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColors.textLight,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Graphic clipboard
                          Container(
                            width: 54.w,
                            height: 54.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F7F2),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Icon(
                              Icons.assignment_turned_in_outlined,
                              color: const Color(0xFF1DB59B),
                              size: 32.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10.h,
                          horizontal: 8.w,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FAF6),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryItem(
                              value: '${records.length}',
                              subtitle: 'Total',
                              label: 'Records',
                              valueColor: const Color(0xFF0F766E),
                            ),
                            _buildDivider(),
                            _buildSummaryItem(
                              value: hasRecords
                                  ? records.first.bmiValue.toStringAsFixed(1)
                                  : '0.0',
                              subtitle: hasRecords
                                  ? records.first.category.label
                                  : 'None',
                              label: 'BMI',
                              valueColor: const Color(0xFF1DB59B),
                            ),
                            _buildDivider(),
                            _buildSummaryItem(
                              value: hasRecords
                                  ? records.first.bmiValue.toStringAsFixed(1)
                                  : '0.0',
                              subtitle: 'Today',
                              label: 'Latest',
                              valueColor: const Color(0xFF0F766E),
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
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openCalendar(context),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4EFE6),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          CupertinoIcons.calendar,
                          size: 16.sp,
                          color: const Color(0xFF0F766E),
                        ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayStr,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1DB59B),
                  ),
                ),
                Text(
                  monthYearStr,
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),

            // BMI value column
            Column(
              children: [
                Text(
                  'BMI',
                  style: TextStyle(fontSize: 10.sp, color: AppColors.textLight),
                ),
                SizedBox(height: 2.h),
                Text(
                  record.bmiValue.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ],
            ),

            // Weight value column
            Column(
              children: [
                Text(
                  'Weight',
                  style: TextStyle(fontSize: 10.sp, color: AppColors.textLight),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${record.weightKg.toStringAsFixed(1)}kg',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
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
    required String value,
    required String subtitle,
    required String label,
    required Color valueColor,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: AppColors.textLight),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
            color: valueColor,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(fontSize: 9.sp, color: AppColors.textLight),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 32.h, width: 1.w, color: const Color(0xFFD4EFE6));
  }

  Widget _buildEmptyHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top empty card with clipboard graphic
        CustomCard(
          borderRadius: 22.r,
          padding: EdgeInsets.all(18.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD3F4EA),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.history,
                        color: const Color(0xFF0F766E),
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'No records yet',
                      style: TextStyle(
                        fontSize: 14.sp,
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
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: 140.w,
                      child: CustomGradientButton(
                        text: 'Calculate BMI',
                        solidColor: const Color(0xFF1B8A7A),
                        height: 36.h,
                        onPressed: () => Get.toNamed(AppRoutes.bmiCalculator),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 90.w,
                height: 90.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F7F2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  Icons.assignment_turned_in_outlined,
                  color: const Color(0xFF1DB59B),
                  size: 48.sp,
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
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: const BoxDecoration(
                  color: Color(0xFFD3F4EA),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.trending_up,
                  color: const Color(0xFF0F766E),
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Your BMI history helps you understand your health journey over time and stay on track with your goals.',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textBody,
                    height: 1.35,
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
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: const Color(0xFF1DB59B),
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1DB59B).withValues(alpha: 0.3),
                blurRadius: 10.r,
                offset: Offset(0, 4.h),
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
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Get advanced insights, reports &\nmore',
                      style: TextStyle(color: Colors.white70, fontSize: 10.sp, height: 1.2),
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
                  style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700),
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
            child: Icon(
              icon,
              color: const Color(0xFF1DB59B),
              size: 18.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
