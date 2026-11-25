import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/meal_setup_controller.dart';
import '../../data/models/user_profile_model.dart';
import 'meal_setup_common.dart';
import 'meal_setup_flow.dart';

/// Step 1 — Health Profile: age, gender, height, weight, goal, activity.
class HealthProfileStep extends StatefulWidget {
  const HealthProfileStep({super.key});

  @override
  State<HealthProfileStep> createState() => _HealthProfileStepState();
}

class _HealthProfileStepState extends State<HealthProfileStep> {
  final c = MealSetupController.to;
  late final TextEditingController _age;
  late final TextEditingController _height;
  late final TextEditingController _weight;
  final FocusNode _ageFocus = FocusNode();

  static const double _cmPerIn = 2.54;
  static const double _lbPerKg = 2.20462;

  @override
  void initState() {
    super.initState();
    _age = TextEditingController(text: c.age.value?.toString() ?? '');
    _height = TextEditingController(text: _heightText());
    _weight = TextEditingController(text: _weightText());
  }

  @override
  void dispose() {
    _ageFocus.dispose();
    _age.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  static double? _parse(String s) =>
      double.tryParse(s.trim().replaceAll(',', '.'));

  String _heightText() {
    final cm = c.heightCm.value;
    if (cm == null) return '';
    return c.heightInCm.value ? _fmt(cm) : (cm / _cmPerIn).round().toString();
  }

  String _weightText() {
    final kg = c.weightKg.value;
    if (kg == null) return '';
    return c.weightInKg.value
        ? _fmt(double.parse(kg.toStringAsFixed(1)))
        : _fmt(double.parse((kg * _lbPerKg).toStringAsFixed(1)));
  }

  void _onHeight(String s) {
    final v = _parse(s);
    c.heightCm.value = v == null
        ? null
        : (c.heightInCm.value ? v : v * _cmPerIn);
  }

  void _onWeight(String s) {
    final v = _parse(s);
    c.weightKg.value = v == null
        ? null
        : (c.weightInKg.value ? v : v / _lbPerKg);
  }

  void _toggleHeightUnit() {
    c.heightInCm.toggle();
    _height.text = _heightText();
  }

  void _toggleWeightUnit() {
    c.weightInKg.toggle();
    _weight.text = _weightText();
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (!c.healthProfileValid) {
      showSetupHint('ms_fill_health_profile'.tr);
      return;
    }
    MealSetupFlow.next(1);
  }

  @override
  Widget build(BuildContext context) {
    return SetupScaffold(
      step: 1,
      showStepChip: false,
      // Two-tone title like the overview: navy "Health", green "Profile".
      titleTop: 'ms_health_title_top'.tr,
      titleBottom: 'ms_health_title_bottom'.tr,
      subtitle: 'ms_health_profile_subtitle'.tr,
      hero: MealSetupAssets.health,
      body: Column(
        children: [
          _row(
            icon: MealSetupAssets.icAge,
            title: 'age'.tr,
            subtitle: 'ms_enter_your_age'.tr,
            control: SetupTextField(
              controller: _age,
              focusNode: _ageFocus,
              hint: 'ms_eg_value'.trParams({'v': '25'}),
              suffix: 'ms_years'.tr,
              suffixChevron: true,
              onSuffixTap: _ageFocus.requestFocus,
              keyboardType: TextInputType.number,
              inputFormatters: SetupTextField.digits,
              onChanged: (s) => c.age.value = int.tryParse(s),
            ),
          ),
          _row(
            icon: MealSetupAssets.icGender,
            title: 'gender'.tr,
            subtitle: 'ms_select_your_gender'.tr,
            controlFlex: 7,
            control: Obx(
              () => Row(
                children: [
                  for (final (i, g) in Gender.values.indexed) ...[
                    if (i > 0) SizedBox(width: 7.w),
                    Expanded(
                      child: _GenderChip(
                        gender: g,
                        selected: c.gender.value == g,
                        onTap: () => c.gender.value = g,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          _row(
            icon: MealSetupAssets.icHeight,
            title: 'height'.tr,
            subtitle: 'ms_enter_your_height'.tr,
            control: Obx(
              () => SetupTextField(
                controller: _height,
                hint: 'ms_eg_value'.trParams({
                  'v': c.heightInCm.value ? '170' : '67',
                }),
                suffix: c.heightInCm.value ? 'unit_cm'.tr : 'ms_unit_in'.tr,
                onSuffixTap: _toggleHeightUnit,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: SetupTextField.decimal,
                onChanged: _onHeight,
              ),
            ),
          ),
          _row(
            icon: MealSetupAssets.icWeight,
            title: 'ms_current_weight'.tr,
            subtitle: 'ms_enter_your_weight'.tr,
            control: Obx(
              () => SetupTextField(
                controller: _weight,
                hint: 'ms_eg_value'.trParams({
                  'v': c.weightInKg.value ? '65' : '143',
                }),
                suffix: c.weightInKg.value ? 'unit_kg'.tr : 'unit_lb'.tr,
                onSuffixTap: _toggleWeightUnit,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: SetupTextField.decimal,
                onChanged: _onWeight,
              ),
            ),
          ),
          _row(
            icon: MealSetupAssets.icGoal,
            title: 'ms_health_goal'.tr,
            subtitle: 'ms_what_is_your_goal'.tr,
            control: Obx(
              () => SetupDropdown<HealthGoal>(
                hint: 'ms_select_goal'.tr,
                value: c.goal.value,
                items: HealthGoal.values,
                labelOf: (g) => g.title,
                onSelected: (g) => c.goal.value = g,
              ),
            ),
          ),
          _row(
            icon: MealSetupAssets.icActivity,
            title: 'ms_activity_level'.tr,
            subtitle: 'ms_choose_activity_level'.tr,
            control: Obx(
              () => SetupDropdown<ActivityLevel>(
                hint: 'ms_select_level'.tr,
                value: c.activity.value,
                items: ActivityLevel.values,
                labelOf: (a) => a.title,
                onSelected: (a) => c.activity.value = a,
              ),
            ),
          ),
        ],
      ),
      bottom: Obx(
        () => SetupCta(
          text: 'next'.tr,
          enabled: c.healthProfileValid,
          onPressed: _next,
        ),
      ),
    );
  }

  /// Field card: 3D icon, title + subtitle, then the input on the end side.
  Widget _row({
    required String icon,
    required String title,
    required String subtitle,
    required Widget control,
    int controlFlex = 6,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: SetupCard(
        padding: EdgeInsetsDirectional.fromSTEB(12.w, 10.h, 12.w, 10.h),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 60.h),
          child: Row(
            children: [
              ExcludeSemantics(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: Image.asset(
                    icon,
                    width: 52.w,
                    height: 58.w / 1.38,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                flex: 5,
                child: SetupCardTitle(
                  title: title,
                  subtitle: subtitle,
                  titleSize: 16,
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(flex: controlFlex, child: control),
            ],
          ),
        ),
      ),
    );
  }
}

/// Male / Female / Other pill from the Health Profile kit.
class _GenderChip extends StatelessWidget {
  final Gender gender;
  final bool selected;
  final VoidCallback onTap;

  const _GenderChip({
    required this.gender,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? kMsGreenDeep : kMsChipText;
    final icon = switch (gender) {
      Gender.male => MealSetupAssets.genderMale,
      Gender.female => MealSetupAssets.genderFemale,
      Gender.other => MealSetupAssets.genderOther,
    };
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 54.h,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
          decoration: BoxDecoration(
            // Unselected chips sit on a light grey fill (reference design)
            color: selected ? kMsMint : const Color(0xFFF4F6F8),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: selected ? kMsGreen : kMsChipBorder,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            // Icon stacked above the label so each word gets the chip's
            // full width instead of being squeezed beside the icon.
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  icon,
                  width: 18.w,
                  height: 18.w,
                  colorFilter: ColorFilter.mode(fg, BlendMode.srcIn),
                ),
                SizedBox(height: 4.h),
                Text(
                  gender.displayName,
                  maxLines: 1,
                  style: msBody(12.5, color: fg, weight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
