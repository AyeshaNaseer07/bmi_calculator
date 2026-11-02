import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import 'ad_shimmer.dart';
import 'max_native_ad.dart';
import 'native_ad_card.dart';

class FullScreenNativeAdPage extends StatefulWidget {
  final String? adUnitId;
  final VoidCallback onNext;
  final VoidCallback? onAdFailed;

  const FullScreenNativeAdPage({
    super.key,
    this.adUnitId,
    required this.onNext,
    this.onAdFailed,
  });

  @override
  State<FullScreenNativeAdPage> createState() => _FullScreenNativeAdPageState();
}

class _FullScreenNativeAdPageState extends State<FullScreenNativeAdPage> {
  static const NativeAdPlacement _placement = NativeAdPlacement.fullScreen;

  final MaxNativeAd _ad = NativeAds.of(_placement);
  bool _isFailed = false;
  static const int _closeDelaySeconds = 4;
  int _remainingSeconds = _closeDelaySeconds;
  Timer? _countdownTimer;

  static const int _maxWaitSeconds = 8;
  Timer? _safetyTimer;
  bool _hasAdvanced = false;

  bool get _isLoaded => _ad.state.value == MaxNativeAdState.loaded;

  @override
  void initState() {
    super.initState();
    _loadAd();
    _startCountdown();
    _safetyTimer = Timer(const Duration(seconds: _maxWaitSeconds), () {
      if (mounted && !_isLoaded) {
        _advance();
      }
    });
  }

  void _advance() {
    if (_hasAdvanced) return;
    _hasAdvanced = true;
    widget.onNext();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() => _remainingSeconds = 0);
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  void _fail() {
    if (!mounted || _isFailed) return;
    setState(() => _isFailed = true);
    widget.onAdFailed?.call();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _advance();
    });
  }

  void _loadAd() {
    if (!NativeAds.isEnabled(_placement)) {
      _isFailed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _advance();
      });
      return;
    }
    _ad.state.addListener(_onAdStateChanged);
    NativeAds.preload(_placement, adUnitId: widget.adUnitId).then((started) {
      if (!started) _fail();
    });
  }

  void _onAdStateChanged() {
    if (!mounted) return;
    if (_ad.state.value == MaxNativeAdState.failed) {
      _fail();
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _safetyTimer?.cancel();
    _ad.state.removeListener(_onAdStateChanged);
    if (!_isFailed) _ad.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!NativeAds.isEnabled(_placement)) {
      return const SizedBox.shrink();
    }
    final padding = MediaQuery.of(context).padding;
    final controlTop = math.max(padding.top, 20.0) + 16;
    return Scaffold(
      backgroundColor: AppPalette.surface,
      body: Stack(
        children: [
          Positioned.fill(
            top: controlTop + 28 + 12,
            bottom: padding.bottom + 16,
            left: 16,
            right: 16,
            child: _isFailed
                ? const SizedBox.shrink()
                : _isLoaded
                ? MaxNativeAdView(ad: _ad)
                : const MediumNativeAdShimmer(height: double.infinity),
          ),

          Positioned(
            top: controlTop,
            right: 15,
            child: _remainingSeconds > 0
                ? _CountdownBadge(seconds: _remainingSeconds)
                : GestureDetector(
                    onTap: _advance,
                    behavior: HitTestBehavior.opaque,
                    child: const _CloseBadge(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CountdownBadge extends StatelessWidget {
  final int seconds;

  const _CountdownBadge({required this.seconds});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: Color(0xFF8E8E8E),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$seconds',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CloseBadge extends StatelessWidget {
  const _CloseBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: Color(0xFF8E8E8E),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.close, size: 16, color: Colors.white),
    );
  }
}
