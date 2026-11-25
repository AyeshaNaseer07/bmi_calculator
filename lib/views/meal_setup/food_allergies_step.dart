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

  @override
  void initState() {
    super.initState();
    _other = TextEditingController(text: c.otherAllergy.value);
  }

  @override
  void dispose() {
    _other.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SetupScaffold(
      step: 3,
      titleTop: 'ms_food'.tr,
      titleBottom: 'ms_allergies'.tr,
      subtitle: 'ms_allergies_subtitle'.tr,
      hero: MealSetupAssets.allergies,
      heroEmoji: '🥜',
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
                SizedBox(width: 14.w),
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
                    onChanged: (v) => c.otherAllergy.value = v,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottom: SetupCta(
        text: 'next'.tr,
        onPressed: () {
          FocusScope.of(context).unfocus();
          MealSetupFlow.next(3);
        },
      ),
    );
  }

  TextStyle get _titleStyle => TextStyle(
    color: kMsNavy,
    fontSize: 15.sp,
    fontFamily: 'Outfit',
    fontWeight: FontWeight.w700,
  );

  /// 72×42 mint pill holding the item icon.
  Widget _pill({required Widget child}) => Container(
    width: 72.w,
    height: 42.w,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: kMsMint,
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: child,
  );

  Widget _row(SetupOption o) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
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
              constraints: BoxConstraints(minHeight: 42.w),
              child: Row(
                children: [
                  // 3D icon already has its mint pill baked in.
                  ExcludeSemantics(
                    child: Image.asset(
                      o.image!,
                      width: 72.w,
                      height: 42.w,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 14.w),
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
