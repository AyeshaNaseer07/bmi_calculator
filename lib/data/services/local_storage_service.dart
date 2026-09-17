import 'package:bmi_calculator/core/constants/storage_key.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  late final SharedPreferences _prefs;

  LocalStorageService._();

  int? getInt(String key) => _prefs.getInt(key);
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  static Future<LocalStorageService> init() async {
    final service = LocalStorageService._();
    service._prefs = await SharedPreferences.getInstance();
    return service;
  }

  T? read<T>(String key) {
    if (T == bool) return _prefs.getBool(key) as T?;
    if (T == String) return _prefs.getString(key) as T?;
    if (T == int) return _prefs.getInt(key) as T?;
    if (T == double) return _prefs.getDouble(key) as T?;
    return null;
  }

  Future<bool> write<T>(String key, T value) {
    if (value is bool) return _prefs.setBool(key, value);
    if (value is String) return _prefs.setString(key, value);
    if (value is int) return _prefs.setInt(key, value);
    if (value is double) return _prefs.setDouble(key, value);
    throw ArgumentError(
      'Unsupported type for key "$key": ${value.runtimeType}',
    );
  }

  // ── Onboarding ──
  bool get isOnboarded =>
      kDebugMode ? false : _prefs.getBool(StorageKeys.isOnboarded) ?? false;
  Future<bool> setOnboarded(bool value) =>
      _prefs.setBool(StorageKeys.isOnboarded, value);

  // ── Premium ──
  bool get isPremium => _prefs.getBool(StorageKeys.isPremium) ?? false;
  Future<bool> setPremium(bool value) =>
      _prefs.setBool(StorageKeys.isPremium, value);

  // ── Generic helpers ──
  String? getString(String key) => _prefs.getString(key);

  // ── Notifications ──
  bool get isNotificationGranted =>
      _prefs.getBool(StorageKeys.notificationGranted) ?? false;
  Future<bool> setNotificationGranted(bool value) =>
      _prefs.setBool(StorageKeys.notificationGranted, value);

  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  bool? getBool(String key) => _prefs.getBool(key);

  Future<bool> remove(String key) => _prefs.remove(key);

  Future<bool> clear() => _prefs.clear();
}
