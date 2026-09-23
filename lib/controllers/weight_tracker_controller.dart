import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';

import '../data/models/weight_record_model.dart';
import '../data/services/storage_service.dart';

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
      // No real data — leave history empty to show empty state
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

  void updateGoalWeight(double weight) {
    goalWeight.value = weight;
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

  List<FlSpot> getSpots() {
    if (weightHistory.isEmpty) return [];

    final tf = selectedTimeframe.value.toLowerCase();
    final sorted = List<WeightRecord>.from(weightHistory)
      ..sort((a, b) => a.date.compareTo(b.date));
    final now = DateTime.now();

    if (tf == 'week') {
      // Map records to their weekday position (Mon=0 ... Sun=6)
      // Use current Mon–Sun window
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final weekStart = DateTime(monday.year, monday.month, monday.day);
      // Build weekday -> latest weight map
      final Map<int, double> dayMap = {};
      for (final r in sorted) {
        final dayIndex = r.date.difference(weekStart).inDays;
        if (dayIndex >= 0 && dayIndex <= 6) {
          dayMap[dayIndex] = r.weightKg; // last record wins
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
      // Fallback: records outside current week — place at sequential positions
      final recent = sorted.length > 7
          ? sorted.sublist(sorted.length - 7)
          : sorted;
      return List.generate(
        recent.length,
        (i) => FlSpot(i.toDouble(), recent[i].weightKg),
      );
    } else if (tf == 'month') {
      // Records in the last 30 days, grouped by day
      final cutoff = now.subtract(const Duration(days: 30));
      final recent = sorted.where((r) => r.date.isAfter(cutoff)).toList();
      if (recent.isEmpty) return [];
      // Up to 7 evenly spaced points
      final step = (recent.length / 7).ceil();
      final sampled = <WeightRecord>[];
      for (int i = 0; i < recent.length; i += step) {
        sampled.add(recent[i]);
      }
      if (sampled.last != recent.last) sampled.add(recent.last);
      return List.generate(
        sampled.length,
        (i) => FlSpot(i.toDouble(), sampled[i].weightKg),
      );
    } else {
      // Year: records in the last 12 months, up to 7 points
      final cutoff = DateTime(now.year - 1, now.month, now.day);
      final recent = sorted.where((r) => r.date.isAfter(cutoff)).toList();
      if (recent.isEmpty) return [];
      final step = (recent.length / 7).ceil();
      final sampled = <WeightRecord>[];
      for (int i = 0; i < recent.length; i += step) {
        sampled.add(recent[i]);
      }
      if (sampled.last != recent.last) sampled.add(recent.last);
      return List.generate(
        sampled.length,
        (i) => FlSpot(i.toDouble(), sampled[i].weightKg),
      );
    }
  }

  /// Returns a flat horizontal dashed line at the goal weight value.
  /// Spans the same X range as getSpots().
  List<FlSpot> getGoalSpots() {
    final goal = goalWeight.value;
    if (goal <= 0) return [];
    final spots = getSpots();
    if (spots.isEmpty) return [];
    final maxX = spots.last.x;
    return [FlSpot(0, goal), FlSpot(maxX, goal)];
  }

  List<String> getXAxisLabels() {
    final tf = selectedTimeframe.value.toLowerCase();
    final spots = getSpots();
    final count = spots.length;

    if (tf == 'week') {
      // Always return all 7 days so the chart spans Mon–Sun (maxX = 6)
      return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    } else if (tf == 'month') {
      if (count == 0) return [];
      // Generate relative day labels for each sampled point
      final sorted = List<WeightRecord>.from(weightHistory)
        ..sort((a, b) => a.date.compareTo(b.date));
      final now = DateTime.now();
      final cutoff = now.subtract(const Duration(days: 30));
      final recent = sorted.where((r) => r.date.isAfter(cutoff)).toList();
      if (recent.isEmpty) return [];
      final step = (recent.length / 7).ceil();
      final sampled = <WeightRecord>[];
      for (int i = 0; i < recent.length; i += step) {
        sampled.add(recent[i]);
      }
      if (sampled.last != recent.last) sampled.add(recent.last);
      return sampled.map((r) => '${r.date.day}/${r.date.month}').toList();
    } else {
      if (count == 0) return [];
      final sorted = List<WeightRecord>.from(weightHistory)
        ..sort((a, b) => a.date.compareTo(b.date));
      final now = DateTime.now();
      final cutoff = DateTime(now.year - 1, now.month, now.day);
      final recent = sorted.where((r) => r.date.isAfter(cutoff)).toList();
      if (recent.isEmpty) return [];
      final step = (recent.length / 7).ceil();
      final sampled = <WeightRecord>[];
      for (int i = 0; i < recent.length; i += step) {
        sampled.add(recent[i]);
      }
      if (sampled.last != recent.last) sampled.add(recent.last);
      return sampled
          .map((r) => '${r.date.month}/${r.date.year.toString().substring(2)}')
          .toList();
    }
  }
}
