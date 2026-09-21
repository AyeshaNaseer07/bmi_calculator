import 'package:bmi_calculator/data/models/remote_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RemoteModel Tests', () {
    test('Default values are correct and only include requested parameters', () {
      final defaults = RemoteModel.defaults();

      expect(defaults.firstTimeOnboarding, 'on');
      expect(defaults.isFirstTimeOnboarding, isTrue);

      expect(defaults.secondTimeOnboarding, 'off');
      expect(defaults.isSecondTimeOnboarding, isFalse);

      expect(defaults.paywallBtnText, 'Start Free Trial');
      expect(defaults.crossDelay, 3);
      expect(defaults.monthlyProductId, 'com.monthly.bmi.calculator');
      expect(defaults.yearlyProductId, 'com.yearly.bmi.calculator');
      expect(defaults.nativeAdId, isNotEmpty);

      expect(defaults.ads, 'on');
      expect(defaults.isAdsEnabled, isTrue);

      expect(defaults.localNotification, 'on');
      expect(defaults.isLocalNotificationEnabled, isTrue);
    });

    test('Parses remote config with custom values correctly', () {
      final remoteConfig = {
        'first_time_onboarding': 'off',
        'second_time_onboarding': 'on',
        'paywall_btn_text': 'Unlock Premium Access',
        'cross_delay': 5,
        'monthly_product_id': 'custom.monthly.id',
        'yearly_product_id': 'custom.yearly.id',
        'native_ad_id': 'custom_ad_unit_123',
        'ads': 'off',
        'local_notification': 'off',
      };

      final model = RemoteModel.fromRemoteConfig(remoteConfig);

      expect(model.firstTimeOnboarding, 'off');
      expect(model.isFirstTimeOnboarding, isFalse);

      expect(model.secondTimeOnboarding, 'on');
      expect(model.isSecondTimeOnboarding, isTrue);

      expect(model.paywallBtnText, 'Unlock Premium Access');
      expect(model.crossDelay, 5);
      expect(model.monthlyProductId, 'custom.monthly.id');
      expect(model.yearlyProductId, 'custom.yearly.id');
      expect(model.nativeAdId, 'custom_ad_unit_123');

      expect(model.ads, 'off');
      expect(model.isAdsEnabled, isFalse);

      expect(model.localNotification, 'off');
      expect(model.isLocalNotificationEnabled, isFalse);
    });

    test('toJson contains only the 6 required parameter groups', () {
      final model = RemoteModel.defaults();
      final json = model.toJson();

      expect(json.keys.toSet(), {
        'first_time_onboarding',
        'second_time_onboarding',
        'paywall_btn_text',
        'cross_delay',
        'monthly_product_id',
        'yearly_product_id',
        'native_ad_id',
        'ads',
        'local_notification',
      });
      // Verifying extra parameters are NOT present
      expect(json.containsKey('monthly_price'), isFalse);
      expect(json.containsKey('yearly_price'), isFalse);
      expect(json.containsKey('trial_subtitle'), isFalse);
      expect(json.containsKey('premium_discount_cross_delay'), isFalse);
      expect(json.containsKey('premium_discount_btn_text'), isFalse);
      expect(json.containsKey('premium_discount_offer_product_id'), isFalse);
      expect(json.containsKey('onboarding_default_selection'), isFalse);
    });
  });
}
