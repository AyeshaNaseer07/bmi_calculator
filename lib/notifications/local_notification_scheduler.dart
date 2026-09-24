import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:get/get.dart';

import '../data/models/remote_model.dart';
import '../data/services/remote_config_service.dart';

/// Schedules repeating local notifications based on Remote Config frequency.
/// Each notification shows a different random message from the pool.
class LocalNotificationScheduler {
  LocalNotificationScheduler._();
  static final LocalNotificationScheduler instance =
      LocalNotificationScheduler._();

  static const String _tag = 'LocalNotifScheduler';

  /// Base notification ID — individual notifications use _baseId + index.
  static const int _baseId = 9000;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Pool of engaging notification content tailored for BMI & health tracking.
  static final List<Map<String, String>> _messages = [
    {
      'title': '⚖️ Time to log your weight!',
      'body': 'Step on the scale and record your weight to keep your progress chart accurate.',
    },
    {
      'title': '🎯 Check your BMI score today',
      'body': 'Stay informed about your body mass index and see how close you are to your goal.',
    },
    {
      'title': '💧 Stay healthy & hydrated',
      'body': 'Hydration fuels your metabolism. Drink a glass of water and check your BMI status.',
    },
    {
      'title': '🔥 Consistency builds results!',
      'body': 'Regular weigh-ins help you stay accountable and achieve long-term wellness.',
    },
    {
      'title': '🍏 Daily health insight is ready',
      'body': 'Discover wellness and nutrition tips tailored to support your health journey.',
    },
    {
      'title': '📈 Track your progress & trends',
      'body': 'View your history and charts to see how your body metrics are improving.',
    },
    {
      'title': '🏃 Time for a quick movement break!',
      'body': 'A short walk or stretch boosts your energy and supports a healthy BMI.',
    },
    {
      'title': '💪 You are closer than you think!',
      'body': 'Every healthy choice counts. Log your stats and keep your momentum going.',
    },
    {
      'title': '🥗 Fuel your body right',
      'body': 'Nourish yourself with balanced meals to stay in your ideal health category.',
    },
    {
      'title': '☀️ Start your day with a check-in',
      'body': 'A quick 5-second log this morning keeps your health journey on track.',
    },
    {
      'title': '🎯 Reach your ideal weight zone',
      'body': 'Find out your recommended weight target and celebrate every milestone.',
    },
    {
      'title': '🌙 Evening wellness reflection',
      'body': 'Review your progress today and get ready for another healthy day tomorrow.',
    },
    {
      'title': '✨ Small steps, big transformation',
      'body': 'Consistency beats intensity. Open BMI Calculator to keep your streak alive.',
    },
  ];

  /// How many notifications to pre-schedule per frequency.
  static const int _dailyCount = 14; // 2 weeks worth (daily)
  static const int _weeklyCount = 8; // 2 months worth (weekly)
  static const int _monthlyCount = 6; // 6 months worth (monthly)

  /// Call this after Remote Config is ready.
  /// Cancels any existing schedule and pre-schedules a batch of
  /// future notifications, each with a different message.
  Future<void> scheduleNotifications() async {
    // Remote Config `local_notification` on/off switch.
    final bool enabled = Get.isRegistered<RemoteConfigService>()
        ? RemoteConfigService.to.isLocalNotificationEnabled
        : remoteModel.isLocalNotificationEnabled;
    if (!enabled) {
      log(
        'local_notification is OFF — cancelling scheduled notifications',
        name: _tag,
      );
      await _cancelAll();
      return;
    }

    final rawFrequency = RemoteConfig.showNotificationFrequency
        .trim()
        .toLowerCase();
    log('Scheduling notifications with frequency: $rawFrequency', name: _tag);

    // Initialize timezone data and set local location
    tz_data.initializeTimeZones();
    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
    } catch (e) {
      log('Error getting local timezone: $e, falling back to UTC', name: _tag);
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // Cancel all previously scheduled notifications
    await _cancelAll();

    final int count;
    final Duration interval;

    switch (rawFrequency) {
      case 'w':
      case 'week':
      case 'weekly':
        count = _weeklyCount;
        interval = const Duration(days: 7);
        break;

      case 'm':
      case 'month':
      case 'monthly':
        count = _monthlyCount;
        interval = const Duration(days: 30);
        break;

      case 'd':
      case 'day':
      case 'daily':
      default:
        count = _dailyCount;
        interval = const Duration(days: 1);
        break;
    }

    final random = math.Random();

    // Shuffle messages so each batch is different
    final shuffled = List<Map<String, String>>.from(_messages)..shuffle(random);

    for (int i = 0; i < count; i++) {
      final msg = shuffled[i % shuffled.length];
      final scheduledTime = DateTime.now().add(interval * (i + 1));

      await _plugin.zonedSchedule(
        id: _baseId + i,
        title: msg['title']!,
        body: msg['body']!,
        scheduledDate: _toTZDateTime(scheduledTime),
        notificationDetails: const NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
          android: AndroidNotificationDetails(
            'bmi_calculator_reminders_channel',
            'BMI Calculator Reminders',
            channelDescription:
                'Scheduled health and weight tracking reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: null, // one-shot, not repeating
      );
    }

    log(
      'Scheduled $count notifications, interval=${interval.inHours}h, '
      'first at ${DateTime.now().add(interval)}',
      name: _tag,
    );
  }

  /// Convert a [DateTime] to a [tz.TZDateTime] for scheduling.
  /// Uses the device local timezone.
  tz.TZDateTime _toTZDateTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  /// Cancel all scheduled notifications in our ID range.
  Future<void> _cancelAll() async {
    for (int i = 0; i < 50; i++) {
      await _plugin.cancel(id: _baseId + i);
    }
    log('Previous notifications cancelled', name: _tag);
  }
}
