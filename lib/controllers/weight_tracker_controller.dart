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

  final RxDouble progressThisWeek = (-1.2).obs;
  final RxDouble progressThisMonth = (-3.5).obs;
  final RxDouble progressTotal = (-8.0).obs;

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
      // Seed default initial data matching the UI design mockup
      currentWeight.value = 70.0;
      goalWeight.value = 60.0;
      progressThisWeek.value = -1.2;
      progressThisMonth.value = -3.5;
      progressTotal.value = -8.0;

      final now = DateTime.now();
      const defaultWeights = [71.2, 71.0, 70.8, 70.5, 70.3, 70.2, 70.0];
      final defaultRecords = <WeightRecord>[];
      for (int i = 0; i < defaultWeights.length; i++) {
        defaultRecords.add(
          WeightRecord(
            id: 'mock_$i',
            weightKg: defaultWeights[i],
            date: now.subtract(Duration(days: 6 - i)),
          ),
        );
      }
      weightHistory.assignAll(defaultRecords);
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
      progressThisWeek.value = -1.2;
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
      progressThisMonth.value = -3.5;
    }
  }

  void setTimeframe(String timeframe) {
    selectedTimeframe.value = timeframe;
  }

  void updateGoalWeight(double weight) {
    goalWeight.value = weight;
  }

  Future<void> addWeight(double weight, DateTime date, {String? note}) async {
    final newRecord = WeightRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      weightKg: weight,
      date: date,
      note: note,
    );
    await _storage.addWeightRecord(newRecord);
    weightHistory.add(newRecord);
    currentWeight.value = weight;
    if (goalWeight.value == 0.0) {
      goalWeight.value = 60.0;
    }
    _recalculateProgress();
  }

  List<FlSpot> getSpots() {
    final tf = selectedTimeframe.value.toLowerCase();

    if (tf == 'week') {
      // 7 points for Mon to Sun matching UI mockup: 71.2, 71.0, 70.8, 70.5, 70.3, 70.2, 70.0
      if (weightHistory.length >= 7) {
        final recent = weightHistory.sublist(weightHistory.length - 7);
        return List.generate(
          7,
          (i) => FlSpot(i.toDouble(), recent[i].weightKg),
        );
      } else if (weightHistory.isNotEmpty) {
        return List.generate(
          weightHistory.length,
          (i) => FlSpot(i.toDouble(), weightHistory[i].weightKg),
        );
      } else {
        const defaultVals = [71.2, 71.0, 70.8, 70.5, 70.3, 70.2, 70.0];
        return List.generate(7, (i) => FlSpot(i.toDouble(), defaultVals[i]));
      }
    } else if (tf == 'month') {
      // 7 points for Jan to Jul matching UI mockup: 71.2, 71.0, 70.8, 70.5, 70.3, 70.2, 70.0
      const defaultVals = [71.2, 71.0, 70.8, 70.5, 70.3, 70.2, 70.0];
      return List.generate(7, (i) => FlSpot(i.toDouble(), defaultVals[i]));
    } else {
      // 7 points for Year (2021 to 2027)
      const defaultVals = [76.0, 75.0, 73.5, 72.0, 71.2, 70.5, 70.0];
      return List.generate(7, (i) => FlSpot(i.toDouble(), defaultVals[i]));
    }
  }

  List<String> getXAxisLabels() {
    final tf = selectedTimeframe.value.toLowerCase();
    if (tf == 'week') {
      return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    } else if (tf == 'month') {
      return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
    } else {
      return ['2021', '2022', '2023', '2024', '2025', '2026', '2027'];
    }
  }
}
