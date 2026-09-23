import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets(
    'Global GestureDetector dismisses keyboard on tap outside with GetMaterialApp',
    (WidgetTester tester) async {
      final focusNode = FocusNode();
      final controller = TextEditingController();

      await tester.pumpWidget(
        GetMaterialApp(
          builder: (context, child) {
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: child,
            );
          },
          home: Scaffold(
            body: Column(
              children: [
                TextField(focusNode: focusNode, controller: controller),
                const SizedBox(height: 100),
                const Text('Outside Area'),
              ],
            ),
          ),
        ),
      );

      // Initially not focused
      expect(focusNode.hasFocus, isFalse);

      // Tap the text field to focus it
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      // Tap outside the text field
      await tester.tap(find.text('Outside Area'));
      await tester.pump();
      expect(focusNode.hasFocus, isFalse);
    },
  );

  testWidgets(
    'Tapping the TextField does not lose focus with global GestureDetector',
    (WidgetTester tester) async {
      final focusNode = FocusNode();
      final controller = TextEditingController(text: 'Hello');

      await tester.pumpWidget(
        GetMaterialApp(
          builder: (context, child) {
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: child,
            );
          },
          home: Scaffold(
            body: Column(
              children: [
                TextField(focusNode: focusNode, controller: controller),
                const SizedBox(height: 100),
                const Text('Outside Area'),
              ],
            ),
          ),
        ),
      );

      // Tap the text field to focus it
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      // Tap again inside the text field
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);
    },
  );

  testWidgets('FocusNodes advance on submitted next and unfocus on done', (
    WidgetTester tester,
  ) async {
    final focusNode1 = FocusNode();
    final focusNode2 = FocusNode();
    final controller1 = TextEditingController();
    final controller2 = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              TextField(
                key: const Key('field1'),
                focusNode: focusNode1,
                controller: controller1,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => focusNode2.requestFocus(),
              ),
              TextField(
                key: const Key('field2'),
                focusNode: focusNode2,
                controller: controller2,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => focusNode2.unfocus(),
              ),
            ],
          ),
        ),
      ),
    );

    // Focus field 1
    await tester.tap(find.byKey(const Key('field1')));
    await tester.pump();
    expect(focusNode1.hasFocus, isTrue);
    expect(focusNode2.hasFocus, isFalse);

    // Submit field 1 (advances to field 2)
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(focusNode1.hasFocus, isFalse);
    expect(focusNode2.hasFocus, isTrue);

    // Submit field 2 (unfocuses)
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(focusNode1.hasFocus, isFalse);
    expect(focusNode2.hasFocus, isFalse);
  });
}
