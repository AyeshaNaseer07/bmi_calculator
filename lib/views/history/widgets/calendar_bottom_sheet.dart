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
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _currentMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month, 1);
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
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday; // 1 = Mon, 7 = Sun
    final prevMonthDays = DateTime(_currentMonth.year, _currentMonth.month, 0).day;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 16.h),

          // Header Row: Month / Year with Dropdown & Prev/Next Chevrons
          Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Prev Chevron
                  GestureDetector(
                    onTap: _previousMonth,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(CupertinoIcons.chevron_left, size: 16.sp, color: AppColors.textDark),
                    ),
                  ),

                  // Month & Year Selector Chips
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _showMonthDropdown = !_showMonthDropdown),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Text(
                                monthName,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                CupertinoIcons.chevron_down,
                                size: 12.sp,
                                color: AppColors.primaryTeal,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '$year',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              CupertinoIcons.chevron_down,
                              size: 12.sp,
                              color: AppColors.primaryTeal,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Next Chevron
                  GestureDetector(
                    onTap: _nextMonth,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(CupertinoIcons.chevron_right, size: 16.sp, color: AppColors.textDark),
                    ),
                  ),
                ],
              ),

              // Month Dropdown Popup (matching screenshot 32)
              if (_showMonthDropdown)
                Positioned(
                  top: 44.h,
                  left: 70.w,
                  child: Material(
                    elevation: 12,
                    borderRadius: BorderRadius.circular(14.r),
                    color: Colors.white,
                    child: Container(
                      width: 140.w,
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
                                _currentMonth = DateTime(_currentMonth.year, idx + 1, 1);
                                _showMonthDropdown = false;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                              color: isCurrent ? const Color(0xFFF0FAF6) : Colors.transparent,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _months[idx],
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                                      color: isCurrent ? AppColors.primaryTeal : AppColors.textDark,
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
          SizedBox(height: 16.h),

          // Weekdays Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Mo', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
              Text('Tu', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
              Text('We', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
              Text('Th', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
              Text('Fr', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
              Text('Sa', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
              Text('Su', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
            ],
          ),
          SizedBox(height: 10.h),

          // Days Grid (6 rows x 7 cols)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8.h,
              crossAxisSpacing: 8.w,
              childAspectRatio: 1.1,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final dayOffset = index - (firstWeekday - 1);
              if (dayOffset < 0) {
                // Prev month days
                final prevDay = prevMonthDays + dayOffset + 1;
                return Center(
                  child: Text(
                    '$prevDay',
                    style: TextStyle(fontSize: 12.sp, color: const Color(0xFFCBD5E1)),
                  ),
                );
              } else if (dayOffset >= daysInMonth) {
                // Next month days
                final nextDay = dayOffset - daysInMonth + 1;
                return Center(
                  child: Text(
                    '$nextDay',
                    style: TextStyle(fontSize: 12.sp, color: const Color(0xFFCBD5E1)),
                  ),
                );
              }

              final currentDay = dayOffset + 1;
              final cellDate = DateTime(_currentMonth.year, _currentMonth.month, currentDay);
              final isSelected = cellDate.year == _selectedDate.year &&
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
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF2FD1A6).withValues(alpha: 0.3),
                              blurRadius: 6.r,
                              offset: Offset(0, 2.h),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$currentDay',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
