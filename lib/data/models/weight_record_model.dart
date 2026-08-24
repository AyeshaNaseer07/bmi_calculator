class WeightRecord {
  final String id;
  final double weightKg;
  final DateTime date;
  final String? note;

  const WeightRecord({
    required this.id,
    required this.weightKg,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weightKg': weightKg,
      'date': date.toIso8601String(),
      if (note != null) 'note': note,
    };
  }

  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    return WeightRecord(
      id: json['id'] as String,
      weightKg: (json['weightKg'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
    );
  }
}
