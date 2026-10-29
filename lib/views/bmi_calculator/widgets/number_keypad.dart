import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_palette.dart';

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
                      Expanded(
                        child: target.allowDecimal
                            ? _digit('.')
                            : _key(onTap: null, child: const SizedBox()),
                      ),
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
