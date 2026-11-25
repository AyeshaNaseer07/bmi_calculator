import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/meal_setup_controller.dart';
import 'meal_setup_common.dart';
import 'meal_setup_flow.dart';

/// Step 2 — Medical Conditions (multi-select, or "None of the above").
class MedicalConditionsStep extends StatefulWidget {
  const MedicalConditionsStep({super.key});

  @override
  State<MedicalConditionsStep> createState() => _MedicalConditionsStepState();
}

class _MedicalConditionsStepState extends State<MedicalConditionsStep> {
  final c = MealSetupController.to;
  late final TextEditingController _other;
  late final Worker _clearOther;

  @override
  void initState() {
    super.initState();
    _other = TextEditingController(text: c.otherCondition.value);
    // "None of the above" clears the typed condition.
    _clearOther = ever<String>(c.otherCondition, (v) {
      if (v.isEmpty && _other.text.isNotEmpty) _other.clear();
    });
  }

  @override
  void dispose() {
    _clearOther.dispose();
    _other.dispose();
    super.dispose();
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (!c.medicalValid) {
      showSetupHint('ms_select_condition_or_none'.tr);
      return;
    }
    MealSetupFlow.next(2);
  }

  @override
  Widget build(BuildContext context) {
    const options = MealSetupOptions.medical;
    return SetupScaffold(
      step: 2,
      titleTop: 'ms_medical'.tr,
      titleBottom: 'ms_conditions'.tr,
      subtitle: 'ms_medical_subtitle'.tr,
      hero: MealSetupAssets.medical,
      body: Column(
        children: [
          for (int i = 0; i < options.length; i += 2)
            Padding(
              padding: EdgeInsets.only(bottom: 9.h),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _tile(options[i])),
                    SizedBox(width: 9.w),
                    Expanded(
                      child: i + 1 < options.length
                          ? _tile(options[i + 1])
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          SetupCard(
            radius: 18,
            padding: EdgeInsetsDirectional.fromSTEB(12.w, 8.h, 8.w, 8.h),
            child: Row(
              children: [
                SvgPicture.asset(
                  MealSetupAssets.otherDots,
                  width: 36.w,
                  height: 36.w,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 6,
                  child: _label(
                    'ms_other_medical_condition'.tr,
                    'ms_please_specify'.tr,
                    size: 13.5,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  flex: 5,
                  child: SetupTextField(
                    controller: _other,
                    hint: 'ms_type_here'.tr,
                    hintColor: kMsPlaceholder,
                    maxLength: 80,
                    onChanged: c.setOtherCondition,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 9.h),
          Obx(
            () => SetupNoneBanner(
              title: 'ms_none_of_the_above'.tr,
              subtitle: 'ms_no_medical_conditions'.tr,
              selected: c.noConditions.value,
              onTap: c.toggleNoConditions,
            ),
          ),
        ],
      ),
      bottom: Row(
        children: [
          const SetupSparkle(),
          SizedBox(width: 6.w),
          const Expanded(flex: 4, child: SetupBackButton()),
          SizedBox(width: 12.w),
          Expanded(
            flex: 5,
            child: Obx(
              () => SetupCta(
                text: 'next'.tr,
                enabled: c.medicalValid,
                sparkles: false,
                height: 52,
                fontSize: 17,
                onPressed: _next,
              ),
            ),
          ),
          SizedBox(width: 6.w),
          const SetupSparkle(mirror: true),
        ],
      ),
    );
  }

  /// Condition label (13 semibold) with optional grey sub line.
  Widget _label(String title, String? sub, {double size = 12.5}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: msBody(
            size,
            color: kMsNavy,
            weight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        if (sub != null)
          Text(sub, style: msBody(10.5, color: kMsTextSecondary, height: 1.25)),
      ],
    );
  }

  Widget _tile(SetupOption o) {
    return Obx(() {
      final on = c.conditions.contains(o.key);
      return Semantics(
        button: true,
        selected: on,
        child: SetupCard(
          radius: 18,
          selected: on,
          onTap: () => c.toggleCondition(o.key),
          padding: EdgeInsetsDirectional.fromSTEB(8.w, 8.h, 8.w, 8.h),
          child: Row(
            children: [
              SizedBox(
                width: 44.w,
                height: 38.w,
                child: Image.asset(o.image!, fit: BoxFit.contain),
              ),
              SizedBox(width: 6.w),
              Expanded(child: _label(o.label.tr, o.sub?.tr)),
              SizedBox(width: 4.w),
              SetupCheckBox(checked: on, size: 22),
            ],
          ),
        ),
      );
    });
  }
}
