import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/meal_setup_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/rtl.dart';
import '../../data/models/user_profile_model.dart';
import '../widgets/animated_cta_button.dart';
import '../widgets/custom_app_bar.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/cta_arrow_lottie.dart';

// ── Design tokens (Personalized Meal Plan developer kit) ──
const Color kMsBg = Color(0xFFF3FAF8);
const Color kMsNavy = Color(0xFF1D2B3A);
const Color kMsGreen = Color(0xFF17B890);
const Color kMsGreenDeep = Color(0xFF128C6E);
const Color kMsMint = Color(0xFFE6F8F3);
const Color kMsMintSoft = Color(0xFFF2FBF8);
const Color kMsBorder = Color(0xFFE8F1EE);
const Color kMsChipBorder = Color(0xFFE2E8F0);
const Color kMsChipText = Color(0xFF334155);
const Color kMsTextSecondary = Color(0xFF64748B);
const Color kMsSubtitle = Color(0xFF475569);
const Color kMsRequiredBg = Color(0xFFE2F7F0);
const Color kMsPlaceholder = Color(0xFF94A3B8);
const Color kMsBlue = Color(0xFF1D63B8);
const Color kMsBlueSoft = Color(0xFFE3F1FD);

/// Images and icons for the setup flow.
abstract class MealSetupAssets {
  static const String _ic = 'assets/icons';

  /// Hero ids, one per screen.
  static const String overview = 'overview';
  static const String health = 'health';
  static const String medical = 'medical';
  static const String allergies = 'allergies';
  static const String diet = 'diet';
  static const String lifestyle = 'lifestyle';

  /// Hero avatar — the same home art on every screen, picked by gender.
  static String homeArt(Gender? gender) {
    return switch (gender) {
      Gender.female => AppAssets.homeImgFemale,
      Gender.male => AppAssets.homeAvatar,
      _ => AppAssets.homeAvatarDefault,
    };
  }

  // 3D section icons (mint tile baked in).
  static const String icHealthProfile = AppAssets.msHealthProfile;
  static const String icMedical = AppAssets.msMedicalConditions;
  static const String icAllergies = AppAssets.msFoodAllergies;
  static const String icDiet = AppAssets.msDietaryPreferences;
  static const String icLifestyle = AppAssets.msLifestyleInfo;

  // Vector icons.
  static const String cardArrow = '$_ic/ms_card_arrow_right.svg';
  static const String badgeRequired = '$_ic/ms_badge_required_check.svg';
  static const String badgeRecommended = '$_ic/ms_badge_recommended_info.svg';
  static const String chevronDown = '$_ic/ms_chevron_down.svg';
  static const String backArrowGreen = '$_ic/ms_back_arrow_green.svg';
  static const String checkActive = '$_ic/ms_check_circle_active.svg';
  static const String checkEmpty = '$_ic/ms_checkbox_unchecked.svg';
  static const String checkSquare = '$_ic/ms_checkbox_checked.svg';
  static const String plus = '$_ic/ms_plus.svg';
  static const String pencil = '$_ic/ms_pencil.svg';
  static const String lock = '$_ic/ms_lock.svg';

  // Lifestyle section icons (flat vectors).
  static const String secExercise = '$_ic/ms_section_exercise.svg';
  static const String secSleep = '$_ic/ms_section_sleep.svg';
  static const String secWater = '$_ic/ms_section_water.svg';
  static const String secMealClock = '$_ic/ms_section_meal_clock.svg';
  static const String secNotes = '$_ic/ms_section_notes.svg';
  static const String otherDots = '$_ic/ms_other_dots.svg';
  static const String genderMale = '$_ic/ms_gender_male.svg';
  static const String genderFemale = '$_ic/ms_gender_female.svg';
  static const String genderOther = '$_ic/ms_gender_other.svg';

  // Health Profile field icons.
  static const String icAge = AppAssets.msAge;
  static const String icGender = AppAssets.msGender;
  static const String icHeight = AppAssets.msHeight;
  static const String icWeight = AppAssets.msCurrentWeight;
  static const String icGoal = AppAssets.msHealthGoal;
  static const String icActivity = AppAssets.msActivityLevel;
}

TextStyle msTitle(double size, {Color color = kMsNavy}) => TextStyle(
  color: color,
  fontSize: size.sp,
  fontFamily: 'Outfit',
  fontWeight: FontWeight.w700,
  height: 1.1,
  letterSpacing: -0.3,
);

TextStyle msBody(
  double size, {
  Color color = AppPalette.textBody,
  FontWeight weight = FontWeight.w400,
  double? height,
}) => TextStyle(
  color: color,
  fontSize: size.sp,
  fontFamily: 'Inter',
  fontWeight: weight,
  height: height,
);

class SetupScaffold extends StatelessWidget {
  /// 0 for the overview, 1–5 for the steps.
  final int step;
  final bool showStepChip;
  final String titleTop;
  final String titleBottom;
  final String subtitle;

  /// One of the [MealSetupAssets] hero ids.
  final String hero;
  final Widget body;
  final Widget bottom;
  final Widget? footer;

  const SetupScaffold({
    super.key,
    required this.step,
    required this.titleTop,
    required this.titleBottom,
    required this.subtitle,
    required this.hero,
    required this.body,
    required this.bottom,
    this.showStepChip = true,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: kMsBg,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [_header(), body],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [bottom, ?footer],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// One title line, shrunk to fit rather than broken mid-word.
  Widget _titleLine(String text, Color color) => FittedBox(
    fit: BoxFit.scaleDown,
    alignment: AlignmentDirectional.centerStart,
    child: Text(text, maxLines: 1, style: msTitle(28, color: color)),
  );

  Widget _header() {
    // Hero bleeds to the screen edge (past the 16.w page padding).
    final heroW = 0.54.sw;
    final heroH = heroW * 286 / 341;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        PositionedDirectional(
          top: -8.h,
          end: -16.w,
          child: SetupHero(screen: hero, width: heroW, height: heroH),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: heroH - 20.h),
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start: 4.w,
              end: heroW * 0.86 - 16.w,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SetupBackCircle(),
                    if (showStepChip && step > 0) ...[],
                  ],
                ),
                SizedBox(height: 12.h),
                _titleLine(titleTop, kMsNavy),
                if (titleBottom.isNotEmpty) _titleLine(titleBottom, kMsGreen),
                SizedBox(height: 8.h),
                Text(
                  subtitle,
                  style: msBody(12, color: kMsSubtitle, height: 1.35),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Back button: the app-wide [AppBackIcon] artwork.
class SetupBackCircle extends StatelessWidget {
  const SetupBackCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'ms_back'.tr,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Get.back(),
        child: const AppBackIcon(),
      ),
    );
  }
}

class SetupHero extends StatelessWidget {
  final String screen;
  final double width;
  final double height;

  const SetupHero({
    super.key,
    required this.screen,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final dir = Directionality.of(context);
    return ExcludeSemantics(
      child: Obx(() {
        final gender = MealSetupController.to.gender.value;
        final homeArt = MealSetupAssets.homeArt(gender);
        return ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (r) => LinearGradient(
            begin: AlignmentDirectional.centerStart.resolve(dir),
            end: AlignmentDirectional.centerEnd.resolve(dir),
            colors: const [Colors.transparent, Colors.black],
            stops: const [0, 0.16],
          ).createShader(r),
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (r) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black54,
                Colors.black,
                Colors.black,
                Colors.transparent,
              ],
              stops: [0, 0.08, 0.18, 0.84, 1],
            ).createShader(r),
            child: _homeArtCrop(homeArt),
          ),
        );
      }),
    );
  }

  static const double _homeArtZoom = 1125 / 780;
  Widget _homeArtCrop(String asset) => ClipRect(
    child: SizedBox(
      width: width,
      height: height,
      child: OverflowBox(
        alignment: Alignment.topRight,
        minWidth: width * _homeArtZoom,
        maxWidth: width * _homeArtZoom,
        maxHeight: double.infinity,
        child: Image.asset(
          asset,
          key: ValueKey(asset),
          width: width * _homeArtZoom,
          fit: BoxFit.fitWidth,
          alignment: Alignment.topRight,
          errorBuilder: (_, _, _) => _placeholder(),
        ),
      ),
    ),
  );

  Widget _placeholder() => SizedBox(width: width, height: height);
}

/// White rounded card used for every row in the flow.
class SetupCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool selected;
  final VoidCallback? onTap;
  final double radius;

  const SetupCard({
    super.key,
    required this.child,
    this.padding,
    this.selected = false,
    this.onTap,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: selected ? kMsMintSoft : AppPalette.surface,
        borderRadius: BorderRadius.circular(radius.r),
        border: Border.all(
          color: selected ? kMsGreen.withValues(alpha: 0.55) : kMsBorder,
          width: selected ? 1.4 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1D2B3A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: card,
    );
  }
}

/// Mint rounded square holding an emoji or an icon.
class SetupIconTile extends StatelessWidget {
  final String? emoji;
  final IconData? icon;

  /// 3D icon PNG from the kit (tile background already baked in).
  final String? image;
  final double size;
  final bool circle;
  final Color color;

  const SetupIconTile({
    super.key,
    this.emoji,
    this.icon,
    this.image,
    this.size = 56,
    this.circle = false,
    this.color = kMsMint,
  });

  @override
  Widget build(BuildContext context) {
    final s = size.w;
    if (image != null) {
      return ExcludeSemantics(
        child: Image.asset(image!, width: s, fit: BoxFit.fitWidth),
      );
    }
    return ExcludeSemantics(
      child: Container(
        width: s,
        height: s,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circle ? null : BorderRadius.circular(16.r),
        ),
        child: icon != null
            ? Icon(icon, color: kMsGreen, size: s * 0.52)
            : Text(emoji ?? '', style: TextStyle(fontSize: s * 0.46)),
      ),
    );
  }
}

class SetupCheckBox extends StatelessWidget {
  final bool checked;
  final double size;
  final bool square;
  const SetupCheckBox({
    super.key,
    required this.checked,
    this.size = 24,
    this.square = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
      child: SvgPicture.asset(
        !checked
            ? MealSetupAssets.checkEmpty
            : (square
                  ? MealSetupAssets.checkSquare
                  : MealSetupAssets.checkActive),
        key: ValueKey(checked),
        width: size.w,
        height: size.w,
      ),
    );
  }
}

/// Pill option. Selected pills get a mint fill, green border and a check.
class SetupChip extends StatelessWidget {
  final String label;
  final String? sublabel;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  const SetupChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.sublabel,
    this.icon,
  });

  /// How much wider a chip gets when its check mark shows.
  static double get checkExtraWidth => (6 + 16 + 4 - 10).w;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: BoxConstraints(minHeight: 32.h),
          padding: EdgeInsetsDirectional.fromSTEB(
            selected ? 6.w : 10.w,
            5.h,
            10.w,
            5.h,
          ),
          decoration: BoxDecoration(
            color: selected ? kMsMint : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: selected ? kMsGreen : kMsChipBorder,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                SvgPicture.asset(
                  MealSetupAssets.checkActive,
                  width: 16.w,
                  height: 16.w,
                ),
                SizedBox(width: 4.w),
              ] else if (icon != null) ...[
                Icon(icon, size: 18.w, color: AppPalette.textSecondary),
                SizedBox(width: 6.w),
              ],
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    softWrap: false,
                    style: msBody(
                      12.5,
                      color: selected ? kMsGreenDeep : kMsChipText,
                      weight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  if (sublabel != null)
                    Text(
                      sublabel!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      softWrap: false,
                      style: msBody(
                        10,
                        color: selected
                            ? kMsGreenDeep
                            : AppPalette.textSecondary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Required" / "Recommended" pill on the overview cards.
class SetupBadge extends StatelessWidget {
  final bool required;
  const SetupBadge({super.key, required this.required});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22.h,
      padding: EdgeInsetsDirectional.fromSTEB(4.w, 0, 10.w, 0),
      decoration: BoxDecoration(
        color: required ? kMsRequiredBg : kMsBlueSoft,
        borderRadius: BorderRadius.circular(11.h),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            required
                ? MealSetupAssets.badgeRequired
                : MealSetupAssets.badgeRecommended,
            width: 16.w,
            height: 16.w,
          ),
          SizedBox(width: 5.w),
          Flexible(
            child: Text(
              required ? 'ms_required'.tr : 'ms_recommended'.tr,
              style: msBody(
                11,
                color: required ? kMsGreenDeep : kMsBlue,
                weight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded input with an optional tappable unit suffix.
class SetupTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hint;
  final String? suffix;
  final VoidCallback? onSuffixTap;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int maxLines;
  final Widget? prefixIcon;
  final bool showCounter;
  final bool error;

  /// Shows a chevron after the suffix (e.g. "Years ⌄").
  final bool suffixChevron;
  final Color hintColor;
  final double radius;
  final double hintSize;
  final double verticalPadding;

  const SetupTextField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.hint,
    this.suffix,
    this.onSuffixTap,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.prefixIcon,
    this.showCounter = false,
    this.error = false,
    this.suffixChevron = false,
    this.hintColor = kMsTextSecondary,
    this.radius = 14,
    this.hintSize = 15,
    this.verticalPadding = 11,
  });

  static final decimal = [
    FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}([.,]\d{0,1})?')),
  ];
  static final digits = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(3),
  ];

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius.r),
      borderSide: BorderSide(color: c, width: w),
    );
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      maxLines: maxLines,
      minLines: 1,
      textInputAction: maxLines > 1
          ? TextInputAction.newline
          : TextInputAction.done,
      style: msBody(15, color: kMsNavy, weight: FontWeight.w500),
      cursorColor: kMsGreen,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: msBody(hintSize, color: hintColor),
        counterText: showCounter ? null : '',
        counterStyle: msBody(10, color: AppPalette.textMuted),
        prefixIcon: prefixIcon,
        prefixIconConstraints: BoxConstraints(minWidth: 36.w),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: verticalPadding.h,
        ),
        suffixIcon: suffix == null
            ? null
            : GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onSuffixTap,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(end: 12.w, start: 4.w),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        suffix!,
                        style: msBody(
                          14,
                          color: kMsGreen,
                          weight: FontWeight.w600,
                        ),
                      ),
                      if (suffixChevron) ...[
                        SizedBox(width: 8.w),
                        SvgPicture.asset(
                          MealSetupAssets.chevronDown,
                          width: 18.w,
                          height: 18.w,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
        suffixIconConstraints: const BoxConstraints(),
        enabledBorder: border(error ? const Color(0xFFEF4444) : kMsChipBorder),
        focusedBorder: border(error ? const Color(0xFFEF4444) : kMsGreen, 1.4),
      ),
    );
  }
}

/// Field-looking dropdown backed by a popup menu.
class SetupDropdown<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelected;
  final double height;
  final double radius;

  const SetupDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onSelected,
    this.height = 42,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final v = value;
    return PopupMenuButton<T>(
      onSelected: onSelected,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      position: PopupMenuPosition.under,
      itemBuilder: (_) => [
        for (final item in items)
          PopupMenuItem<T>(
            value: item,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    labelOf(item),
                    style: msBody(
                      14,
                      color: item == v ? kMsGreenDeep : AppPalette.textPrimary,
                      weight: item == v ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (item == v)
                  Icon(Icons.check_rounded, color: kMsGreen, size: 18.w),
              ],
            ),
          ),
      ],
      child: Container(
        height: height.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius.r),
          border: Border.all(color: kMsChipBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                v == null ? hint : labelOf(v),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: msBody(
                  15,
                  color: v == null ? kMsTextSecondary : kMsNavy,
                  weight: v == null ? FontWeight.w400 : FontWeight.w500,
                ),
              ),
            ),
            SvgPicture.asset(
              MealSetupAssets.chevronDown,
              width: 20.w,
              height: 20.w,
            ),
          ],
        ),
      ),
    );
  }
}

class SetupCta extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool enabled;
  final bool sparkles;
  final double height;
  final double fontSize;

  const SetupCta({
    super.key,
    required this.text,
    required this.onPressed,
    this.enabled = true,
    this.sparkles = true,
    this.height = 54,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final button = AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1 : 0.55,
      child: AnimatedCtaButton(
        text: text,
        height: height.h,
        width: double.infinity,
        enablePulse: enabled,
        enableShimmer: enabled,
        enableArrowNudge: enabled,
        borderRadius: BorderRadius.circular((height / 2).h),
        gradient: AppColors.ctaGradient,
        textStyle: TextStyle(
          color: Colors.white,
          fontSize: fontSize.sp,
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w700,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 22.w),
        trailingIcon: CtaArrowLottie(size: 30.w),
        onPressed: onPressed,
      ),
    );
    if (!sparkles) return button;
    return Row(
      children: [
        const SetupSparkle(),
        SizedBox(width: 6.w),
        Expanded(child: button),
        SizedBox(width: 6.w),
        const SetupSparkle(mirror: true),
      ],
    );
  }
}

/// Three short strokes fanning outwards beside the CTA.
class SetupSparkle extends StatelessWidget {
  final bool mirror;
  const SetupSparkle({super.key, this.mirror = false});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Transform.flip(
        flipX: mirror,
        child: CustomPaint(size: Size(20.w, 34.h), painter: _SparklePainter()),
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kMsGreen
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final origin = Offset(size.width, size.height / 2);
    final len = size.width * 0.55;
    for (final deg in [-35.0, 0.0, 35.0]) {
      final a = math.pi + deg * math.pi / 180;
      final dir = Offset(math.cos(a), math.sin(a));
      final start = origin + dir * (size.width * 0.3);
      canvas.drawLine(start, start + dir * len, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Outlined "← Back" pill used next to Next on the medical step.
class SetupBackButton extends StatelessWidget {
  final double height;
  const SetupBackButton({super.key, this.height = 52});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Get.back(),
        child: Container(
          height: height.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular((height / 2).h),
            border: Border.all(color: kMsGreen, width: 1.4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MirrorOnRtl(
                child: SvgPicture.asset(
                  MealSetupAssets.backArrowGreen,
                  width: 22.w,
                  height: 22.w,
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'ms_back'.tr,
                    maxLines: 1,
                    style: TextStyle(
                      color: kMsGreen,
                      fontSize: 17.sp,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SetupNoneBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const SetupNoneBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsetsDirectional.fromSTEB(14.w, 12.h, 14.w, 12.h),
          decoration: BoxDecoration(
            color: selected ? kMsMint : Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: selected ? kMsGreen : kMsBorder,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                MealSetupAssets.checkActive,
                width: 38.w,
                height: 38.w,
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: msBody(
                        13.5,
                        color: kMsNavy,
                        weight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: msBody(
                        10.5,
                        color: kMsTextSecondary,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              SetupCheckBox(checked: selected, size: 26),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card heading: title + subtitle.
class SetupCardTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? titleSuffix;
  final double titleSize;
  final Color subtitleColor;

  const SetupCardTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.titleSuffix,
    this.titleSize = 17,
    this.subtitleColor = kMsTextSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            text: title,
            children: [
              if (titleSuffix != null)
                TextSpan(
                  text: ' $titleSuffix',
                  style: msBody(
                    14,
                    color: AppPalette.textSecondary,
                    weight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          style: TextStyle(
            color: kMsNavy,
            fontSize: titleSize.sp,
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 2.h),
          Text(subtitle!, style: msBody(13, color: subtitleColor, height: 1.3)),
        ],
      ],
    );
  }
}

/// Shows a short validation message.
void showSetupHint(String message) {
  Get.closeCurrentSnackbar();
  Get.snackbar(
    'ms_almost_there'.tr,
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.white,
    colorText: kMsNavy,
    margin: EdgeInsets.all(16.w),
    borderRadius: 16.r,
    duration: const Duration(seconds: 2),
    icon: const Icon(Icons.info_outline_rounded, color: kMsGreen),
  );
}
