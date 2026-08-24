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
    weightHistory.assignAll(list);
    
    if (list.isNotEmpty) {
      currentWeight.value = list.last.weightKg;
      goalWeight.value = profile.goalWeightKg > 0 ? profile.goalWeightKg : 60.0;
      _recalculateProgress();
    } else {
      currentWeight.value = 0.0;
      goalWeight.value = 0.0;
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

    final weekRecords = sorted.where((r) => r.date.isAfter(oneWeekAgo)).toList();
    if (weekRecords.length >= 2) {
      progressThisWeek.value = double.parse((weekRecords.last.weightKg - weekRecords.first.weightKg).toStringAsFixed(1));
    } else {
      progressThisWeek.value = 0.0;
    }

    final monthRecords = sorted.where((r) => r.date.isAfter(oneMonthAgo)).toList();
    if (monthRecords.length >= 2) {
      progressThisMonth.value = double.parse((monthRecords.last.weightKg - monthRecords.first.weightKg).toStringAsFixed(1));
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
    if (weightHistory.isEmpty) {
      return const [];
    }

    final sorted = List<WeightRecord>.from(weightHistory)
      ..sort((a, b) => a.date.compareTo(b.date));

    if (selectedTimeframe.value == 'week') {
      final now = DateTime.now();
      final oneWeekAgo = now.subtract(const Duration(days: 7));
      final weekRecords = sorted.where((r) => r.date.isAfter(oneWeekAgo)).toList();
      final recordsToUse = weekRecords.isNotEmpty ? weekRecords : sorted;
      
      final spots = <FlSpot>[];
      for (int i = 0; i < recordsToUse.length; i++) {
        spots.add(FlSpot(i.toDouble(), recordsToUse[i].weightKg));
      }
      return spots;
    } else if (selectedTimeframe.value == 'Month' || selectedTimeframe.value == 'month') {
      final now = DateTime.now();
      final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
      final monthRecords = sorted.where((r) => r.date.isAfter(oneMonthAgo)).toList();
      final recordsToUse = monthRecords.isNotEmpty ? monthRecords : sorted;

      final spots = <FlSpot>[];
      for (int i = 0; i < recordsToUse.length; i++) {
        spots.add(FlSpot(i.toDouble(), recordsToUse[i].weightKg));
      }
      return spots;
    } else {
      final spots = <FlSpot>[];
      for (int i = 0; i < sorted.length; i++) {
        spots.add(FlSpot(i.toDouble(), sorted[i].weightKg));
      }
      return spots;
    }
  }

  List<String> getXAxisLabels() {
    if (selectedTimeframe.value == 'week') {
      return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    } else if (selectedTimeframe.value == 'Month' || selectedTimeframe.value == 'month') {
      return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
    } else {
      return ['2021', '2022', '2023', '2024', '2025', '2026', '2027'];
    }
  }
}
