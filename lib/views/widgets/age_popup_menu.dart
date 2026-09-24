import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AgePopupMenuEntry extends PopupMenuEntry<int> {
  const AgePopupMenuEntry({
    super.key,
    required this.items,
    this.selectedAge,
  });

  final List<int> items;
  final int? selectedAge;

  @override
  double get height => 220.h;

  @override
  bool represents(int? value) => false;

  @override
  State<AgePopupMenuEntry> createState() => _AgePopupMenuEntryState();
}

class _AgePopupMenuEntryState extends State<AgePopupMenuEntry> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final itemHeight = 44.h;
    final defaultAge = widget.selectedAge ?? 25;
    final targetIndex = widget.items.indexOf(defaultAge);
    double initialOffset = 0;
    if (targetIndex > 0) {
      initialOffset = (targetIndex * itemHeight) - itemHeight;
      if (initialOffset < 0) initialOffset = 0;
    }
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 144.w,
      height: 220.h,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11.r),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 144.w,
              height: 220.h,
              decoration: ShapeDecoration(
                gradient: const LinearGradient(
                  begin: Alignment(0.50, -2.0),
                  end: Alignment(0.50, 1.00),
                  colors: [Color(0xFFD9F8F1), Colors.white],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11.r),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 8.60,
                    offset: Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11.r),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: false,
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    itemCount: widget.items.length,
                    separatorBuilder: (context, index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 14.w),
                      height: 1,
                      color: const Color(0xFF9CA3AF).withValues(alpha: 0.3),
                    ),
                    itemBuilder: (context, i) {
                      final age = widget.items[i];
                      final isSelected = age == widget.selectedAge;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop(age);
                          },
                          child: SizedBox(
                            height: 44.h,
                            child: Center(
                              child: Text(
                                '$age',
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF2FD1A6)
                                      : const Color(0xFF111827),
                                  fontSize: 16.sp,
                                  fontFamily: 'Inter',
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
