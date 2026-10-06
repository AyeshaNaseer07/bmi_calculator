import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// A manual value-entry dialog. Supports either a single numeric field
/// (e.g. cm, kg, lb) or a compound feet + inches field pair for imperial
/// height entry.
class ManualInputDialog extends StatefulWidget {
  final String title;
  final String unitLabel;
  final String initialValue;
  final double min;
  final double max;
  final ValueChanged<double> onSubmit;

  final bool useFeetInches;
  final String initialInches;
  final void Function(double feet, double inches)? onSubmitFeetInches;

  const ManualInputDialog({
    super.key,
    required this.title,
    required this.unitLabel,
    required this.initialValue,
    required this.min,
    required this.max,
    required this.onSubmit,
    this.useFeetInches = false,
    this.initialInches = '0',
    this.onSubmitFeetInches,
  });

  /// Shows a single-field dialog (e.g. cm, kg, lb).
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

  /// Shows a feet + inches dialog for imperial height entry.
  static Future<void> showFeetInches({
    required String title,
    required int initialFeet,
    required int initialInches,
    required void Function(double feet, double inches) onSubmit,
  }) {
    return Get.dialog(
      ManualInputDialog(
        title: title,
        unitLabel: 'ft',
        initialValue: '$initialFeet',
        min: 0,
        max: 0,
        onSubmit: (_) {},
        useFeetInches: true,
        initialInches: '$initialInches',
        onSubmitFeetInches: onSubmit,
      ),
    );
  }

  @override
  State<ManualInputDialog> createState() => _ManualInputDialogState();
}

class _ManualInputDialogState extends State<ManualInputDialog> {
  late final TextEditingController _controller;
  late final TextEditingController _inchesController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _inchesController = TextEditingController(text: widget.initialInches);
  }

  @override
  void dispose() {
    _controller.dispose();
    _inchesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.useFeetInches) {
      final feet = double.tryParse(_controller.text.trim());
      final inches = double.tryParse(_inchesController.text.trim());
      if (feet == null || inches == null) {
        setState(() => _errorText = 'Enter valid numbers');
        return;
      }
      if (feet < 0 || inches < 0 || inches >= 12) {
        setState(() => _errorText = 'Inches must be between 0 and 11');
        return;
      }
      final totalInches = (feet * 12) + inches;
      if (totalInches < 47 || totalInches > 86) {
        setState(() => _errorText = "Enter a height between 3'11\" and 7'2\"");
        return;
      }
      widget.onSubmitFeetInches!(feet, inches);
      Get.back();
      return;
    }

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

  InputDecoration _decoration(String unit) {
    const green = Color(0xFF2EC4B6);
    return InputDecoration(
      suffixText: unit,
      suffixStyle: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF6B7280),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: green, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
    );
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
            if (widget.useFeetInches)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                      decoration: _decoration('ft')
                          .copyWith(errorText: _errorText),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextField(
                      controller: _inchesController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                      decoration: _decoration('in'),
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                ],
              )
            else
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
                decoration: _decoration(widget.unitLabel)
                    .copyWith(errorText: _errorText),
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
