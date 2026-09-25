import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:get/get.dart';

import '../data/models/remote_model.dart';
import '../data/services/remote_config_service.dart';

class LocalNotificationScheduler {
  LocalNotificationScheduler._();
  static final LocalNotificationScheduler instance =
      LocalNotificationScheduler._();

  static const String _tag = 'LocalNotifScheduler';
  static const int _baseId = 9000;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
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
    final int stepDays;

    switch (rawFrequency) {
      case 'w':
      case 'week':
      case 'weekly':
        count = _weeklyCount;
        stepDays = 7;
        break;

      case 'm':
      case 'month':
      case 'monthly':
        count = _monthlyCount;
        stepDays = 30;
        break;

      case 'd':
      case 'day':
      case 'daily':
      default:
        count = _dailyCount;
        stepDays = 1;
        break;
    }

    // Fixed morning reminder time (default: 9:00 AM local time for weigh-in)
    int targetHour = 9;
    int targetMinute = 0;
    try {
      final hourStr = RemoteConfig.getString('notification_hour').trim();
      if (hourStr.isNotEmpty) {
        final parsed = int.tryParse(hourStr);
        if (parsed != null && parsed >= 0 && parsed <= 23) {
          targetHour = parsed;
        }
      }
      final minStr = RemoteConfig.getString('notification_minute').trim();
      if (minStr.isNotEmpty) {
        final parsed = int.tryParse(minStr);
        if (parsed != null && parsed >= 0 && parsed <= 59) {
          targetMinute = parsed;
        }
      }
    } catch (_) {}

    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime firstDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      targetHour,
      targetMinute,
    );

    // If target time today has already passed, start tomorrow morning
    if (firstDate.isBefore(now)) {
      firstDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + 1,
        targetHour,
        targetMinute,
      );
    }

    final random = math.Random();

    // Shuffle messages so each batch is different
    final shuffled = List<Map<String, String>>.from(_messages)..shuffle(random);

    for (int i = 0; i < count; i++) {
      final msg = shuffled[i % shuffled.length];
      final scheduledDate = tz.TZDateTime(
        tz.local,
        firstDate.year,
        firstDate.month,
        firstDate.day + (stepDays * i),
        targetHour,
        targetMinute,
      );

      await _plugin.zonedSchedule(
        id: _baseId + i,
        title: msg['title']!,
        body: msg['body']!,
        scheduledDate: scheduledDate,
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
        matchDateTimeComponents: null, // one-shot, pre-scheduled batch
      );
    }

    log(
      'Scheduled $count notifications at ${targetHour.toString().padLeft(2, '0')}:${targetMinute.toString().padLeft(2, '0')} local time, '
      'first at $firstDate, stepDays=$stepDays',
      name: _tag,
    );
  }

  /// Cancel all scheduled notifications in our ID range.
  Future<void> _cancelAll() async {
    for (int i = 0; i < 50; i++) {
      await _plugin.cancel(id: _baseId + i);
    }
    log('Previous notifications cancelled', name: _tag);
  }
}
