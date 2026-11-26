/// One dish in an AI-generated meal plan.
class AiMeal {
  final String name;
  final String blurb;
  final int kcal;
  final int protein;
  final int carbs;
  final int fat;
  final String tag;

  /// Each entry is `[item, amount]`, e.g. `['Rolled oats', '40g']`.
  final List<List<String>> ingredients;

  /// File name (without extension) of a bundled meal photo, or empty.
  final String photo;

  const AiMeal({
    required this.name,
    required this.blurb,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.tag,
    required this.ingredients,
    this.photo = '',
  });

  Map<String, dynamic> toJson() => {
    'n': name,
    'b': blurb,
    'k': kcal,
    'p': protein,
    'c': carbs,
    'f': fat,
    't': tag,
    'i': ingredients,
    'ph': photo,
  };

  factory AiMeal.fromJson(Map<String, dynamic> j) => AiMeal(
    name: j['n'] as String? ?? '',
    blurb: j['b'] as String? ?? '',
    kcal: (j['k'] as num?)?.toInt() ?? 0,
    protein: (j['p'] as num?)?.toInt() ?? 0,
    carbs: (j['c'] as num?)?.toInt() ?? 0,
    fat: (j['f'] as num?)?.toInt() ?? 0,
    tag: j['t'] as String? ?? '',
    ingredients: [
      for (final e in (j['i'] as List? ?? const []))
        if (e is List && e.length >= 2) [e[0].toString(), e[1].toString()],
    ],
    photo: j['ph'] as String? ?? '',
  );
}

class AiMealPlan {
  final String id;
  final String signature;
  final DateTime createdAt;
  final int totalWeeks;
  final Map<int, List<List<AiMeal>>> weeks;

  AiMealPlan({
    required this.id,
    required this.signature,
    required this.createdAt,
    required this.totalWeeks,
    Map<int, List<List<AiMeal>>>? weeks,
  }) : weeks = weeks ?? {};

  int get totalDays => totalWeeks * 7;

  bool hasWeek(int week) => weeks.containsKey(week);

  static int weekOfDay(int day) => (day - 1) ~/ 7 + 1;

  List<AiMeal>? mealsForDay(int day) {
    final w = weeks[weekOfDay(day)];
    if (w == null) return null;
    final i = (day - 1) % 7;
    return i < w.length ? w[i] : null;
  }

  /// Every dish name generated so far, used to avoid repeats.
  List<String> get usedNames => [
    for (final w in weeks.values)
      for (final d in w)
        for (final m in d) m.name,
  ];

  Map<String, dynamic> toJson() => {
    'id': id,
    'signature': signature,
    'createdAt': createdAt.toIso8601String(),
    'totalWeeks': totalWeeks,
    'weeks': {
      for (final e in weeks.entries)
        '${e.key}': [
          for (final d in e.value) [for (final m in d) m.toJson()],
        ],
    },
  };

  factory AiMealPlan.fromJson(Map<String, dynamic> j) {
    final weeks = <int, List<List<AiMeal>>>{};
    final raw = j['weeks'] as Map<String, dynamic>? ?? const {};
    for (final e in raw.entries) {
      final n = int.tryParse(e.key);
      if (n == null) continue;
      weeks[n] = [
        for (final d in (e.value as List))
          [
            for (final m in (d as List))
              AiMeal.fromJson(m as Map<String, dynamic>),
          ],
      ];
    }
    return AiMealPlan(
      id: j['id'] as String? ?? '',
      signature: j['signature'] as String? ?? '',
      createdAt:
          DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
      totalWeeks: (j['totalWeeks'] as num?)?.toInt() ?? 1,
      weeks: weeks,
    );
  }
}
