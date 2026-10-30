import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_palette.dart';

/// What the keypad types into: the field currently being edited.
class NumberKeypadTarget {
  final bool allowDecimal;
  final ValueChanged<String> onKey;
  final VoidCallback onBackspace;
  final VoidCallback onOk;

  const NumberKeypadTarget({
    required this.allowDecimal,
    required this.onKey,
    required this.onBackspace,
    required this.onOk,
  });
}

/// Set by the focused field; [NumberKeypadHost] shows the keypad while set.
final ValueNotifier<NumberKeypadTarget?> numberKeypadTarget = ValueNotifier(
  null,
);

/// Hooks a numeric text field up to the app keypad: shows it while [focus]
/// has focus and types into [controller]. iOS only; elsewhere the field keeps
/// the system number keyboard via [keyboardType]. Call [dispose] with the
/// field's state.
class NumberKeypadBinding {
  final TextEditingController controller;
  final FocusNode focus;
  final bool allowDecimal;
  final int? maxLength;

  /// Keypad OK; defaults to ending editing.
  final VoidCallback? onOk;

  /// Called after each keypad edit (keypad edits don't fire
  /// `TextField.onChanged`).
  final ValueChanged<String>? onChanged;

  NumberKeypadBinding({
    required this.controller,
    required this.focus,
    this.allowDecimal = false,
    this.maxLength,
    this.onOk,
    this.onChanged,
  }) {
    focus.addListener(_onFocusChange);
  }

  static bool get isEnabled => defaultTargetPlatform == TargetPlatform.iOS;

  /// For the field's `keyboardType`: none while the app keypad types instead.
  TextInputType get keyboardType => isEnabled
      ? TextInputType.none
      : TextInputType.numberWithOptions(decimal: allowDecimal);

  late final NumberKeypadTarget _target = NumberKeypadTarget(
    allowDecimal: allowDecimal,
    onKey: _insert,
    onBackspace: _backspace,
    onOk: onOk ?? focus.unfocus,
  );

  void _onFocusChange() {
    if (!isEnabled) return;
    if (focus.hasFocus) {
      _show();
    } else {
      _hide();
    }
  }

  void _show() {
    numberKeypadTarget.value = _target;
    // Once the keypad has taken its space, bring the field into view.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = focus.context;
      if (context == null || !context.mounted || !focus.hasFocus) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 200),
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
    });
  }

  void _hide() {
    if (numberKeypadTarget.value == _target) numberKeypadTarget.value = null;
  }

  bool _isValid(String s) =>
      (maxLength == null || s.length <= maxLength!) &&
      RegExp(allowDecimal ? r'^\d*\.?\d*$' : r'^\d*$').hasMatch(s);

  TextSelection _selection(TextEditingValue value) => value.selection.isValid
      ? value.selection
      : TextSelection.collapsed(offset: value.text.length);

  /// Keypad key: types at the cursor (replacing any selection).
  void _insert(String key) {
    final value = controller.value;
    final sel = _selection(value);
    final next = value.text.replaceRange(sel.start, sel.end, key);
    if (!_isValid(next)) return;
    controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: sel.start + key.length),
    );
    onChanged?.call(next);
  }

  void _backspace() {
    final value = controller.value;
    final sel = _selection(value);
    if (sel.isCollapsed && sel.start == 0) return;
    final start = sel.isCollapsed ? sel.start - 1 : sel.start;
    final next = value.text.replaceRange(start, sel.end, '');
    controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: start),
    );
    onChanged?.call(next);
  }

  void dispose() {
    focus.removeListener(_onFocusChange);
    // Deferred: listeners can't rebuild while the tree is being torn down.
    WidgetsBinding.instance.addPostFrameCallback((_) => _hide());
  }
}

/// Put in the screen's `bottomNavigationBar`, so the page shrinks (and can
/// scroll the field into view) while the keypad is up.
class NumberKeypadHost extends StatelessWidget {
  const NumberKeypadHost({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<NumberKeypadTarget?>(
      valueListenable: numberKeypadTarget,
      builder: (context, target, _) {
        if (target == null) return const SizedBox.shrink();
        // Part of the field, so key taps aren't a "tap outside" that ends
        // editing.
        return TextFieldTapRegion(child: _NumberKeypad(target: target));
      },
    );
  }
}

/// Digits on the left; ⌫ at the top of the right column with a tall OK under
/// it.
class _NumberKeypad extends StatelessWidget {
  final NumberKeypadTarget target;

  const _NumberKeypad({required this.target});

  static const Color _green = Color(0xFF08B289);
  static const double _keyHeight = 50;
  static const double _gap = 6;

  void _tap(VoidCallback action) {
    HapticFeedback.selectionClick();
    action();
  }

  Widget _key({
    required Widget child,
    required VoidCallback? onTap,
    Color? color,
    double height = _keyHeight,
  }) {
    return SizedBox(
      height: height,
      child: Material(
        color: onTap == null ? Colors.transparent : color ?? AppPalette.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap == null ? null : () => _tap(onTap),
          child: Center(child: child),
        ),
      ),
    );
  }

  Widget _digit(String label) => _key(
    onTap: () => target.onKey(label),
    child: Text(
      label,
      style: TextStyle(
        color: AppPalette.textPrimary,
        fontSize: 24,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _row(List<Widget> keys) => Row(
    children: [
      for (var i = 0; i < keys.length; i++) ...[
        if (i > 0) const SizedBox(width: _gap),
        Expanded(child: keys[i]),
      ],
    ],
  );

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    // Swallows taps on the gaps so they don't reach the app-wide
    // "tap anywhere to dismiss the keyboard" handler.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Container(
        color: AppPalette.surfaceMuted,
        padding: EdgeInsets.fromLTRB(_gap, _gap, _gap, _gap + bottomInset),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _row([_digit('1'), _digit('2'), _digit('3')]),
                  const SizedBox(height: _gap),
                  _row([_digit('4'), _digit('5'), _digit('6')]),
                  const SizedBox(height: _gap),
                  _row([_digit('7'), _digit('8'), _digit('9')]),
                  const SizedBox(height: _gap),
                  Row(
                    children: [
                      Expanded(flex: 2, child: _digit('0')),
                      const SizedBox(width: _gap),
                      // Whole-number fields reject it when typed.
                      Expanded(child: _digit('.')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: _gap),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _key(
                    onTap: target.onBackspace,
                    child: Icon(
                      Icons.backspace_outlined,
                      color: AppPalette.textPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: _gap),
                  _key(
                    onTap: target.onOk,
                    color: _green,
                    height: _keyHeight * 3 + _gap * 2,
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
