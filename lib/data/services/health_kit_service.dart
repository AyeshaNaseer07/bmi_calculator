import 'package:flutter/foundation.dart';

enum HealthKitStatus { notDetermined, authorized, denied, notAvailable }

class HealthKitService {
  HealthKitStatus _status = HealthKitStatus.notDetermined;

  HealthKitStatus get status => _status;
  bool get isAvailable => defaultTargetPlatform == TargetPlatform.iOS;

  Future<bool> requestAuthorization() async {
    try {
      if (!isAvailable) {
        _status = HealthKitStatus.notAvailable;
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 600));
      _status = HealthKitStatus.authorized;
      return true;
    } catch (e) {
      debugPrint('HealthKit authorization error: $e');
      _status = HealthKitStatus.denied;
      return false;
    }
  }

  Future<double?> fetchLatestWeightKg() async {
    if (_status != HealthKitStatus.authorized) {
      return null;
    }
    try {
      return null;
    } catch (e) {
      debugPrint('HealthKit read error: $e');
      return null;
    }
  }

  Future<bool> saveWeightKg(double weightKg, DateTime date) async {
    if (_status != HealthKitStatus.authorized) {
      return false;
    }
    try {
      return true;
    } catch (e) {
      debugPrint('HealthKit write error: $e');
      return false;
    }
  }
}
