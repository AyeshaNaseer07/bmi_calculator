import 'dart:math' as math;

import 'package:bmi_calculator/core/constants/app_assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/app_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../data/models/remote_model.dart';
import '../../data/services/localization_service.dart';
import '../../data/services/remote_config_service.dart';
import '../widgets/ads/ad_preloader.dart';
import '../widgets/ads/native_ad_card.dart';
import '../widgets/app_background.dart';

enum _HandPhase { tapping, movingToDone, tappingDone, hidden }

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with TickerProviderStateMixin {
  final AppController _appController = Get.find<AppController>();
  String _selectedLang = 'en';
  bool _hasSelected = false;
  bool _bottomAdAvailable = true;

  final GlobalKey _doneButtonKey = GlobalKey();
  final GlobalKey _firstTileKey = GlobalKey();

  _HandPhase _handPhase = _HandPhase.tapping;

  late AnimationController _handController;

  late AnimationController _moveController;
  Animation<Offset>? _moveAnimation;
  Animation<double>? _moveFade;

  Offset? _doneButtonCenter;

  double _handOffsetX = 70;
  double _handOffsetY = 16;

  @override
  void initState() {
    super.initState();
    _selectedLang = _appController.selectedLanguage.value;

    _handController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _moveFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _moveController,
        curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _handController.dispose();
    _moveController.dispose();
    super.dispose();
  }

  void _onLanguageTap(String code) {
    if (_handPhase == _HandPhase.tapping) {
      _flyToDone();
    }
    setState(() {
      _selectedLang = code;
      _hasSelected = true;
    });
    _appController.changeLanguage(code);
  }

  void _flyToDone() {
    _handController.stop();

    final tileBox =
        _firstTileKey.currentContext?.findRenderObject() as RenderBox?;
    final doneBox =
        _doneButtonKey.currentContext?.findRenderObject() as RenderBox?;

    if (tileBox == null || doneBox == null) {
      setState(() => _handPhase = _HandPhase.hidden);
      return;
    }

    final tileGlobal = tileBox.localToGlobal(Offset.zero);
    final doneGlobal = doneBox.localToGlobal(Offset.zero);

    final startPos = Offset(
      tileGlobal.dx + tileBox.size.width / 2 + _handOffsetX,
      tileGlobal.dy + tileBox.size.height / 2 + _handOffsetY,
    );

    final endPos = Offset(
      doneGlobal.dx + doneBox.size.width / 2 + 14.w,
      doneGlobal.dy + doneBox.size.height / 2 + 20.h,
    );

    _moveAnimation = Tween<Offset>(begin: startPos, end: endPos).animate(
      CurvedAnimation(parent: _moveController, curve: Curves.easeInOutCubic),
    );

    _doneButtonCenter = endPos;

    setState(() => _handPhase = _HandPhase.movingToDone);

    _moveController.forward(from: 0).then((_) {
      if (mounted) {
        setState(() => _handPhase = _HandPhase.tappingDone);
        _handController.repeat();
      }
    });
  }

  void _onDone() {
    _appController.changeLanguage(_selectedLang);

    // Same on/off check on every app flow (first launch and every launch
    // after): Remote Config's onboarding flag decides whether the
    // Onboarding slides are shown. The Paywall itself is constant either
    // way — it always follows, whether via Onboarding or directly here.
    if (_isOnboardingEnabled) {
      Get.offNamed(AppRoutes.onboarding);
    } else {
      Get.offNamed(AppRoutes.paywall, arguments: {'fromOnboarding': true});
    }
  }

  bool get _isOnboardingEnabled {
    if (Get.isRegistered<RemoteConfigService>()) {
      return RemoteConfigService.to.isFirstTimeOnboardingEnabled;
    }
    return remoteModel.isFirstTimeOnboarding;
  }

  static const Color _kMint = Color(0xFFC9F2E5);
  static const Color _kCheckGreen = Color(0xFF1BA672);
  static const Color _kAdBackground = Color(0xFFF7F7F7);

  Widget _buildDoneChip() {
    // Always laid out (so the hand animation can measure it) but only
    // visible/tappable once a language has been picked.
    return IgnorePointer(
      ignoring: !_hasSelected,
      child: AnimatedOpacity(
        opacity: _hasSelected ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          key: _doneButtonKey,
          onTap: _onDone,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _kMint,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'done'.tr,
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlag(String flag) {
    final double size = 30.w;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black12, width: 0.5),
      ),
      child: ClipOval(
        child: OverflowBox(
          maxWidth: size * 2,
          maxHeight: size * 2,
          child: Center(
            child: Transform.scale(
              scale: 1.9, // tweak 1.3 - 1.8 until the flag fills the circle
              child: Text(flag, style: TextStyle(fontSize: size, height: 1.0)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadio(bool isSelected) {
    return Container(
      width: 22.w,
      height: 22.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? _kCheckGreen : _kMint,
        border: isSelected
            ? null
            : Border.all(color: const Color(0xFFB3E6D3), width: 1),
      ),
      child: isSelected
          ? Icon(CupertinoIcons.checkmark_alt, size: 13.sp, color: Colors.white)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    _handOffsetX = 70.w;
    _handOffsetY = 16.h;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 16.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'languages'.tr,
                                style: TextStyle(
                                  color: const Color(0xFF111827),
                                  fontSize: 24,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                'select_lang_subtitle'.tr,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Padding(
                          padding: EdgeInsets.only(top: 2.h),
                          child: _buildDoneChip(),
                        ),
                      ],
                    ),
                  ),

                  // Language tiles
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...List.generate(
                                LocalizationService.supportedLanguages.length,
                                (index) {
                                  final lang = LocalizationService
                                      .supportedLanguages[index];
                                  final isSelected =
                                      _hasSelected &&
                                      _selectedLang == lang.code;
                                  final isFirstItem = index == 0;

                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 12.h),
                                    child: GestureDetector(
                                      onTap: () => _onLanguageTap(lang.code),
                                      child: Container(
                                        key: isFirstItem ? _firstTileKey : null,
                                        width: double.infinity,
                                        height: 48.h,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 14.w,
                                        ),
                                        decoration: ShapeDecoration(
                                          color: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              width: 0.25,
                                              color: const Color(0xFF09B389),
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              11,
                                            ),
                                          ),
                                          shadows: [
                                            BoxShadow(
                                              color: Color(0x1633D2AB),
                                              blurRadius: 6.80,
                                              offset: Offset(0, 3),
                                              spreadRadius: 0,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            _buildFlag(lang.flag),
                                            SizedBox(width: 12.w),
                                            Expanded(
                                              child: Text(
                                                lang.nativeName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: const Color(
                                                    0xFF111827,
                                                  ),
                                                  fontFamily: 'Inter',
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 12.w),
                                            _buildRadio(isSelected),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 8.h),
                            ],
                          ),
                          if (_handPhase == _HandPhase.tapping)
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 0,
                              height: 50.h,
                              child: IgnorePointer(
                                child: _TapHandHint(
                                  controller: _handController,
                                  offsetX: _handOffsetX,
                                  offsetY: _handOffsetY,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Flying hand overlay (movingToDone phase) ──
            if (_handPhase == _HandPhase.movingToDone &&
                _moveAnimation != null &&
                _moveFade != null)
              AnimatedBuilder(
                animation: _moveController,
                builder: (ctx, child) {
                  final pos = _moveAnimation!.value;
                  return Positioned(
                    left: pos.dx - 26.w,
                    top: pos.dy - 26.h,
                    child: Opacity(
                      opacity: _moveFade!.value,
                      child: Image.asset(
                        AppAssets.selectLanguage,
                        width: 52.w,
                        height: 52.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),

            if (_handPhase == _HandPhase.tappingDone &&
                _doneButtonCenter != null)
              _DoneButtonHandOverlay(
                controller: _handController,
                center: _doneButtonCenter!,
              ),
          ],
        ),
        bottomNavigationBar: _bottomAdAvailable
            ? Container(
                width: double.infinity,
                color: _kAdBackground,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10.w, 2.h, 10.w, 0),
                    child: NativeAdCard(
                      slot: AdSlots.language,
                      height: 290.h,
                      backgroundColor: Colors.transparent,
                      onAdAvailabilityChanged: (available) {
                        if (!mounted) return;
                        if (_bottomAdAvailable != available) {
                          setState(() => _bottomAdAvailable = available);
                        }
                      },
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class _TapHandHint extends StatelessWidget {
  final AnimationController controller;
  final double offsetX;
  final double offsetY;

  const _TapHandHint({
    required this.controller,
    required this.offsetX,
    required this.offsetY,
  });

  @override
  Widget build(BuildContext context) {
    // 0..0.25 press down | 0.25..0.55 hold + sparkle | 0.55..1.0 lift
    final tapScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.82), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.82, end: 0.82), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.82, end: 1.0), weight: 45),
    ]).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    final floatY = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 6.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 6.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 45),
    ]).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    final sparkleOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 45),
    ]).animate(controller);

    final sparkleRadius = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 22.0), weight: 30),
      TweenSequenceItem(tween: ConstantTween(22.0), weight: 45),
    ]).animate(controller);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Center(
          child: Transform.translate(
            offset: Offset(offsetX, offsetY + floatY.value),
            child: Transform.scale(
              scale: tapScale.value,
              alignment: Alignment.topCenter,
              child: CustomPaint(
                painter: _SparklePainter(
                  opacity: sparkleOpacity.value,
                  radius: sparkleRadius.value,
                ),
                child: Image.asset(
                  AppAssets.selectLanguage,
                  width: 52.w,
                  height: 52.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SparklePainter extends CustomPainter {
  final double opacity;
  final double radius;

  _SparklePainter({required this.opacity, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0 || radius <= 0) return;

    final paint = Paint()
      ..color = const Color(0xFFE53935).withValues(alpha: opacity * 0.85)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(
      size.width * (19.5 / 96.0),
      size.height * (14.0 / 96.0),
    );
    const angles = [
      -math.pi,
      -2.443,
      -math.pi / 2,
      -math.pi / 4,
      -0.175,
      2.531,
    ];

    for (final angle in angles) {
      final innerR = radius * 0.45;
      final outerR = radius;
      final start = Offset(
        center.dx + innerR * math.cos(angle),
        center.dy + innerR * math.sin(angle),
      );
      final end = Offset(
        center.dx + outerR * math.cos(angle),
        center.dy + outerR * math.sin(angle),
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(_SparklePainter old) =>
      old.opacity != opacity || old.radius != radius;
}

class _DoneButtonHandOverlay extends StatelessWidget {
  final AnimationController controller;
  final Offset center;

  const _DoneButtonHandOverlay({
    required this.controller,
    required this.center,
  });

  @override
  Widget build(BuildContext context) {
    // Same sequence as _TapHandHint
    final tapScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.82), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.82, end: 0.82), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.82, end: 1.0), weight: 45),
    ]).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    final floatY = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 6.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 6.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 45),
    ]).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    final sparkleOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 45),
    ]).animate(controller);

    final sparkleRadius = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 22.0), weight: 30),
      TweenSequenceItem(tween: ConstantTween(22.0), weight: 45),
    ]).animate(controller);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final left = center.dx - 26.w;
        final top = center.dy - 26.h + floatY.value;

        return Positioned(
          left: left,
          top: top,
          child: Transform.scale(
            scale: tapScale.value,
            alignment: Alignment.topCenter,
            child: CustomPaint(
              painter: _SparklePainter(
                opacity: sparkleOpacity.value,
                radius: sparkleRadius.value,
              ),
              child: Image.asset(
                AppAssets.selectLanguage,
                width: 52.w,
                height: 52.h,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }
}
