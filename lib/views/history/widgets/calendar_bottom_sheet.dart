import 'package:bmi_calculator/core/constants/app_assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CalendarBottomSheet extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;

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
  DateTime? _selectedDate;
  bool _isMonthYearPicker = false;

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
    final initialDate = widget.selectedDate ?? DateTime.now();
    _currentMonth = DateTime(initialDate.year, initialDate.month, 1);
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

  void _previousYear() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year - 1, _currentMonth.month, 1);
    });
  }

  void _nextYear() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year + 1, _currentMonth.month, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat('MMMM').format(_currentMonth);
    final year = _currentMonth.year;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header Row: Month Year title & Stepper buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Month & Year title button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isMonthYearPicker = !_isMonthYearPicker;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: _isMonthYearPicker
                        ? const Color(0xFFF0FAF6)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$monthName $year',
                        style: TextStyle(
                          color: _isMonthYearPicker
                              ? const Color(0xFF09B389)
                              : const Color(0xFF111827),
                          fontSize: 16.sp,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Icon(
                        _isMonthYearPicker
                            ? CupertinoIcons.chevron_up
                            : CupertinoIcons.chevron_down,
                        size: 14.sp,
                        color: _isMonthYearPicker
                            ? const Color(0xFF09B389)
                            : const Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),
              ),

              // Navigation Stepper Buttons
              Row(
                children: [
                  GestureDetector(
                    onTap: _isMonthYearPicker ? _previousYear : _previousMonth,
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
                    onTap: _isMonthYearPicker ? _nextYear : _nextMonth,
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
                        child: Image.asset(AppAssets.ageForward, height: 14.h),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 18.h),

          // Main Content: Month/Year Grid or Calendar Days Grid
          if (_isMonthYearPicker)
            _buildMonthYearSelector()
          else
            _buildCalendarDaysView(),

          SizedBox(height: 18.h),

          // Footer Action Bar: Clear Filter & Today buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_selectedDate != null)
                TextButton.icon(
                  onPressed: () {
                    widget.onDateSelected(null);
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    CupertinoIcons.clear_circled,
                    size: 15.sp,
                    color: const Color(0xFFEF4444),
                  ),
                  label: Text(
                    'Clear Filter',
                    style: TextStyle(
                      color: const Color(0xFFEF4444),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 6.h,
                    ),
                  ),
                )
              else
                Text(
                  'Tap a date to filter',
                  style: TextStyle(
                    color: const Color(0xFF94A3B8),
                    fontSize: 12.sp,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              TextButton(
                onPressed: () {
                  final today = DateTime.now();
                  widget.onDateSelected(today);
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF0FAF6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                ),
                child: Text(
                  'Today',
                  style: TextStyle(
                    color: const Color(0xFF09B389),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Month & Year Selector View (Zero overlapping!)
  Widget _buildMonthYearSelector() {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10.h,
            crossAxisSpacing: 10.w,
            childAspectRatio: 2.2,
          ),
          itemCount: 12,
          itemBuilder: (context, idx) {
            final isCurrentMonth = idx + 1 == _currentMonth.month;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentMonth = DateTime(_currentMonth.year, idx + 1, 1);
                  _isMonthYearPicker = false;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isCurrentMonth
                      ? const Color(0xFF2FD1A6)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: isCurrentMonth
                        ? const Color(0xFF2FD1A6)
                        : const Color(0xFFE2E8F0),
                    width: 1.w,
                  ),
                  boxShadow: isCurrentMonth
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2FD1A6)
                                .withValues(alpha: 0.3),
                            blurRadius: 6.r,
                            offset: Offset(0, 2.h),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    _months[idx],
                    style: TextStyle(
                      color: isCurrentMonth
                          ? Colors.white
                          : const Color(0xFF1E293B),
                      fontSize: 13.sp,
                      fontFamily: 'Inter',
                      fontWeight: isCurrentMonth
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Standard Calendar Days View
  Widget _buildCalendarDaysView() {
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
    final today = DateTime.now();

    return Column(
      children: [
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
                        color: const Color(0xFF94A3B8),
                        fontSize: 13.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        SizedBox(height: 12.h),

        // Days Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8.h,
            crossAxisSpacing: 8.w,
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
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
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
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
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
                _selectedDate != null &&
                cellDate.year == _selectedDate!.year &&
                cellDate.month == _selectedDate!.month &&
                cellDate.day == _selectedDate!.day;

            final isToday =
                cellDate.year == today.year &&
                cellDate.month == today.month &&
                cellDate.day == today.day;

            return GestureDetector(
              onTap: () {
                if (isSelected) {
                  // Tapping the currently selected date deselects it
                  setState(() => _selectedDate = null);
                  widget.onDateSelected(null);
                } else {
                  setState(() => _selectedDate = cellDate);
                  widget.onDateSelected(cellDate);
                }
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2FD1A6) : Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: isToday
                              ? const Color(0xFF2FD1A6)
                              : const Color(0xFFF1F5F9),
                          width: isToday ? 1.5.w : 1.w,
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
                      fontWeight: isSelected || isToday
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isToday
                                ? const Color(0xFF09B389)
                                : const Color(0xFF0F172A)),
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
