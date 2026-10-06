import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ManualInputDialog extends StatefulWidget {
  final String title;
  final String unitLabel;
  final String initialValue;
  final double min;
  final double max;
  final ValueChanged<double> onSubmit;

  const ManualInputDialog({
    super.key,
    required this.title,
    required this.unitLabel,
    required this.initialValue,
    required this.min,
    required this.max,
    required this.onSubmit,
  });

  static Future<void> show({
    required String title,
    required String unitLabel,
    required String initialValue,
    required double min,
    required double max,
    required ValueChanged<double> onSubmit,
  }) {
    return Get.dialog(
      ManualInputDialog(
        title: title,
        unitLabel: unitLabel,
        initialValue: initialValue,
        min: min,
        max: max,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<ManualInputDialog> createState() => _ManualInputDialogState();
}

class _ManualInputDialogState extends State<ManualInputDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = double.tryParse(_controller.text.trim());
    if (value == null) {
      setState(() => _errorText = 'Enter a valid number');
      return;
    }
    if (value < widget.min || value > widget.max) {
      setState(
        () => _errorText =
            'Enter a value between ${widget.min.toStringAsFixed(0)} and ${widget.max.toStringAsFixed(0)}',
      );
      return;
    }
    widget.onSubmit(value);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF2EC4B6);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                color: const Color(0xFF111827),
                fontSize: 18.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 14.h),
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
              ],
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
              decoration: InputDecoration(
                suffixText: widget.unitLabel,
                suffixStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B7280),
                ),
                errorText: _errorText,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: green, width: 1.5),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 12.h,
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
            SizedBox(height: 18.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: const BorderSide(color: green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: green,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
