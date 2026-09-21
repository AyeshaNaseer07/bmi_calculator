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
  static const String _keyIsPremium = 'is_premium';
  static const String _keyUserProfile = 'user_profile';
  static const String _keyBmiHistory = 'bmi_history';
  static const String _keyWeightHistory = 'weight_history';
  static const String _keyRemoteCrossDelay = 'rc_cross_delay_seconds';
  static const String _keyRemoteMonthlyProductId = 'rc_monthly_product_id';
  static const String _keyRemoteYearlyProductId = 'rc_yearly_product_id';
  static const String _keyRemoteButtonText = 'rc_button_text';

  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // ── Onboarding ──
  bool getOnboardingSeen() => _prefs.getBool(_keyOnboardingSeen) ?? false;
  Future<void> setOnboardingSeen(bool seen) => _prefs.setBool(_keyOnboardingSeen, seen);

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
  Future<void> setUnitSystem(UnitSystem unit) => _prefs.setString(_keyUnitSystem, unit.name);

  // ── Notifications ──
  bool getNotificationsEnabled() => _prefs.getBool(_keyNotifications) ?? true;
  Future<void> setNotificationsEnabled(bool enabled) => _prefs.setBool(_keyNotifications, enabled);

  // ── Premium ──
  bool getIsPremium() => _prefs.getBool(_keyIsPremium) ?? false;
  Future<void> setIsPremium(bool premium) => _prefs.setBool(_keyIsPremium, premium);

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
      return list.map((item) => BMIRecord.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveBmiHistory(List<BMIRecord> records) =>
      _prefs.setString(_keyBmiHistory, jsonEncode(records.map((e) => e.toJson()).toList()));

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
      return list.map((item) => WeightRecord.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveWeightHistory(List<WeightRecord> records) =>
      _prefs.setString(_keyWeightHistory, jsonEncode(records.map((e) => e.toJson()).toList()));

  Future<void> addWeightRecord(WeightRecord record) async {
    final current = getWeightHistory();
    current.add(record);
    await saveWeightHistory(current);
  }

  // ── Remote Config ──
  int? getRemoteCrossDelay() => _prefs.getInt(_keyRemoteCrossDelay);
  Future<void> setRemoteCrossDelay(int seconds) => _prefs.setInt(_keyRemoteCrossDelay, seconds);

  String? getRemoteMonthlyProductId() => _prefs.getString(_keyRemoteMonthlyProductId);
  Future<void> setRemoteMonthlyProductId(String id) => _prefs.setString(_keyRemoteMonthlyProductId, id);

  String? getRemoteYearlyProductId() => _prefs.getString(_keyRemoteYearlyProductId);
  Future<void> setRemoteYearlyProductId(String id) => _prefs.setString(_keyRemoteYearlyProductId, id);

  String? getRemoteButtonText() => _prefs.getString(_keyRemoteButtonText);
  Future<void> setRemoteButtonText(String text) => _prefs.setString(_keyRemoteButtonText, text);

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
