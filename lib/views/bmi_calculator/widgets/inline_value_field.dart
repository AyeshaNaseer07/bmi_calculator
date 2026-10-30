import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_palette.dart';
import 'number_keypad.dart';

class InlineValueField extends StatefulWidget {
  final double? value;
  final String unit;
  final int decimals;
  final double min;
  final double max;
  final double width;
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

  bool get _useKeypad => defaultTargetPlatform == TargetPlatform.iOS;

  late final NumberKeypadTarget _keypadTarget = NumberKeypadTarget(
    allowDecimal: widget.decimals > 0,
    onKey: _insert,
    onBackspace: _backspace,
    onOk: _focus.unfocus,
  );

  String _format(double? v) =>
      v == null ? '' : v.toStringAsFixed(widget.decimals);

  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: _format(widget.value));
    _ownsFocus = widget.focusNode == null;
    _focus = widget.focusNode ?? FocusNode();
    _focus.addListener(_onFocusChange);
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
    if (_focus.hasFocus) {
      _showKeypad();
    } else {
      _hideKeypad();
      _commit();
    }
  }

  void _showKeypad() {
    if (!_useKeypad) return;
    numberKeypadTarget.value = _keypadTarget;
    // Once the keypad has taken its space, bring the field into view.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_focus.hasFocus) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 200),
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
    });
  }

  void _hideKeypad() {
    if (numberKeypadTarget.value == _keypadTarget) {
      numberKeypadTarget.value = null;
    }
  }

  int get _maxLength => widget.decimals > 0 ? 5 : 3;

  bool _isValidText(String s) =>
      s.length <= _maxLength &&
      RegExp(widget.decimals > 0 ? r'^\d*\.?\d*$' : r'^\d*$').hasMatch(s);

  /// Keypad key: types at the cursor (replacing any selection).
  void _insert(String key) {
    final value = _text.value;
    final sel = value.selection.isValid
        ? value.selection
        : TextSelection.collapsed(offset: value.text.length);
    final next = value.text.replaceRange(sel.start, sel.end, key);
    if (!_isValidText(next)) return;
    _text.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: sel.start + key.length),
    );
    _onTextChanged(next);
  }

  void _backspace() {
    final value = _text.value;
    final sel = value.selection.isValid
        ? value.selection
        : TextSelection.collapsed(offset: value.text.length);
    if (sel.isCollapsed && sel.start == 0) return;
    final start = sel.isCollapsed ? sel.start - 1 : sel.start;
    final next = value.text.replaceRange(start, sel.end, '');
    _text.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: start),
    );
    _onTextChanged(next);
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
    // Deferred: listeners can't rebuild while the tree is being torn down.
    WidgetsBinding.instance.addPostFrameCallback((_) => _hideKeypad());
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
            keyboardType: _useKeypad
                ? TextInputType.none
                : TextInputType.numberWithOptions(decimal: widget.decimals > 0),
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
              hintText: '00',
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
