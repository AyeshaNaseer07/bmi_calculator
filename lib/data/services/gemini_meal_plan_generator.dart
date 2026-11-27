import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/ai_meal_plan_model.dart';
import 'meal_plan_generator.dart';

class GeminiMealPlanGenerator implements MealPlanGenerator {
  final String apiKey;
  final List<String> models;
  final http.Client _client;

  GeminiMealPlanGenerator({
    required this.apiKey,
    required this.models,
    http.Client? client,
  }) : _client = client ?? http.Client();

  // Gemini 3 models think before answering; a full week can take a while.
  static const Duration _timeout = Duration(seconds: 120);

  /// Waits between attempts on the same model (3 attempts per model).
  static const List<Duration> _backoff = [
    Duration(seconds: 3),
    Duration(seconds: 8),
  ];

  @override
  Future<List<List<AiMeal>>> generateWeek(MealPlanRequest request) async {
    if (apiKey.isEmpty || models.isEmpty) {
      throw const MealPlanException('Gemini not configured', retryable: false);
    }
    MealPlanException? last;
    for (final model in models) {
      if (model != models.first) {
        debugPrint('[Gemini] trying fallback model "$model"');
      }
      for (int attempt = 1; attempt <= _backoff.length + 1; attempt++) {
        try {
          return await _generateOnce(request, model);
        } on MealPlanException catch (e) {
          last = e;
          debugPrint('[Gemini] $model week ${request.week} #$attempt: $e');
          // Retired or misspelled model: go straight to the next one.
          if (e.statusCode == 404) break;
          // Bad key or bad request: another model won't fix it.
          if (!e.retryable) rethrow;
        } on TimeoutException {
          last = MealPlanException('$model timed out');
          debugPrint('[Gemini] $model week ${request.week} #$attempt: timeout');
        } catch (e) {
          // No connection: retry, but another model won't help.
          last = MealPlanException('Network error: $e');
          debugPrint('[Gemini] week ${request.week} #$attempt: $e');
          if (attempt > _backoff.length) throw last;
        }
        if (attempt <= _backoff.length) {
          await Future.delayed(_backoff[attempt - 1]);
        }
      }
    }
    throw last ?? const MealPlanException('Unknown error');
  }

  Future<List<List<AiMeal>>> _generateOnce(
    MealPlanRequest r,
    String model,
  ) async {
    final uri = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models/$model:generateContent',
    );
    final body = jsonEncode({
      'systemInstruction': {
        'parts': [
          {'text': _systemPrompt},
        ],
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': _userPrompt(r)},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.9,
        'responseMimeType': 'application/json',
        'responseSchema': _schema(r.photoKeys, r.slots),
      },
    });

    final res = await _client
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            // Header, not query string, so the key stays out of URL logs.
            'x-goog-api-key': apiKey,
          },
          body: body,
        )
        .timeout(_timeout);

    if (res.statusCode != 200) {
      final retryable = res.statusCode == 429 || res.statusCode >= 500;
      throw MealPlanException(
        'HTTP ${res.statusCode}: ${_errorMessage(res.body)}',
        retryable: retryable,
        statusCode: res.statusCode,
      );
    }

    final decoded = jsonDecode(utf8.decode(res.bodyBytes));
    final block = decoded['promptFeedback']?['blockReason'];
    if (block != null) {
      throw MealPlanException('Blocked: $block');
    }
    final candidates = decoded['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw const MealPlanException('No candidates returned');
    }
    final cand = candidates.first as Map<String, dynamic>;
    final finish = cand['finishReason'] as String?;
    if (finish != null && finish != 'STOP') {
      throw MealPlanException('Finished with $finish');
    }
    final parts = (cand['content']?['parts'] as List?) ?? const [];
    final text = parts
        .whereType<Map>()
        .where((p) => p['thought'] != true)
        .map((p) => p['text'] ?? '')
        .join();
    if (text.trim().isEmpty) {
      throw const MealPlanException('Empty response');
    }
    return _parseWeek(text, r.photoKeys.toSet(), r.slots);
  }

  static String _errorMessage(String body) {
    try {
      return (jsonDecode(body)['error']?['message'] as String?) ?? body;
    } catch (_) {
      return body.length > 200 ? body.substring(0, 200) : body;
    }
  }

  // ── Parsing + checks ──

  static List<List<AiMeal>> _parseWeek(
    String text,
    Set<String> photoKeys,
    List<String> slots,
  ) {
    final Map<String, dynamic> j;
    try {
      j = jsonDecode(text) as Map<String, dynamic>;
    } catch (e) {
      throw MealPlanException('Invalid JSON: $e');
    }
    final days = j['days'] as List?;
    if (days == null || days.length < 7) {
      throw MealPlanException('Expected 7 days, got ${days?.length ?? 0}');
    }
    return [
      for (final d in days.take(7))
        [for (final s in slots) _parseMeal((d as Map)[s], photoKeys)],
    ];
  }

  static AiMeal _parseMeal(dynamic raw, Set<String> photoKeys) {
    if (raw is! Map) throw const MealPlanException('Missing meal');
    String str(String k) => (raw[k] ?? '').toString().trim();
    int n(String k) => (raw[k] is num) ? (raw[k] as num).round() : 0;

    final ingredients = <List<String>>[
      for (final i in (raw['ingredients'] as List? ?? const []))
        if (i is Map &&
            (i['item'] ?? '').toString().trim().isNotEmpty &&
            (i['amount'] ?? '').toString().trim().isNotEmpty)
          [_clean(i['item'].toString()), _clean(i['amount'].toString())],
    ];
    final meal = AiMeal(
      name: _clean(str('name')),
      blurb: _clean(str('description')),
      kcal: n('kcal'),
      protein: n('protein_g'),
      carbs: n('carbs_g'),
      fat: n('fat_g'),
      tag: _clean(str('tag')),
      ingredients: ingredients,
      photo: photoKeys.contains(str('photo')) ? str('photo') : '',
    );
    if (meal.name.isEmpty ||
        meal.kcal < 80 ||
        meal.kcal > 2500 ||
        meal.protein < 0 ||
        meal.carbs < 0 ||
        meal.fat < 0 ||
        meal.protein + meal.carbs + meal.fat == 0 ||
        meal.ingredients.isEmpty) {
      throw MealPlanException('Invalid meal: ${meal.name}');
    }
    return meal;
  }

  /// `|` and `;` separate ingredient fields in the app's meal format.
  static String _clean(String s) =>
      s.replaceAll(RegExp(r'[|;]'), ',').replaceAll(RegExp(r'\s+'), ' ').trim();

  // ── Prompt ──

  static const String _systemPrompt =
      'You are a registered dietitian writing practical home meal plans for a '
      'BMI and nutrition app. Meals must be safe, realistic, made from '
      'everyday supermarket ingredients, and match the user\'s calorie '
      'target. Never include an ingredient the user is allergic to, or any '
      'food that commonly contains it. Respect diet type and dislikes '
      'strictly. Adjust for medical conditions (for example low glycaemic '
      'index for diabetes, low sodium for high blood pressure or heart '
      'disease, gluten-free for celiac). Nutrition numbers must be '
      'realistic for the listed ingredient amounts.';

  static String _userPrompt(MealPlanRequest r) {
    String list(List<String> v, String none) =>
        v.isEmpty ? none : v.map(_label).join(', ');
    final phase = _phase(r.week, r.totalWeeks);
    final minor = r.age < 18;
    final notes = r.notes.trim();
    final avoid = r.avoidNames.length > 120
        ? r.avoidNames.sublist(r.avoidNames.length - 120)
        : r.avoidNames;

    return '''
Create week ${r.week} of a ${r.totalWeeks}-week meal plan: 7 days, each with exactly ${r.slots.length} meals: ${r.slots.map(_slotName).join(', ')}.

Phase for this week: $phase

User profile:
- Age: ${r.age}${minor ? ' (minor: no calorie restriction, support healthy growth)' : ''}
- Gender: ${r.gender}
- Height: ${r.heightCm.toStringAsFixed(0)} cm, weight: ${r.weightKg.toStringAsFixed(1)} kg
- BMI category: ${r.bmiCategory}
- Health goal: ${_label(r.healthGoal)}
- Daily exercise / activity: ${_activity(r.activity)}. Scale portions, protein and carbohydrates to this activity.
- Medical conditions: ${list(r.conditions, 'none')}
- Food allergies (NEVER use): ${list(r.allergies, 'none')}
- Diet type: ${_label(r.dietType)}
- Preferred cuisine: ${_label(r.cuisine)}
- Foods to avoid / dislikes: ${list(r.dislikes, 'none')}
- Cooking preference: ${_label(r.cooking)}
- Budget: ${_label(r.budget)}
- Sleep: ${_label(r.sleep)}, water intake: ${_label(r.water)}
- Meal timing: ${_label(r.mealTiming)}
- Meals per day: ${r.slots.length}
${notes.isEmpty ? '' : '- User notes: ${notes.length > 300 ? notes.substring(0, 300) : notes}\n'}
Calories: each day must total ${r.targetKcal} kcal (within 5%). Split roughly ${_split(r.slots)}.
${r.slots.any(MealSlots.isSnack) ? 'Snacks are small, quick and need little or no cooking.\n' : ''}

Rules:
- Write every name, description, tag and ingredient in ${r.language}.
- "name": a short dish name (max 4 words). "description": max 6 words.
- "tag": a 1-3 word highlight such as "High Protein" or "High Fibre".
- "amount": always start with a number, e.g. "150g", "1/2 cup", "2 slices".
- 3 to 7 ingredients per meal.
- "photo": the closest matching photo name from the allowed list, or "none".
- Do not repeat a dish within this week. ${avoid.isEmpty ? '' : 'Avoid these dishes used in earlier weeks: ${avoid.join(', ')}.'}
''';
  }

  static String _slotName(String slot) => slot.replaceAll('_', ' ');

  /// Rough share of the day's calories for each meal.
  static String _split(List<String> slots) {
    const shares = {
      2: {'breakfast': '40%', 'lunch': '40%', 'dinner': '60%'},
      3: {'breakfast': '25-30%', 'lunch': '35%', 'dinner': '35-40%'},
      4: {
        'breakfast': '25%',
        'lunch': '30-35%',
        'snack': '10%',
        'dinner': '30-35%',
      },
      5: {
        'breakfast': '20-25%',
        'morning_snack': '10%',
        'lunch': '30%',
        'afternoon_snack': '10%',
        'dinner': '25-30%',
      },
    };
    final s = shares[slots.length] ?? shares[3]!;
    return slots.map((k) => '${_slotName(k)} ${s[k] ?? ''}'.trim()).join(', ');
  }

  /// Activity level with how often the user exercises.
  static String _activity(String key) => switch (key) {
    'sedentary' => 'sedentary (little or no exercise)',
    'lightlyActive' => 'lightly active (exercise 1-3 days a week)',
    'moderatelyActive' => 'moderately active (exercise 3-5 days a week)',
    'veryActive' => 'very active (exercise 6-7 days a week)',
    'extraActive' => 'extra active (hard daily exercise or a physical job)',
    _ => _label(key),
  };

  static String _phase(int week, int total) {
    final p = week / total;
    if (week == 1 || p <= 0.34) {
      return 'Foundation - simple, familiar meals that are easy to start with.';
    }
    if (p <= 0.67) {
      return 'Progress - more variety and new flavours, keep protein high.';
    }
    return 'Sustain - flexible meals the user can keep cooking after the plan.';
  }

  /// Turns setup keys like `high_bp` or `lightlyActive` into plain words.
  static String _label(String key) {
    const labels = {
      'high_bp': 'high blood pressure',
      'heart': 'heart disease',
      'kidney': 'kidney disease',
      'liver': 'liver disease',
      'celiac': 'celiac disease',
      'gerd': 'acid reflux (GERD)',
      'pcos': 'PCOS',
      'tree_nuts': 'tree nuts',
      'non_vegetarian': 'non-vegetarian (eats meat and fish)',
      'other': 'any',
      'quick': 'quick meals under 20 minutes',
      'home_cooked': 'home-cooked meals',
      'no_preference': 'no preference',
      'lt5': 'under 5 hours',
      '5_6': '5-6 hours',
      '6_7': '6-7 hours',
      '7_8': '7-8 hours',
      '8_9': '8-9 hours',
      'gt9': 'over 9 hours',
      'lt1': 'under 1 litre',
      '1_1_5': '1-1.5 litres',
      '1_5_2': '1.5-2 litres',
      'gt2': 'over 2 litres',
      'early': 'early meals',
      'regular': 'regular schedule',
      'late': 'late meals',
      'low': 'low',
      'medium': 'medium',
      'high': 'high',
      'none': 'none',
    };
    final k = key.trim();
    if (k.isEmpty) return 'not specified';
    final known = labels[k];
    if (known != null) return known;
    // camelCase / snake_case → words.
    return k
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .replaceAll('_', ' ')
        .toLowerCase();
  }

  // ── Response schema ──

  static Map<String, dynamic> _schema(
    List<String> photoKeys,
    List<String> slots,
  ) {
    const str = {'type': 'STRING'};
    const integer = {'type': 'INTEGER'};
    final meal = {
      'type': 'OBJECT',
      'properties': {
        'name': str,
        'description': str,
        'kcal': integer,
        'protein_g': integer,
        'carbs_g': integer,
        'fat_g': integer,
        'tag': str,
        'photo': {
          'type': 'STRING',
          'enum': [...photoKeys, 'none'],
        },
        'ingredients': {
          'type': 'ARRAY',
          'items': {
            'type': 'OBJECT',
            'properties': {'item': str, 'amount': str},
            'required': ['item', 'amount'],
            'propertyOrdering': ['item', 'amount'],
          },
        },
      },
      'required': [
        'name',
        'description',
        'kcal',
        'protein_g',
        'carbs_g',
        'fat_g',
        'tag',
        'photo',
        'ingredients',
      ],
      'propertyOrdering': [
        'name',
        'description',
        'tag',
        'ingredients',
        'kcal',
        'protein_g',
        'carbs_g',
        'fat_g',
        'photo',
      ],
    };
    return {
      'type': 'OBJECT',
      'properties': {
        'days': {
          'type': 'ARRAY',
          'items': {
            'type': 'OBJECT',
            'properties': {'day': integer, for (final s in slots) s: meal},
            'required': ['day', ...slots],
            'propertyOrdering': ['day', ...slots],
          },
        },
      },
      'required': ['days'],
    };
  }
}
