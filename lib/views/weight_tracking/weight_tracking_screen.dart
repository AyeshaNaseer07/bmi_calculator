import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/weight_tracker_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_gradient_button.dart';

class WeightTrackingScreen extends StatelessWidget {
  const WeightTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WeightTrackerController controller =
        Get.find<WeightTrackerController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: const CustomAppBar(title: 'Weight Tracking'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
          child: Obx(() {
            final current = controller.currentWeight.value;
            final goal = controller.goalWeight.value;
            final timeframe = controller.selectedTimeframe.value;
            final spots = controller.getSpots();
            final xLabels = controller.getXAxisLabels();

            final hasRecords = controller.weightHistory.isNotEmpty;
            final currentStr = hasRecords ? '${current.toStringAsFixed(1)}kg' : '00.0kg';
            final goalStr = hasRecords ? '${goal.toStringAsFixed(1)}kg' : '00.0kg';
            final centerValStr = hasRecords ? current.toStringAsFixed(1) : '00.0';
            final progressVal = hasRecords && goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;

            final pWeek = controller.progressThisWeek.value;
            final pMonth = controller.progressThisMonth.value;
            final pTotal = controller.progressTotal.value;
            final weekStr = pWeek == 0.0 ? '-0.0kg' : '${pWeek > 0 ? '+' : ''}${pWeek.toStringAsFixed(1)}kg';
            final monthStr = pMonth == 0.0 ? '-0.0kg' : '${pMonth > 0 ? '+' : ''}${pMonth.toStringAsFixed(1)}kg';
            final totalStr = pTotal == 0.0 ? '-0.0kg' : '${pTotal > 0 ? '+' : ''}${pTotal.toStringAsFixed(1)}kg';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Weight Ring Summary Card
                CustomCard(
                  borderRadius: 22.r,
                  padding: EdgeInsets.all(18.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Current Weight
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current weight',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textLight,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            currentStr,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1DB59B),
                            ),
                          ),
                        ],
                      ),

                      // Center Ring Gauge
                      SizedBox(
                        width: 90.w,
                        height: 90.w,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 80.w,
                              height: 80.w,
                              child: CircularProgressIndicator(
                                value: progressVal,
                                strokeWidth: 8.w,
                                backgroundColor: const Color(0xFFE8F7F2),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF1DB59B),
                                ),
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.scale_outlined,
                                  size: 16.sp,
                                  color: const Color(0xFF1DB59B),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  centerValStr,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  'kg',
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Goal Weight
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Goal weight',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textLight,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            goalStr,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1DB59B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),

                // Add Weight CTA Button
                CustomGradientButton(
                  text: 'Add Weight',
                  leadingIcon: Icon(
                    CupertinoIcons.plus_circle,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                  solidColor: const Color(0xFF1B8A7A),
                  onPressed: () => Get.toNamed(AppRoutes.addWeight),
                ),
                SizedBox(height: 16.h),

                // Weight Progress Card with Chart
                CustomCard(
                  borderRadius: 22.r,
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Title & Timeframe Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Weight Progress',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F7F2),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              children: ['week', 'Month', 'Year'].map((tab) {
                                final isSelected = timeframe == tab;
                                return GestureDetector(
                                  onTap: () => controller.setTimeframe(tab),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8.r),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.04),
                                                blurRadius: 4.r,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Text(
                                      tab,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? const Color(0xFF1DB59B)
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // FL Chart Container
                      SizedBox(
                        height: 170.h,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 22.h,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index >= 0 && index < xLabels.length) {
                                      return Padding(
                                        padding: EdgeInsets.only(top: 6.h),
                                        child: Text(
                                          xLabels[index],
                                          style: TextStyle(
                                            fontSize: 9.sp,
                                            color: const Color(0xFF64748B),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 24.w,
                                  interval: 2,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: TextStyle(
                                        fontSize: 9.sp,
                                        color: const Color(0xFF94A3B8),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border(
                                bottom: BorderSide(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1.w,
                                ),
                                left: BorderSide(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1.w,
                                ),
                              ),
                            ),
                            minX: 0,
                            maxX: (xLabels.length - 1).toDouble(),
                            minY: 66,
                            maxY: 74,
                            lineBarsData: spots.isEmpty
                                ? []
                                : [
                                    LineChartBarData(
                                      spots: spots,
                                      isCurved: true,
                                      color: const Color(0xFF2FD1A6),
                                      barWidth: 2.5.w,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(
                                        show: true,
                                        getDotPainter:
                                            (spot, percent, barData, index) {
                                              final isLast =
                                                  index == spots.length - 1;
                                              return FlDotCirclePainter(
                                                radius: isLast ? 4.r : 3.r,
                                                color: Colors.white,
                                                strokeWidth: 2.w,
                                                strokeColor: isLast
                                                    ? const Color(0xFF1DB59B)
                                                    : const Color(0xFF2FD1A6),
                                              );
                                            },
                                      ),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF2FD1A6).withValues(alpha: 0.3),
                                            const Color(0xFF2FD1A6).withValues(alpha: 0.0),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Bottom Progress Metrics Summary
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 12.h,
                          horizontal: 8.w,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F7F2),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildProgressMetric(
                              value: weekStr,
                              label: 'This Week',
                            ),
                            _buildProgressDivider(),
                            _buildProgressMetric(
                              value: monthStr,
                              label: 'This Month',
                            ),
                            _buildProgressDivider(),
                            _buildProgressMetric(
                              value: totalStr,
                              label: 'Total Progress',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildProgressMetric({required String value, required String label}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: AppColors.textLight),
        ),
      ],
    );
  }

  Widget _buildProgressDivider() {
    return Container(height: 28.h, width: 1.w, color: const Color(0xFFD4EFE6));
  }
}
