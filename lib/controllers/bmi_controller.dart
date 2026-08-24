import 'package:get/get.dart';
import '../data/models/bmi_record_model.dart';
import '../data/models/user_profile_model.dart';
import '../data/services/bmi_service.dart';
import '../data/services/storage_service.dart';

class BMIController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final Rx<Gender> selectedGender = Gender.male.obs;
  final RxInt age = 25.obs;
  final RxDouble heightCm = 175.0.obs;
  final RxDouble weightKg = 70.0.obs;

  final RxBool isCm = true.obs;
  final RxBool isKg = true.obs;
  final RxBool isAgePickerVisible = false.obs;
  final RxBool isCalculating = false.obs;

  final RxList<BMIRecord> bmiHistory = <BMIRecord>[].obs;
  final Rxn<BMIRecord> latestRecord = Rxn<BMIRecord>();

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  void loadHistory() {
    final list = _storage.getBmiHistory();
    bmiHistory.assignAll(list);
    if (list.isNotEmpty) {
      latestRecord.value = list.first;
    }
  }

  double get calculatedBMI {
    return BMIService.calculateBMI(
      weightKg: weightKg.value,
      heightCm: heightCm.value,
    );
  }

  BMICategory get calculatedCategory {
    return BMIService.getCategory(calculatedBMI);
  }

  void setGender(Gender gender) {
    selectedGender.value = gender;
  }

  void setAge(int newAge) {
    age.value = newAge.clamp(1, 120);
  }

  void incrementAge() {
    if (age.value < 120) age.value++;
  }

  void decrementAge() {
    if (age.value > 1) age.value--;
  }

  void toggleAgePicker() {
    isAgePickerVisible.value = !isAgePickerVisible.value;
  }

  void setHeight(double cm) {
    heightCm.value = double.parse(cm.toStringAsFixed(1));
  }

  void setWeight(double kg) {
    weightKg.value = double.parse(kg.toStringAsFixed(1));
  }

  void toggleHeightUnit(bool useCm) {
    isCm.value = useCm;
  }

  void toggleWeightUnit(bool useKg) {
    isKg.value = useKg;
  }

  void resetInputs() {
    selectedGender.value = Gender.male;
    age.value = 25;
    heightCm.value = 175.0;
    weightKg.value = 70.0;
    isCm.value = true;
    isKg.value = true;
    isAgePickerVisible.value = false;
  }

  Future<BMIRecord> calculateAndSave() async {
    final bmi = calculatedBMI;
    final category = calculatedCategory;
    final record = BMIRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bmiValue: bmi,
      weightKg: weightKg.value,
      heightCm: heightCm.value,
      age: age.value,
      gender: selectedGender.value.displayName,
      category: category,
      date: DateTime.now(),
    );

    await _storage.addBmiRecord(record);
    bmiHistory.insert(0, record);
    latestRecord.value = record;
    return record;
  }

  void deleteRecord(String id) async {
    bmiHistory.removeWhere((item) => item.id == id);
    await _storage.saveBmiHistory(bmiHistory);
    if (latestRecord.value?.id == id) {
      latestRecord.value = bmiHistory.isNotEmpty ? bmiHistory.first : null;
    }
  }
}
