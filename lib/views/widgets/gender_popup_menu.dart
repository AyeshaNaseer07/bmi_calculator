import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GenderPopupMenuItem<T> {
  final T value;
  final String label;

  const GenderPopupMenuItem({required this.value, required this.label});
}

class GenderPopupMenuEntry<T> extends PopupMenuEntry<T> {
  const GenderPopupMenuEntry({super.key, required this.items});

  final List<GenderPopupMenuItem<T>> items;

  @override
  double get height => 137.h;

  @override
  bool represents(T? value) => false;

  @override
  State<GenderPopupMenuEntry<T>> createState() =>
      _GenderPopupMenuEntryState<T>();
}

class _GenderPopupMenuEntryState<T> extends State<GenderPopupMenuEntry<T>> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 144.w,
      height: 137.h,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11.r)),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 144.w,
              height: 137.h,
              decoration: ShapeDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.50, -2.0),
                  end: Alignment(0.50, 1.00),
                  colors: [const Color(0xFFD9F8F1), Colors.white],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11.r),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 8.60,
                    offset: Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  for (int i = 0; i < widget.items.length; i++) ...[
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.vertical(
                            top: i == 0 ? Radius.circular(11.r) : Radius.zero,
                            bottom: i == widget.items.length - 1
                                ? Radius.circular(11.r)
                                : Radius.zero,
                          ),
                          onTap: () {
                            Navigator.of(context).pop(widget.items[i].value);
                          },
                          child: Center(
                            child: Text(
                              widget.items[i].label,
                              style: TextStyle(
                                color: const Color(0xFF111827),
                                fontSize: 16.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (i < widget.items.length - 1)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 14.w),
                        height: 1,
                        color: const Color(0xFF9CA3AF).withValues(alpha: 0.5),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
