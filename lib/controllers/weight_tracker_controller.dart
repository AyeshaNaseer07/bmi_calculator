import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';

import '../data/models/weight_record_model.dart';
import '../data/services/storage_service.dart';
import '../data/services/analytics_service.dart';

class WeightTrackerController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final RxDouble currentWeight = 0.0.obs;
  final RxDouble goalWeight = 0.0.obs;
  final RxString selectedTimeframe = 'week'.obs;
  final RxList<WeightRecord> weightHistory = <WeightRecord>[].obs;

  final RxDouble progressThisWeek = 0.0.obs;
  final RxDouble progressThisMonth = 0.0.obs;
  final RxDouble progressTotal = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void loadData() {
    final list = _storage.getWeightHistory();
    final profile = _storage.getUserProfile();

    if (list.isNotEmpty) {
      weightHistory.assignAll(list);
      currentWeight.value = list.last.weightKg;
      goalWeight.value = profile.goalWeightKg > 0 ? profile.goalWeightKg : 60.0;
      _recalculateProgress();
    } else {
      weightHistory.clear();
      currentWeight.value = 0.0;
      goalWeight.value = profile.goalWeightKg > 0 ? profile.goalWeightKg : 60.0;
      progressThisWeek.value = 0.0;
      progressThisMonth.value = 0.0;
      progressTotal.value = 0.0;
    }
  }

  void _recalculateProgress() {
    if (weightHistory.isEmpty) {
      progressThisWeek.value = 0.0;
      progressThisMonth.value = 0.0;
      progressTotal.value = 0.0;
      return;
    }

    final sorted = List<WeightRecord>.from(weightHistory)
      ..sort((a, b) => a.date.compareTo(b.date));

    final latest = sorted.last.weightKg;
    final first = sorted.first.weightKg;
    progressTotal.value = double.parse((latest - first).toStringAsFixed(1));

    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);

    final weekRecords = sorted
        .where((r) => r.date.isAfter(oneWeekAgo))
        .toList();
    if (weekRecords.length >= 2) {
      progressThisWeek.value = double.parse(
        (weekRecords.last.weightKg - weekRecords.first.weightKg)
            .toStringAsFixed(1),
      );
    } else {
      progressThisWeek.value = 0.0;
    }

    final monthRecords = sorted
        .where((r) => r.date.isAfter(oneMonthAgo))
        .toList();
    if (monthRecords.length >= 2) {
      progressThisMonth.value = double.parse(
        (monthRecords.last.weightKg - monthRecords.first.weightKg)
            .toStringAsFixed(1),
      );
    } else {
      progressThisMonth.value = 0.0;
    }
  }

  void setTimeframe(String timeframe) {
    selectedTimeframe.value = timeframe;
  }

  Future<void> addWeight(
    double weight,
    DateTime date, {
    String? note,
    double goalWeight = 0.0,
  }) async {
    final newRecord = WeightRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      weightKg: weight,
      date: date,
      note: note,
    );
    await _storage.addWeightRecord(newRecord);
    weightHistory.add(newRecord);
    AnalyticsService.log(AnalyticsService.weightLogged, {
      'note': note != null && note.isNotEmpty,
      'goal': goalWeight > 0,
    });
    currentWeight.value = weight;
    // Update goal weight if provided
    if (goalWeight > 0) {
      this.goalWeight.value = goalWeight;
      final profile = _storage.getUserProfile();
      _storage.saveUserProfile(profile.copyWith(goalWeightKg: goalWeight));
    } else if (this.goalWeight.value == 0.0) {
      this.goalWeight.value = 60.0;
    }
    _recalculateProgress();
  }

  // Chart window: past slots, the current one, then empty future slots.
  static const int _monthsBack = 4;
  static const int _monthsAhead = 2;
  static const int _yearsBack = 3;
  static const int _yearsAhead = 1;

  static List<String> get _monthNames => [
    'jan'.tr,
    'feb'.tr,
    'mar'.tr,
    'apr'.tr,
    'may'.tr,
    'jun'.tr,
    'jul'.tr,
    'aug'.tr,
    'sep'.tr,
    'oct'.tr,
    'nov'.tr,
    'dec'.tr,
  ];

  List<FlSpot> getSpots() {
    if (weightHistory.isEmpty) return [];

    final tf = selectedTimeframe.value.toLowerCase();
    final sorted = List<WeightRecord>.from(weightHistory)
      ..sort((a, b) => a.date.compareTo(b.date));
    final now = DateTime.now();

    if (tf == 'week') {
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final weekStart = DateTime(monday.year, monday.month, monday.day);
      final Map<int, double> dayMap = {};
      for (final r in sorted) {
        final dayIndex = r.date.difference(weekStart).inDays;
        if (dayIndex >= 0 && dayIndex <= 6) {
          dayMap[dayIndex] = r.weightKg;
        }
      }
      if (dayMap.isNotEmpty) {
        final spots =
            dayMap.entries
                .map((e) => FlSpot(e.key.toDouble(), e.value))
                .toList()
              ..sort((a, b) => a.x.compareTo(b.x));
        return spots;
      }
      final recent = sorted.length > 7
          ? sorted.sublist(sorted.length - 7)
          : sorted;
      return List.generate(
        recent.length,
        (i) => FlSpot(i.toDouble(), recent[i].weightKg),
      );
    } else if (tf == 'month') {
      final Map<int, double> monthMap = {};
      for (int i = _monthsBack; i >= -_monthsAhead; i--) {
        final slotIndex = _monthsBack - i;
        final startOfMonth = DateTime(now.year, now.month - i, 1);
        final endOfMonth = DateTime(now.year, now.month - i + 1, 1);
        final inMonth = sorted
            .where(
              (r) =>
                  !r.date.isBefore(startOfMonth) && r.date.isBefore(endOfMonth),
            )
            .toList();
        if (inMonth.isNotEmpty) {
          monthMap[slotIndex] = inMonth.last.weightKg;
        }
      }
      if (monthMap.isNotEmpty) {
        final spots =
            monthMap.entries
                .map((e) => FlSpot(e.key.toDouble(), e.value))
                .toList()
              ..sort((a, b) => a.x.compareTo(b.x));
        return spots;
      }
      final recent = sorted.length > _monthsBack + 1
          ? sorted.sublist(sorted.length - (_monthsBack + 1))
          : sorted;
      return List.generate(
        recent.length,
        (i) => FlSpot(i.toDouble(), recent[i].weightKg),
      );
    } else {
      final Map<int, double> yearMap = {};
      for (int i = _yearsBack; i >= -_yearsAhead; i--) {
        final slotIndex = _yearsBack - i;
        final targetYear = now.year - i;
        final inYear = sorted.where((r) => r.date.year == targetYear).toList();
        if (inYear.isNotEmpty) {
          yearMap[slotIndex] = inYear.last.weightKg;
        }
      }
      if (yearMap.isNotEmpty) {
        final spots =
            yearMap.entries
                .map((e) => FlSpot(e.key.toDouble(), e.value))
                .toList()
              ..sort((a, b) => a.x.compareTo(b.x));
        return spots;
      }
      final recent = sorted.length > 5
          ? sorted.sublist(sorted.length - 5)
          : sorted;
      return List.generate(
        recent.length,
        (i) => FlSpot(i.toDouble(), recent[i].weightKg),
      );
    }
  }

  /// The goal is a plan for one period: this week (Mon-Sun), the month the
  /// goal was entered in through the next month, or the year it was entered
  /// in through the next year. The goal is entered with a weight, so the
  /// latest record's date anchors the plan.
  List<FlSpot> getGoalSpots() {
    final goal = goalWeight.value;
    if (goal <= 0) return [];
    final labels = getXAxisLabels();
    if (labels.isEmpty) return [];
    final lastX = (labels.length - 1).toDouble();
    final tf = selectedTimeframe.value.toLowerCase();

    if (tf == 'week' || weightHistory.isEmpty) {
      return [FlSpot(0, goal), FlSpot(lastX, goal)];
    }

    final entered = weightHistory
        .map((r) => r.date)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final now = DateTime.now();

    final int slot;
    if (tf == 'month') {
      final monthsAgo =
          (now.year - entered.year) * 12 + now.month - entered.month;
      slot = _monthsBack - monthsAgo;
    } else {
      slot = _yearsBack - (now.year - entered.year);
    }

    final start = slot.toDouble();
    final end = (slot + 1).toDouble();
    if (end < 0 || start > lastX) return [];
    return [
      FlSpot(start.clamp(0, lastX), goal),
      FlSpot(end.clamp(0, lastX), goal),
    ];
  }

  List<String> getXAxisLabels() {
    final tf = selectedTimeframe.value.toLowerCase();
    final now = DateTime.now();

    if (tf == 'week') {
      // Always return all 7 days so the chart spans Mon–Sun (maxX = 6)
      return [
        'mon'.tr,
        'tue'.tr,
        'wed'.tr,
        'thu'.tr,
        'fri'.tr,
        'sat'.tr,
        'sun'.tr,
      ];
    } else if (tf == 'month') {
      // 4 months back, the current month and 2 ahead (e.g. Jul..Jan in Nov).
      final List<String> labels = [];
      for (int i = _monthsBack; i >= -_monthsAhead; i--) {
        final d = DateTime(now.year, now.month - i, 1);
        labels.add(_monthNames[d.month - 1]);
      }
      return labels;
    } else {
      // 3 years back, the current year and 1 ahead (e.g. 2023..2027 in 2026).
      final List<String> labels = [];
      for (int i = _yearsBack; i >= -_yearsAhead; i--) {
        labels.add((now.year - i).toString());
      }
      return labels;
    }
  }
}
