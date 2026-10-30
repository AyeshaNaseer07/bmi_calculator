import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/bmi_record_model.dart';
import '../models/user_profile_model.dart';
import '../models/weight_record_model.dart';

class StorageService {
  static const String _keyOnboardingSeen = 'onboarding_seen';
  static const String _keyLanguage = 'selected_language';
  static const String _keyUnitSystem = 'unit_system';
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keyDarkMode = 'dark_mode';
  static const String _keyIsPremium = 'is_premium';
  static const String _keyPremiumInstallId = 'premium_install_id';
  static const String _keyUserProfile = 'user_profile';
  static const String _keyBmiHistory = 'bmi_history';
  static const String _keyWeightHistory = 'weight_history';
  static const String _keyProfileImagePath = 'profile_image_path';
  static const String _keyRemoteButtonText = 'rc_button_text';
  static const String _keyLastWeightEntry = 'last_weight_entry';
  static const String _keyWaterGlasses = 'water_glasses';
  static const String _keyWaterGlassesDay = 'water_glasses_day';

  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // ── Onboarding ──
  bool getOnboardingSeen() => _prefs.getBool(_keyOnboardingSeen) ?? false;

  Future<void> setOnboardingSeen(bool seen) =>
      _prefs.setBool(_keyOnboardingSeen, seen);

  // ── Language ──
  String getLanguage() => _prefs.getString(_keyLanguage) ?? 'en';
  Future<void> setLanguage(String code) => _prefs.setString(_keyLanguage, code);

  // ── Unit System ──
  UnitSystem getUnitSystem() {
    final name = _prefs.getString(_keyUnitSystem);
    return UnitSystem.values.firstWhere(
      (e) => e.name == name,
      orElse: () => UnitSystem.metric,
    );
  }

  Future<void> setUnitSystem(UnitSystem unit) =>
      _prefs.setString(_keyUnitSystem, unit.name);

  // ── Theme ──
  bool getDarkMode() => _prefs.getBool(_keyDarkMode) ?? false;
  Future<void> setDarkMode(bool enabled) =>
      _prefs.setBool(_keyDarkMode, enabled);

  // ── Notifications ──
  bool getNotificationsEnabled() => _prefs.getBool(_keyNotifications) ?? true;
  Future<void> setNotificationsEnabled(bool enabled) =>
      _prefs.setBool(_keyNotifications, enabled);

  // ── Premium ──
  bool getIsPremium() => _prefs.getBool(_keyIsPremium) ?? false;
  Future<void> setIsPremium(bool premium) =>
      _prefs.setBool(_keyIsPremium, premium);

  /// The install a purchase or restore was made on; see SubscriptionService.
  String? getPremiumInstallId() => _prefs.getString(_keyPremiumInstallId);
  Future<void> setPremiumInstallId(String? id) => id == null
      ? _prefs.remove(_keyPremiumInstallId)
      : _prefs.setString(_keyPremiumInstallId, id);

  // ── Profile Image ──
  String? getProfileImagePath() => _prefs.getString(_keyProfileImagePath);
  Future<void> setProfileImagePath(String path) =>
      _prefs.setString(_keyProfileImagePath, path);

  Map<String, dynamic>? getLastWeightEntry() {
    final raw = _prefs.getString(_keyLastWeightEntry);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> setLastWeightEntry(Map<String, dynamic> entry) =>
      _prefs.setString(_keyLastWeightEntry, jsonEncode(entry));

  // ── Daily water goal: glasses ticked today ──
  static String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  /// Glasses ticked on [day]; 0 when the saved count is from another day.
  int getWaterGlasses(DateTime day) {
    if (_prefs.getString(_keyWaterGlassesDay) != _dayKey(day)) return 0;
    return _prefs.getInt(_keyWaterGlasses) ?? 0;
  }

  Future<void> setWaterGlasses(DateTime day, int glasses) async {
    await _prefs.setString(_keyWaterGlassesDay, _dayKey(day));
    await _prefs.setInt(_keyWaterGlasses, glasses);
  }

  // ── User Profile ──
  bool hasUserProfile() => _prefs.getString(_keyUserProfile) != null;

  UserProfile getUserProfile() {
    final raw = _prefs.getString(_keyUserProfile);
    if (raw == null) return const UserProfile();
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const UserProfile();
    }
  }

  Future<void> saveUserProfile(UserProfile profile) =>
      _prefs.setString(_keyUserProfile, jsonEncode(profile.toJson()));

  // ── BMI History ──
  List<BMIRecord> getBmiHistory() {
    final raw = _prefs.getString(_keyBmiHistory);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((item) => BMIRecord.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveBmiHistory(List<BMIRecord> records) => _prefs.setString(
    _keyBmiHistory,
    jsonEncode(records.map((e) => e.toJson()).toList()),
  );

  Future<void> addBmiRecord(BMIRecord record) async {
    final current = getBmiHistory();
    current.insert(0, record);
    await saveBmiHistory(current);
  }

  // ── Weight History ──
  List<WeightRecord> getWeightHistory() {
    final raw = _prefs.getString(_keyWeightHistory);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((item) => WeightRecord.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveWeightHistory(List<WeightRecord> records) =>
      _prefs.setString(
        _keyWeightHistory,
        jsonEncode(records.map((e) => e.toJson()).toList()),
      );

  Future<void> addWeightRecord(WeightRecord record) async {
    final current = getWeightHistory();
    current.add(record);
    await saveWeightHistory(current);
  }

  // ── Remote Config ──

  String? getRemoteButtonText() => _prefs.getString(_keyRemoteButtonText);
  Future<void> setRemoteButtonText(String text) =>
      _prefs.setString(_keyRemoteButtonText, text);
}
