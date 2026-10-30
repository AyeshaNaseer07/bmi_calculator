import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_palette.dart';
import '../../widgets/number_keypad.dart';

class InlineValueField extends StatefulWidget {
  final double? value;
  final String unit;
  final int decimals;
  final double min;
  final double max;
  final double width;
  final String hint;
  final FocusNode? focusNode;
  final bool showEdit;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double> onCommitted;

  const InlineValueField({
    super.key,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.onCommitted,
    this.onChanged,
    this.decimals = 0,
    this.width = 92,
    this.hint = '00',
    this.focusNode,
    this.showEdit = false,
  });

  @override
  State<InlineValueField> createState() => _InlineValueFieldState();
}

class _InlineValueFieldState extends State<InlineValueField> {
  late final TextEditingController _text;
  late final FocusNode _focus;
  bool _ownsFocus = false;

  static const Color _green = Color(0xFF08B289);

  late final NumberKeypadBinding _keypad;

  String _format(double? v) =>
      v == null ? '' : v.toStringAsFixed(widget.decimals);

  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: _format(widget.value));
    _ownsFocus = widget.focusNode == null;
    _focus = widget.focusNode ?? FocusNode();
    _focus.addListener(_onFocusChange);
    _keypad = NumberKeypadBinding(
      controller: _text,
      focus: _focus,
      allowDecimal: widget.decimals > 0,
      maxLength: widget.decimals > 0 ? 5 : 3,
      onChanged: _onTextChanged,
    );
  }

  @override
  void didUpdateWidget(covariant InlineValueField old) {
    super.didUpdateWidget(old);
    // Keep the text in sync with slider / unit changes, but never while the
    // user is typing in this field.
    if (!_focus.hasFocus) {
      final t = _format(widget.value);
      if (_text.text != t) _text.text = t;
    }
  }

  void _onFocusChange() {
    if (!_focus.hasFocus) _commit();
  }

  void _commit() {
    final parsed = double.tryParse(_text.text.trim());
    if (parsed == null) {
      _text.text = _format(widget.value);
      return;
    }
    final v = parsed.clamp(widget.min, widget.max).toDouble();
    widget.onCommitted(v);
    _text.text = _format(v);
  }

  void _onTextChanged(String s) {
    final v = double.tryParse(s);
    if (v != null && v >= widget.min && v <= widget.max) {
      widget.onChanged?.call(v);
    }
  }

  /// Edit icon: focus the field with a blinking cursor after the value.
  void _startEditing() {
    _focus.requestFocus();
    _text.selection = TextSelection.collapsed(offset: _text.text.length);
  }

  @override
  void dispose() {
    _keypad.dispose();
    _focus.removeListener(_onFocusChange);
    if (_ownsFocus) _focus.dispose();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: _green,
      fontSize: 34.sp,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w800,
      height: 1.1,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(
          width: widget.width.w,
          child: TextField(
            controller: _text,
            focusNode: _focus,
            textAlign: TextAlign.center,
            style: style,
            cursorColor: _green,
            showCursor: true,
            // On iOS the app keypad types instead of the system keyboard.
            keyboardType: _keypad.keyboardType,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(widget.decimals > 0 ? r'[0-9.]' : r'[0-9]'),
              ),
              LengthLimitingTextInputFormatter(widget.decimals > 0 ? 5 : 3),
            ],
            textInputAction: TextInputAction.done,
            onChanged: _onTextChanged,
            onSubmitted: (_) => _focus.unfocus(),
            onTapOutside: (_) => _focus.unfocus(),
            decoration: InputDecoration(
              isDense: true,
              hintText: widget.hint,
              hintStyle: style.copyWith(color: const Color(0xFFB8E8DA)),
              contentPadding: EdgeInsets.only(bottom: 2.h),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: _green, width: 1.5),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: _green, width: 2.2),
              ),
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          widget.unit,
          style: TextStyle(
            color: _green,
            fontSize: 16.sp,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        if (widget.showEdit) ...[
          SizedBox(width: 8.w),
          // Part of the field, so tapping it while editing doesn't first
          // count as a tap outside and drop focus.
          TextFieldTapRegion(
            child: GestureDetector(
              onTap: _startEditing,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppPalette.surfaceMint,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.edit, size: 14.sp, color: _green),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
