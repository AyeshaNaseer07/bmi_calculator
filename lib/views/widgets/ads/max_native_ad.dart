import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

bool get _isSupported => Platform.isIOS || Platform.isAndroid;

const String _viewType = 'max_native_ad_view';

enum MaxNativeAdState { idle, loading, loaded, failed }

class MaxNativeAd {
  MaxNativeAd(this.placement) {
    _ads[placement] = this;
  }

  /// Unique key for this ad, e.g. 'home'
  final String placement;

  final ValueNotifier<MaxNativeAdState> state = ValueNotifier(
    MaxNativeAdState.idle,
  );
  String? _adUnitId;

  String? get adUnitId => _adUnitId;

  /// Called for each paid impression, e.g. to log revenue
  static void Function(MaxNativeAd ad, String networkName, double revenue)?
  onRevenuePaid;

  /// Called when the user taps the ad and leaves the app
  static void Function(MaxNativeAd ad)? onAdClicked;

  static const MethodChannel _channel = MethodChannel('max_native_ad');
  static final Map<String, MaxNativeAd> _ads = {};
  static bool _isListening = false;

  bool get isLoadingOrLoaded =>
      state.value == MaxNativeAdState.loading ||
      state.value == MaxNativeAdState.loaded;

  /// Starts loading the ad, ideally a screen or two before it is shown
  void preload(String adUnitId) {
    if (!_isSupported || isLoadingOrLoaded) return;
    _listen();

    _adUnitId = adUnitId;
    state.value = MaxNativeAdState.loading;
    _channel
        .invokeMethod('preload', {'placement': placement, 'adUnitId': adUnitId})
        .catchError((e) {
          debugPrint('[MaxNativeAd] ($placement) preload failed: $e');
          state.value = MaxNativeAdState.failed;
        });
  }

  /// Releases the ad once its screen is done with it
  void destroy() {
    state.value = MaxNativeAdState.idle;
    if (!_isSupported) return;
    _channel.invokeMethod('destroy', {'placement': placement}).catchError((e) {
      debugPrint('[MaxNativeAd] ($placement) destroy failed: $e');
    });
  }

  static void _listen() {
    if (_isListening) return;
    _isListening = true;
    _channel.setMethodCallHandler(_onEvent);
  }

  static Future<void> _onEvent(MethodCall call) async {
    final args = Map<String, dynamic>.from(call.arguments as Map);
    final ad = _ads[args['placement']];
    if (ad == null) return;

    switch (call.method) {
      case 'onAdLoaded':
        debugPrint('[MaxNativeAd] (${ad.placement}) loaded');
        ad.state.value = MaxNativeAdState.loaded;
      case 'onAdLoadFailed':
        debugPrint(
          '[MaxNativeAd] (${ad.placement}) failed to load: ${args['message']} (code ${args['code']})',
        );
        ad.state.value = MaxNativeAdState.failed;
      case 'onAdExpired':
        // Expired before it was shown: load a fresh one
        ad.state.value = MaxNativeAdState.idle;
        final adUnitId = ad._adUnitId;
        if (adUnitId != null) ad.preload(adUnitId);
      case 'onAdClicked':
        onAdClicked?.call(ad);
      case 'onAdRevenuePaid':
        onRevenuePaid?.call(
          ad,
          args['networkName'] as String? ?? '',
          (args['revenue'] as num?)?.toDouble() ?? 0,
        );
    }
  }
}

class MaxNativeAdView extends StatelessWidget {
  const MaxNativeAdView({super.key, required this.ad});

  final MaxNativeAd ad;

  @override
  Widget build(BuildContext context) {
    if (!_isSupported) return const SizedBox.shrink();
    return ValueListenableBuilder<MaxNativeAdState>(
      valueListenable: ad.state,
      builder: (context, state, _) {
        if (state != MaxNativeAdState.loaded) return const SizedBox.shrink();
        if (Platform.isAndroid) return _buildAndroidView(context);
        return UiKitView(
          // A new key per ad, so a reloaded ad gets a fresh native view
          key: ObjectKey(ad),
          viewType: _viewType,
          creationParams: {'placement': ad.placement},
          creationParamsCodec: const StandardMessageCodec(),
        );
      },
    );
  }

  Widget _buildAndroidView(BuildContext context) {
    final direction = Directionality.of(context);
    return PlatformViewLink(
      // A new key per ad, so a reloaded ad gets a fresh native view
      key: ObjectKey(ad),
      viewType: _viewType,
      surfaceFactory: (context, controller) => AndroidViewSurface(
        controller: controller as AndroidViewController,
        gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
        hitTestBehavior: PlatformViewHitTestBehavior.opaque,
      ),
      onCreatePlatformView: (params) =>
          PlatformViewsService.initExpensiveAndroidView(
              id: params.id,
              viewType: _viewType,
              layoutDirection: direction,
              creationParams: {'placement': ad.placement},
              creationParamsCodec: const StandardMessageCodec(),
              onFocus: () => params.onFocusChanged(true),
            )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..create(),
    );
  }
}
