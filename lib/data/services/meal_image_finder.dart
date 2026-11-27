import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Finds a real food photo on a public website for a short English dish
/// query such as "lentil soup". Nothing is generated.
///
/// Sources, in order:
/// 1. TheMealDB (free, no key): good photos, but only for dishes it knows.
/// 2. Openverse (free, no key): Creative Commons photos (mostly Flickr),
///    limited to licences that allow commercial use.
class MealImageFinder {
  final http.Client _client;

  MealImageFinder({http.Client? client}) : _client = client ?? http.Client();

  static const Duration _timeout = Duration(seconds: 6);
  static const Map<String, String> _headers = {
    'User-Agent': 'MealPlanClient/1.0',
  };

  /// Results for this app session, so repeated dishes cost one lookup.
  final Map<String, Future<String>> _cache = {};

  /// Image URL for [query], or empty when nothing fitting was found.
  Future<String> find(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return Future.value('');
    return _cache.putIfAbsent(q, () => _lookup(q));
  }

  /// Looks up [queries] a few at a time (the free APIs throttle bursts),
  /// giving up on what's left after [budget]. Returns query → URL; a query
  /// with no photo is missing or empty.
  Future<Map<String, String>> findAll(
    Iterable<String> queries, {
    Duration budget = const Duration(seconds: 20),
    int parallel = 4,
  }) async {
    final found = <String, String>{};
    final pending = queries
        .map((q) => q.trim())
        .where((q) => q.isNotEmpty)
        .toSet()
        .toList();
    Future<void> worker() async {
      while (pending.isNotEmpty) {
        final q = pending.removeLast();
        found[q] = await find(q);
      }
    }

    try {
      await Future.wait([for (int i = 0; i < parallel; i++) worker()])
          .timeout(budget);
    } on TimeoutException {
      pending.clear(); // stop the workers picking up more
      debugPrint('[MealImage] lookup budget used; ${found.length} done');
    }
    return found;
  }

  Future<String> _lookup(String q) async {
    for (final source in [_mealDb, _openverse]) {
      try {
        final url = await source(q);
        if (url.isNotEmpty) return url;
      } catch (e) {
        debugPrint('[MealImage] "$q": $e');
      }
    }
    return '';
  }

  Future<String> _mealDb(String q) async {
    final uri = Uri.https('www.themealdb.com', '/api/json/v1/1/search.php', {
      's': q,
    });
    final meals = (await _getJson(uri))['meals'] as List?;
    return _best(q, [
      for (final m in meals ?? const [])
        if (m is Map) (m['strMeal'] as String?, m['strMealThumb'] as String?),
    ], requireAllWords: false);
  }

  Future<String> _openverse(String q) async {
    final uri = Uri.https('api.openverse.org', '/v1/images/', {
      'q': q,
      'category': 'photograph',
      'license_type': 'commercial',
      'mature': 'false',
      'page_size': '10',
    });
    final results = (await _getJson(uri))['results'] as List?;
    return _best(q, [
      for (final r in results ?? const [])
        if (r is Map) (r['title'] as String?, r['url'] as String?),
    ], requireAllWords: true);
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final res = await _client.get(uri, headers: _headers).timeout(_timeout);
    if (res.statusCode != 200) throw 'HTTP ${res.statusCode} from ${uri.host}';
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  /// First result whose title fits the query. Titles naming a meat or fish
  /// the query doesn't mention are skipped, so a vegetarian dish never gets
  /// a photo of, say, chorizo.
  static String _best(
    String q,
    List<(String?, String?)> results, {
    required bool requireAllWords,
  }) {
    final words = _words(q);
    for (final (title, url) in results) {
      if (title == null || url == null || !url.startsWith('https://')) {
        continue;
      }
      final t = _words(title);
      if (t.any((w) => _meat.contains(w) && !words.contains(w))) continue;
      if (requireAllWords && !words.every(t.contains)) continue;
      return url;
    }
    return '';
  }

  /// Lower-case words, with a trailing plural `s` dropped.
  static Set<String> _words(String s) => {
    for (final w in s.toLowerCase().split(RegExp(r'[^a-z]+')))
      if (w.length > 1)
        w.length > 3 && w.endsWith('s') ? w.substring(0, w.length - 1) : w,
  };

  static const Set<String> _meat = {
    'chicken',
    'beef',
    'pork',
    'lamb',
    'mutton',
    'goat',
    'veal',
    'duck',
    'turkey',
    'bacon',
    'ham',
    'sausage',
    'chorizo',
    'salami',
    'pepperoni',
    'steak',
    'mince',
    'meatball',
    'meat',
    'fish',
    'salmon',
    'tuna',
    'cod',
    'prawn',
    'shrimp',
    'crab',
    'lobster',
    'squid',
    'octopu',
    'mussel',
    'clam',
    'oyster',
    'anchovy',
    'sardine',
    'mackerel',
    'kebab',
    'gyro',
  };
}
