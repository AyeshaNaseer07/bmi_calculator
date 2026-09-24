import 'package:bmi_calculator/core/constants/app_assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/bmi_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../data/models/bmi_record_model.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_card.dart';
import 'widgets/calendar_bottom_sheet.dart';

enum HistorySortOption {
  newest('Newest First (Date)'),
  oldest('Oldest First (Date)'),
  bmiHighest('Highest BMI'),
  bmiLowest('Lowest BMI');

  final String label;
  const HistorySortOption(this.label);
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime? _selectedDate;
  HistorySortOption _currentSort = HistorySortOption.newest;
  bool _isSelectionMode = false;
  final Set<String> _selectedRecordIds = <String>{};

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

  void _confirmDeleteSingle(BuildContext context, BMIRecord record) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        backgroundColor: Colors.white,
        title: Text(
          'Delete Record?',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
            fontFamily: 'Inter',
          ),
        ),
        content: Text(
          'Are you sure you want to delete this BMI record from ${DateFormat('dd MMM yyyy').format(record.date)}?',
          style: TextStyle(
            fontSize: 13.sp,
            color: const Color(0xFF64748B),
            fontFamily: 'Inter',
          ),
        ),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    final bmiController = Get.find<BMIController>();
                    bmiController.deleteRecord(record.id);
                    setState(() {
                      _selectedRecordIds.remove(record.id);
                      if (bmiController.bmiHistory.isEmpty) {
                        _isSelectionMode = false;
                      }
                    });
                    Get.snackbar(
                      'Deleted',
                      'Record deleted successfully',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF0F172A),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                      margin: EdgeInsets.all(16.w),
                      borderRadius: 12.r,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF09B389),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSelected(BuildContext context) {
    final count = _selectedRecordIds.length;
    if (count == 0) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        backgroundColor: Colors.white,
        title: Text(
          'Delete Records?',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
            fontFamily: 'Inter',
          ),
        ),
        content: Text(
          'Are you sure you want to delete $count selected history record${count > 1 ? 's' : ''}? This action cannot be undone.',
          style: TextStyle(
            fontSize: 13.sp,
            color: const Color(0xFF64748B),
            fontFamily: 'Inter',
          ),
        ),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    final bmiController = Get.find<BMIController>();
                    bmiController.deleteMultipleRecords(_selectedRecordIds);
                    setState(() {
                      _selectedRecordIds.clear();
                      _isSelectionMode = false;
                    });
                    Get.snackbar(
                      'Deleted',
                      '$count record${count > 1 ? 's' : ''} deleted successfully',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF0F172A),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                      margin: EdgeInsets.all(16.w),
                      borderRadius: 12.r,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF09B389),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sort BMI History',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                    fontFamily: 'Inter',
                  ),
                ),
                if (_currentSort != HistorySortOption.newest)
                  TextButton(
                    onPressed: () {
                      setState(() => _currentSort = HistorySortOption.newest);
                      Navigator.pop(ctx);
                    },
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF09B389),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            ...HistorySortOption.values.map((option) {
              final isSelected = _currentSort == option;
              return GestureDetector(
                onTap: () {
                  setState(() => _currentSort = option);
                  Navigator.pop(ctx);
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFF0FAF6)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF09B389)
                          : const Color(0xFFE2E8F0),
                      width: 1.w,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        option.label,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF0F766E)
                              : const Color(0xFF1E293B),
                          fontFamily: 'Inter',
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          color: const Color(0xFF09B389),
                          size: 18.sp,
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final BMIController bmiController = Get.find<BMIController>();

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(title: 'History'),
        body: SafeArea(
          child: Obx(() {
            final allRecords = bmiController.bmiHistory;
            final hasRecords = allRecords.isNotEmpty;

            // Apply Date Filter
            List<BMIRecord> displayedRecords = List<BMIRecord>.from(allRecords);
            if (_selectedDate != null) {
              displayedRecords = displayedRecords
                  .where(
                    (r) =>
                        r.date.year == _selectedDate!.year &&
                        r.date.month == _selectedDate!.month &&
                        r.date.day == _selectedDate!.day,
                  )
                  .toList();
            }

            // Apply Sorting
            switch (_currentSort) {
              case HistorySortOption.newest:
                displayedRecords.sort((a, b) => b.date.compareTo(a.date));
                break;
              case HistorySortOption.oldest:
                displayedRecords.sort((a, b) => a.date.compareTo(b.date));
                break;
              case HistorySortOption.bmiHighest:
                displayedRecords.sort(
                  (a, b) => b.bmiValue.compareTo(a.bmiValue),
                );
                break;
              case HistorySortOption.bmiLowest:
                displayedRecords.sort(
                  (a, b) => a.bmiValue.compareTo(b.bmiValue),
                );
                break;
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasRecords) ...[
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
                          color: const Color(0xFF09B389)
                              .withValues(alpha: 0.05),
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
                                    value: '${allRecords.length}',
                                    subtitle: 'Total',
                                  ),
                                ),
                                _buildDivider(),
                                Expanded(
                                  child: _buildSummaryItem(
                                    label: 'BMI',
                                    value: allRecords.first.bmiValue
                                        .toStringAsFixed(1),
                                    subtitle: allRecords.first.category.label,
                                  ),
                                ),
                                _buildDivider(),
                                Expanded(
                                  child: _buildSummaryItem(
                                    label: 'Latest',
                                    value: allRecords.first.bmiValue
                                        .toStringAsFixed(1),
                                    subtitle: _getLatestSubtitle(
                                      allRecords.first.date,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // BMI History Header with Selection / Actions
                    if (_isSelectionMode)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Select All Checkbox & Label
                            GestureDetector(
                              onTap: () {
                                final allSelected =
                                    displayedRecords.isNotEmpty &&
                                    displayedRecords.every(
                                      (r) => _selectedRecordIds.contains(r.id),
                                    );
                                setState(() {
                                  if (allSelected) {
                                    _selectedRecordIds.clear();
                                  } else {
                                    _selectedRecordIds.addAll(
                                      displayedRecords.map((r) => r.id),
                                    );
                                  }
                                });
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 22.w,
                                    height: 22.w,
                                    decoration: BoxDecoration(
                                      color:
                                          (displayedRecords.isNotEmpty &&
                                              displayedRecords.every(
                                                (r) => _selectedRecordIds
                                                    .contains(r.id),
                                              ))
                                          ? const Color(0xFF09B389)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(6.r),
                                      border: Border.all(
                                        color:
                                            (displayedRecords.isNotEmpty &&
                                                displayedRecords.every(
                                                  (r) => _selectedRecordIds
                                                      .contains(r.id),
                                                ))
                                            ? const Color(0xFF09B389)
                                            : const Color(0xFFCBD5E1),
                                        width: 1.5.w,
                                      ),
                                    ),
                                    child:
                                        (displayedRecords.isNotEmpty &&
                                            displayedRecords.every(
                                              (r) => _selectedRecordIds
                                                  .contains(r.id),
                                            ))
                                        ? Icon(
                                            Icons.check,
                                            size: 14.sp,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Select All',
                                    style: TextStyle(
                                      color: const Color(0xFF0F172A),
                                      fontSize: 13.sp,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (_selectedRecordIds.isNotEmpty) ...[
                                    SizedBox(width: 6.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF09B389),
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                      ),
                                      child: Text(
                                        '${_selectedRecordIds.length}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Actions: Delete and Cancel
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: _selectedRecordIds.isNotEmpty
                                      ? () => _confirmDeleteSelected(context)
                                      : null,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _selectedRecordIds.isNotEmpty
                                          ? const Color(0xFF09B389)
                                          : const Color(0xFFCBD5E1)
                                                .withValues(alpha: 0.99),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          CupertinoIcons.trash,
                                          size: 13.sp,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          'Delete',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isSelectionMode = false;
                                      _selectedRecordIds.clear();
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: const Color(0xFF64748B),
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    else
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
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Selection / Delete mode button
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isSelectionMode = true;
                                    _selectedRecordIds.clear();
                                  });
                                },
                                child: Container(
                                  width: 32.w,
                                  height: 32.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                      width: 1.w,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.04,
                                        ),
                                        blurRadius: 4.r,
                                        offset: Offset(0, 1.h),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      CupertinoIcons.trash,
                                      size: 15.sp,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),

                              // Sort action button
                              GestureDetector(
                                onTap: () => _showSortOptions(context),
                                child: Container(
                                  width: 32.w,
                                  height: 32.h,
                                  decoration: BoxDecoration(
                                    color:
                                        _currentSort != HistorySortOption.newest
                                        ? const Color(0xFFE8F7F2)
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          _currentSort !=
                                              HistorySortOption.newest
                                          ? const Color(0xFF09B389)
                                          : const Color(0xFFE2E8F0),
                                      width: 1.w,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.04,
                                        ),
                                        blurRadius: 4.r,
                                        offset: Offset(0, 1.h),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.sort_rounded,
                                      size: 17.sp,
                                      color:
                                          _currentSort !=
                                              HistorySortOption.newest
                                          ? const Color(0xFF09B389)
                                          : const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),

                              // Calendar filter button with active dot indicator
                              GestureDetector(
                                onTap: () => _openCalendar(context),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Image.asset(
                                      AppAssets.historyCalander,
                                      width: 32.w,
                                      height: 32.h,
                                    ),
                                    if (_selectedDate != null)
                                      Positioned(
                                        top: -1.h,
                                        right: -1.w,
                                        child: Container(
                                          width: 9.w,
                                          height: 9.w,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF09B389),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.5.w,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                    // Active Date Filter Chip
                    if (_selectedDate != null) ...[
                      SizedBox(height: 10.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F7F2),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: const Color(0xFFC4ECE0),
                            width: 1.w,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.calendar,
                              size: 13.sp,
                              color: const Color(0xFF0F766E),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'Date: ${DateFormat('dd MMM yyyy').format(_selectedDate!)}',
                              style: TextStyle(
                                color: const Color(0xFF0F766E),
                                fontSize: 12.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            GestureDetector(
                              onTap: () => setState(() => _selectedDate = null),
                              child: Container(
                                padding: EdgeInsets.all(2.r),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 12.sp,
                                  color: const Color(0xFF0F766E),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: 12.h),

                    // List of Records or Filtered Empty State
                    if (displayedRecords.isNotEmpty)
                      ...displayedRecords.map(
                        (record) => _buildHistoryRow(record),
                      )
                    else
                      _buildNoFilterResultsSection(),
                  ] else ...[
                    // Empty State UI
                    _buildEmptyHistorySection(),
                  ],

                  SizedBox(height: 24.h),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildNoFilterResultsSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
      margin: EdgeInsets.only(top: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.calendar_today,
            size: 36.sp,
            color: const Color(0xFF94A3B8),
          ),
          SizedBox(height: 10.h),
          Text(
            'No records for this date',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
              fontFamily: 'Inter',
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            _selectedDate != null
                ? DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate!)
                : '',
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF64748B),
              fontFamily: 'Inter',
            ),
          ),
          SizedBox(height: 14.h),
          GestureDetector(
            onTap: () => setState(() => _selectedDate = null),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFF09B389),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Show All Records',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(BMIRecord record) {
    final isSelected = _selectedRecordIds.contains(record.id);
    final dayStr = DateFormat('dd').format(record.date);
    final monthYearStr = DateFormat('MMM yyyy').format(record.date);
    final isNormal = record.category == BMICategory.normal;
    final statusColor = isNormal
        ? const Color(0xFF09B389)
        : const Color(0xFFEF4444);

    final cardContent = GestureDetector(
      onTap: () {
        if (_isSelectionMode) {
          setState(() {
            if (isSelected) {
              _selectedRecordIds.remove(record.id);
            } else {
              _selectedRecordIds.add(record.id);
            }
          });
        }
      },
      onLongPress: () {
        if (!_isSelectionMode) {
          setState(() {
            _isSelectionMode = true;
            _selectedRecordIds.add(record.id);
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE6F7F2) : const Color(0xFFF0FAF6),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF09B389)
                : const Color(0xFFE2F3ED),
            width: isSelected ? 1.5.w : 1.w,
          ),
        ),
        child: Row(
          children: [
            // Selection Checkbox
            if (_isSelectionMode) ...[
              Container(
                width: 20.w,
                height: 20.w,
                margin: EdgeInsets.only(right: 10.w),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF09B389) : Colors.white,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF09B389)
                        : const Color(0xFFCBD5E1),
                    width: 1.5.w,
                  ),
                ),
                child: isSelected
                    ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                    : null,
              ),
            ],

            // Date column
            SizedBox(
              width: 52.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    dayStr,
                    style: TextStyle(
                      color: const Color(0xFF33D2AB),
                      fontSize: 18.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    monthYearStr,
                    style: TextStyle(
                      color: const Color(0xFF111827).withValues(alpha: 0.55),
                      fontSize: 10.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // BMI value column
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'BMI',
                  style: TextStyle(
                    color: const Color(0xFF111827).withValues(alpha: .62),
                    fontSize: 11.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  record.bmiValue.toStringAsFixed(1),
                  style: TextStyle(
                    color: const Color(0xFF33D2AB),
                    fontSize: 13.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Weight value column
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Weight',
                  style: TextStyle(
                    color: const Color(0xFF111827).withValues(alpha: .62),
                    fontSize: 11.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${record.weightKg.toStringAsFixed(1)}kg',
                  style: TextStyle(
                    color: const Color(0xFF33D2AB),
                    fontSize: 13.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Status label
            Text(
              record.category.label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),

            // Delete Specific History icon button (when not in selection mode)
            if (!_isSelectionMode) ...[
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => _confirmDeleteSingle(context, record),
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  child: Icon(
                    CupertinoIcons.trash,
                    size: 15.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: _isSelectionMode
          ? cardContent
          : Dismissible(
              key: Key(record.id),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) async {
                _confirmDeleteSingle(context, record);
                return false;
              },
              background: Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.trash,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              child: cardContent,
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
              color: const Color(0xFF09B389).withValues(alpha: 0.06),
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
                  foregroundColor: const Color(0xFF09B389),
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
            child: Icon(icon, color: const Color(0xFF09B389), size: 18.sp),
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
