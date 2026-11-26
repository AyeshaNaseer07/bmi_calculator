import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/meal_setup_controller.dart';
import 'meal_setup_common.dart';
import 'meal_setup_flow.dart';

/// Step 3 — Food Allergies (multi-select; none selected = no allergies).
class FoodAllergiesStep extends StatefulWidget {
  const FoodAllergiesStep({super.key});

  @override
  State<FoodAllergiesStep> createState() => _FoodAllergiesStepState();
}

class _FoodAllergiesStepState extends State<FoodAllergiesStep> {
  final c = MealSetupController.to;
  late final TextEditingController _other;
  late final Worker _clearOther;

  @override
  void initState() {
    super.initState();
    _other = TextEditingController(text: c.otherAllergy.value);
    // "No food allergies" clears the typed allergy.
    _clearOther = ever<String>(c.otherAllergy, (v) {
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
    if (!c.allergiesValid) {
      showSetupHint('ms_fill_allergies'.tr);
      return;
    }
    MealSetupFlow.next(3);
  }

  @override
  Widget build(BuildContext context) {
    return SetupScaffold(
      step: 3,
      titleTop: 'ms_food'.tr,
      titleBottom: 'ms_allergies'.tr,
      subtitle: 'ms_allergies_subtitle'.tr,
      hero: MealSetupAssets.allergies,
      body: Column(
        children: [
          for (final o in MealSetupOptions.allergies) _row(o),
          SetupCard(
            radius: 18,
            padding: EdgeInsetsDirectional.fromSTEB(10.w, 8.h, 10.w, 8.h),
            child: Row(
              children: [
                _pill(
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFCDEFE3),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      MealSetupAssets.plus,
                      width: 18.w,
                      height: 18.w,
                      colorFilter: const ColorFilter.mode(
                        kMsGreen,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 5,
                  child: Text('ms_other_food_allergy'.tr, style: _titleStyle),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  flex: 5,
                  child: SetupTextField(
                    controller: _other,
                    hint: 'ms_type_here'.tr,
                    hintColor: kMsPlaceholder,
                    hintSize: 14,
                    radius: 20,
                    maxLength: 80,
                    onChanged: c.setOtherAllergy,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Obx(
            () => SetupNoneBanner(
              title: 'ms_no_food_allergies'.tr,
              subtitle: 'ms_no_food_allergies_sub'.tr,
              selected: c.noAllergies.value,
              onTap: c.toggleNoAllergies,
            ),
          ),
        ],
      ),
      bottom: Obx(
        () => SetupCta(
          text: 'next'.tr,
          enabled: c.allergiesValid,
          onPressed: _next,
        ),
      ),
    );
  }

  TextStyle get _titleStyle => TextStyle(
    color: kMsNavy,
    fontSize: 15.sp,
    fontFamily: 'Outfit',
    fontWeight: FontWeight.w700,
  );

  static const Color _tileMint = Color(0xFFE7FCF5);

  /// Same size, radius and mint as the baked allergen icon tiles.
  Widget _pill({required Widget child}) => Container(
    width: _tileW,
    height: _tileH,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: _tileMint,
      borderRadius: BorderRadius.circular(14.r),
    ),
    child: child,
  );

  double get _tileW => 52.w;
  double get _tileH => 58.w / 1.38;

  Widget _row(SetupOption o) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5.h),
      child: Obx(() {
        final on = c.allergies.contains(o.key);
        return Semantics(
          button: true,
          selected: on,
          child: SetupCard(
            radius: 18,
            selected: on,
            onTap: () => c.toggleAllergy(o.key),
            padding: EdgeInsetsDirectional.fromSTEB(10.w, 7.h, 16.w, 7.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: _tileH),
              child: Row(
                children: [
                  ExcludeSemantics(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14.r),
                      child: Image.asset(
                        o.image!,
                        width: _tileW,
                        height: _tileH,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(o.label.tr, style: _titleStyle),
                        if (o.sub != null)
                          Text(
                            o.sub!.tr,
                            style: msBody(13, color: kMsSubtitle),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  SetupCheckBox(checked: on, square: true),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
