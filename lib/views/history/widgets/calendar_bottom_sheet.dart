import 'package:bmi_calculator/core/constants/app_assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';

class CalendarBottomSheet extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const CalendarBottomSheet({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<CalendarBottomSheet> createState() => _CalendarBottomSheetState();
}

class _CalendarBottomSheetState extends State<CalendarBottomSheet> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;
  bool _showMonthDropdown = false;

  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _currentMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      1,
    );
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat('MMMM').format(_currentMonth);
    final year = _currentMonth.year;

    // Calculate calendar grid
    final daysInMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;
    final firstWeekday = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    ).weekday; // 1 = Mon, 7 = Sun
    final prevMonthDays = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      0,
    ).day;

    final startOffset = firstWeekday - 1;
    final totalDays = startOffset + daysInMonth;
    final totalRows = (totalDays / 7).ceil();
    final totalCells = totalRows * 7;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 28.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row: "Month Year >" and navigation chevrons
          Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Month & Year title with arrow
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showMonthDropdown = !_showMonthDropdown;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$monthName $year',
                          style: TextStyle(
                            color: const Color(0xFF111827),
                            fontSize: 15,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Image.asset(AppAssets.ageForward, height: 14.h),
                      ],
                    ),
                  ),

                  // Circular Prev / Next navigation buttons
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _previousMonth,
                        child: Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFF1F5F9),
                              width: 1.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 6.r,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(AppAssets.ageBack, height: 14.h),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: _nextMonth,
                        child: Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFF1F5F9),
                              width: 1.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 6.r,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              AppAssets.ageForward,
                              height: 14.h,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Month Selection Dropdown
              if (_showMonthDropdown)
                Positioned(
                  top: 36.h,
                  left: 0,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(14.r),
                    color: Colors.white,
                    child: Container(
                      width: 150.w,
                      height: 200.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: ListView.builder(
                        itemCount: _months.length,
                        itemBuilder: (context, idx) {
                          final isCurrent = idx + 1 == _currentMonth.month;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentMonth = DateTime(
                                  _currentMonth.year,
                                  idx + 1,
                                  1,
                                );
                                _showMonthDropdown = false;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 8.h,
                              ),
                              color: isCurrent
                                  ? const Color(0xFFF0FAF6)
                                  : Colors.transparent,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _months[idx],
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: isCurrent
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isCurrent
                                          ? AppColors.primaryTeal
                                          : AppColors.textDark,
                                    ),
                                  ),
                                  if (isCurrent)
                                    Icon(
                                      CupertinoIcons.checkmark,
                                      size: 12.sp,
                                      color: AppColors.primaryTeal,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 22.h),

          // Weekdays Row (Mo, Tu, We, Th, Fr, Sa, Su)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w500,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 14.h),

          // Days Grid (5 or 6 rows x 7 cols)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 10.h,
              crossAxisSpacing: 10.w,
              childAspectRatio: 1.0,
            ),
            itemCount: totalCells,
            itemBuilder: (context, index) {
              final dayOffset = index - startOffset;
              if (dayOffset < 0) {
                // Prev month days
                final prevDay = prevMonthDays + dayOffset + 1;
                return Center(
                  child: Text(
                    '$prevDay',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFCBD5E1),
                      fontFamily: 'Inter',
                    ),
                  ),
                );
              } else if (dayOffset >= daysInMonth) {
                // Next month days
                final nextDay = dayOffset - daysInMonth + 1;
                return Center(
                  child: Text(
                    '$nextDay',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFCBD5E1),
                      fontFamily: 'Inter',
                    ),
                  ),
                );
              }

              final currentDay = dayOffset + 1;
              final cellDate = DateTime(
                _currentMonth.year,
                _currentMonth.month,
                currentDay,
              );
              final isSelected =
                  cellDate.year == _selectedDate.year &&
                  cellDate.month == _selectedDate.month &&
                  cellDate.day == _selectedDate.day;

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedDate = cellDate);
                  widget.onDateSelected(cellDate);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2FD1A6) : Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: const Color(0xFFF1F5F9),
                            width: 1.w,
                          ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF2FD1A6)
                                  .withValues(alpha: 0.35),
                              blurRadius: 6.r,
                              offset: Offset(0, 2.h),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 4.r,
                              offset: Offset(0, 1.h),
                            ),
                          ],
                  ),
                  child: Center(
                    child: Text(
                      '$currentDay',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF0F172A),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
