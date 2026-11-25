import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/meal_setup_controller.dart';
import '../../data/models/user_profile_model.dart';
import 'meal_setup_common.dart';
import 'meal_setup_flow.dart';

/// Unselected option fill from the Lifestyle kit.
const Color _kInputFill = Color(0xFFF8FAFC);

/// Step 5 — Lifestyle Information, then "Complete Setup".
class LifestyleStep extends StatefulWidget {
  const LifestyleStep({super.key});

  @override
  State<LifestyleStep> createState() => _LifestyleStepState();
}

class _LifestyleStepState extends State<LifestyleStep> {
  final c = MealSetupController.to;
  late final TextEditingController _notes;
  bool _finishing = false;

  static const int _notesMax = 500;

  /// Daily exercise choices; shares the activity level from step 1.
  static const _exercise = [
    (ActivityLevel.sedentary, 'sedentary', 'ms_ex_sedentary_sub'),
    (ActivityLevel.lightlyActive, 'lightly_active', 'ms_ex_light_sub'),
    (ActivityLevel.moderatelyActive, 'moderately_active', 'ms_ex_moderate_sub'),
    (ActivityLevel.veryActive, 'very_active', 'ms_ex_very_sub'),
  ];

  @override
  void initState() {
    super.initState();
    _notes = TextEditingController(text: c.notes.value);
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    if (_finishing) return;
    _finishing = true;
    FocusScope.of(context).unfocus();
    c.completeStep(5);
    await MealSetupFlow.finish();
    _finishing = false;
  }

  @override
  Widget build(BuildContext context) {
    return SetupScaffold(
      step: 5,
      titleTop: 'ms_lifestyle'.tr,
      titleBottom: 'ms_information'.tr,
      subtitle: 'ms_lifestyle_subtitle'.tr,
      hero: MealSetupAssets.lifestyle,
      heroEmoji: '💧',
      body: Column(
        children: [
          _section(
            icon: MealSetupAssets.secExercise,
            title: 'ms_daily_exercise'.tr,
            subtitle: 'ms_how_active'.tr,
            // Four labelled options need the full card width to stay legible.
            fullWidth: Obx(() {
              var current = c.activity.value;
              if (current == ActivityLevel.extraActive) {
                current = ActivityLevel.veryActive;
              }
              return _optionRow([
                for (final (level, label, sub) in _exercise)
                  _OptionTile(
                    label: label.tr,
                    sub: sub.tr,
                    selected: current == level,
                    onTap: () => c.activity.value = level,
                  ),
              ]);
            }),
          ),
          _section(
            icon: MealSetupAssets.secSleep,
            title: 'ms_sleep_duration'.tr,
            subtitle: 'ms_hours_sleep'.tr,
            child: Obx(
              () => SetupDropdown<SetupOption>(
                hint: 'ms_select_hours'.tr,
                height: 48,
                radius: 12,
                value: MealSetupOptions.sleep.firstWhereOrNull(
                  (o) => o.key == c.sleep.value,
                ),
                items: MealSetupOptions.sleep,
                labelOf: (o) => o.label.tr,
                onSelected: (o) => c.sleep.value = o.key,
              ),
            ),
          ),
          _section(
            icon: MealSetupAssets.secWater,
            title: 'ms_daily_water_intake'.tr,
            subtitle: 'ms_how_much_water'.tr,
            child: Obx(
              () => _optionRow([
                for (final o in MealSetupOptions.water)
                  _OptionTile(
                    label: o.label.tr,
                    selected: c.water.value == o.key,
                    big: true,
                    onTap: () =>
                        c.water.value = c.water.value == o.key ? null : o.key,
                  ),
              ]),
            ),
          ),
          _section(
            icon: MealSetupAssets.secMealClock,
            title: 'ms_meal_timing'.tr,
            subtitle: 'ms_prefer_meal_times'.tr,
            fullWidth: Obx(
              () => _optionRow([
                for (final o in MealSetupOptions.mealTiming)
                  _OptionTile(
                    label: o.label.tr,
                    sub: o.sub?.tr,
                    checkbox: true,
                    selected: c.mealTiming.value == o.key,
                    onTap: () => c.mealTiming.value =
                        c.mealTiming.value == o.key ? null : o.key,
                  ),
              ]),
            ),
          ),
          _section(
            icon: MealSetupAssets.secNotes,
            title: 'ms_additional_notes'.tr,
            titleSuffix: 'ms_optional'.tr,
            subtitle: 'ms_additional_notes_hint'.tr,
            child: _notesBox(),
          ),
        ],
      ),
      bottom: SetupCta(text: 'ms_complete_setup'.tr, onPressed: _complete),
      footer: Padding(
        padding: EdgeInsets.only(top: 10.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(MealSetupAssets.lock, width: 15.w, height: 15.w),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                'ms_info_secure'.tr,
                textAlign: TextAlign.center,
                style: msBody(12, color: kMsSubtitle),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Equal-width options in one row.
  Widget _optionRow(List<Widget> tiles) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < tiles.length; i++) ...[
          if (i > 0) SizedBox(width: 6.w),
          Expanded(child: tiles[i]),
        ],
      ],
    ),
  );

  /// Notes field: grey-filled box with the counter inside, bottom end.
  Widget _notesBox() {
    return Container(
      constraints: BoxConstraints(minHeight: 72.h),
      padding: EdgeInsetsDirectional.fromSTEB(14.w, 4.h, 12.w, 8.h),
      decoration: BoxDecoration(
        color: _kInputFill,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: kMsChipBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _notes,
            maxLength: _notesMax,
            maxLines: 4,
            minLines: 2,
            keyboardType: TextInputType.multiline,
            cursorColor: kMsGreen,
            onChanged: (v) => c.notes.value = v,
            style: msBody(14, color: kMsNavy),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              counterText: '',
              hintText: 'ms_type_here'.tr,
              hintStyle: msBody(14, color: kMsPlaceholder),
              contentPadding: EdgeInsets.symmetric(vertical: 8.h),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _notes,
            builder: (_, v, _) => Text(
              '${v.text.characters.length}/$_notesMax',
              textAlign: TextAlign.end,
              style: msBody(10, color: kMsTextSecondary),
            ),
          ),
        ],
      ),
    );
  }

  /// Card: icon tile, title + subtitle, then [child] under the title, or
  /// [fullWidth] spanning the whole card below the header.
  Widget _section({
    required String icon,
    required String title,
    required String subtitle,
    Widget? child,
    Widget? fullWidth,
    String? titleSuffix,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: SetupCard(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: Container(
                    width: 56.w,
                    height: 56.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: kMsMint,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: SvgPicture.asset(icon, width: 36.w, height: 36.w),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SetupCardTitle(
                        title: title,
                        subtitle: subtitle,
                        titleSuffix: titleSuffix,
                        titleSize: 16,
                      ),
                      if (child != null) ...[SizedBox(height: 10.h), child],
                    ],
                  ),
                ),
              ],
            ),
            if (fullWidth != null) ...[SizedBox(height: 10.h), fullWidth],
          ],
        ),
      ),
    );
  }
}

/// Rounded option from the Lifestyle kit: grey fill when idle, mint with a
/// green border and check circle when selected. With [checkbox] it always
/// shows a leading box (meal timing).
class _OptionTile extends StatelessWidget {
  final String label;
  final String? sub;
  final bool selected;
  final bool checkbox;
  final bool big;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.sub,
    this.checkbox = false,
    this.big = false,
  });

  @override
  Widget build(BuildContext context) {
    final showMark = checkbox || selected;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: BoxConstraints(minHeight: 38.h),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: selected ? kMsMint : _kInputFill,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: selected ? kMsGreen : kMsChipBorder,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: checkbox
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              if (showMark) ...[
                SetupCheckBox(checked: selected, size: big ? 22 : 19),
                SizedBox(width: 5.w),
              ],
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: checkbox
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      textAlign: checkbox ? TextAlign.start : TextAlign.center,
                      style: msBody(
                        big ? 14 : 11.5,
                        color: selected ? kMsGreenDeep : kMsNavy,
                        weight: big ? FontWeight.w500 : FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    if (sub != null)
                      Text(
                        sub!,
                        textAlign: checkbox
                            ? TextAlign.start
                            : TextAlign.center,
                        style: msBody(
                          9.5,
                          color: selected ? kMsGreenDeep : kMsTextSecondary,
                          height: 1.2,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
