import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/meal_setup_controller.dart';
import '../../core/utils/rtl.dart';
import 'meal_setup_common.dart';
import 'meal_setup_flow.dart';

/// "Personalized Meal Plan" — overview of the five setup sections.
class MealPlanSetupScreen extends StatelessWidget {
  const MealPlanSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = MealSetupController.to;
    return SetupScaffold(
      step: 0,
      titleTop: 'ms_personalized'.tr,
      titleBottom: 'ms_meal_plan'.tr,
      subtitle: 'ms_overview_subtitle'.tr,
      hero: MealSetupAssets.overview,
      heroEmoji: '🥗',
      body: Obx(() {
        final done = c.completedSteps.toSet();
        return Column(
          children: [
            _SectionCard(
              step: 1,
              image: MealSetupAssets.icHealthProfile,
              title: 'ms_health_profile'.tr,
              subtitle: 'ms_health_profile_desc'.tr,
              required: true,
              done: done.contains(1),
            ),
            _SectionCard(
              step: 2,
              image: MealSetupAssets.icMedical,
              title: 'ms_medical_conditions'.tr,
              subtitle: 'ms_medical_conditions_desc'.tr,
              required: true,
              done: done.contains(2),
            ),
            _SectionCard(
              step: 3,
              image: MealSetupAssets.icAllergies,
              title: 'ms_food_allergies'.tr,
              subtitle: 'ms_food_allergies_desc'.tr,
              required: true,
              done: done.contains(3),
            ),
            _SectionCard(
              step: 4,
              image: MealSetupAssets.icDiet,
              title: 'ms_dietary_preferences'.tr,
              subtitle: 'ms_dietary_preferences_desc'.tr,
              required: true,
              done: done.contains(4),
            ),
            _SectionCard(
              step: 5,
              image: MealSetupAssets.icLifestyle,
              title: 'ms_lifestyle_info'.tr,
              subtitle: 'ms_lifestyle_info_desc'.tr,
              required: true,
              done: done.contains(5),
            ),
          ],
        );
      }),
      bottom: SetupCta(
        text: 'continue_btn'.tr,
        onPressed: MealSetupFlow.continueFromOverview,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final int step;
  final String image;
  final String title;
  final String subtitle;
  final bool required;
  final bool done;

  const _SectionCard({
    required this.step,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.required,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Semantics(
        button: true,
        label: '$title. $subtitle',
        child: SetupCard(
          onTap: () => MealSetupFlow.openStep(step),
          padding: EdgeInsetsDirectional.fromSTEB(12.w, 12.h, 14.w, 12.h),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 68.h),
            child: Row(
              children: [
                SetupIconTile(image: image, size: 64),
                SizedBox(width: 14.w),
                Expanded(
                  child: ExcludeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SetupCardTitle(title: title, subtitle: subtitle),
                        SizedBox(height: 6.h),
                        SetupBadge(required: required),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36.w,
                  height: 36.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: done ? kMsGreen : kMsMint,
                    shape: BoxShape.circle,
                  ),
                  child: done
                      ? Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 20.w,
                        )
                      : MirrorOnRtl(
                          child: SvgPicture.asset(
                            MealSetupAssets.cardArrow,
                            width: 20.w,
                            height: 20.w,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
