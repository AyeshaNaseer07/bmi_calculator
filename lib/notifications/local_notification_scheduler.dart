import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
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

  /// Debug-only test reminder; inside the range [_cancelAll] clears.
  static const int _debugTestId = _baseId + 49;

  static const NotificationDetails _details = NotificationDetails(
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
    android: AndroidNotificationDetails(
      'bmi_calculator_reminders_channel',
      'BMI Calculator Reminders',
      channelDescription: 'Scheduled health and weight tracking reminders',
      importance: Importance.max,
      priority: Priority.high,
    ),
  );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static List<Map<String, String>> get _messages => [
    {
      'title': 'time_to_log_your_weight'.tr,
      'body': 'step_on_the_scale_and_record'.tr,
    },
    {
      'title': 'check_your_bmi_score_today'.tr,
      'body': 'stay_informed_about_your_body_mass'.tr,
    },
    {
      'title': 'stay_healthy_hydrated'.tr,
      'body': 'hydration_fuels_your_metabolism_drink_a'.tr,
    },
    {
      'title': 'consistency_builds_results'.tr,
      'body': 'regular_weigh_ins_help_you_stay'.tr,
    },
    {
      'title': 'daily_health_insight_is_ready'.tr,
      'body': 'discover_wellness_and_nutrition_tips_tailored'.tr,
    },
    {
      'title': 'track_your_progress_trends'.tr,
      'body': 'view_your_history_and_charts_to'.tr,
    },
    {
      'title': 'time_for_a_quick_movement_break'.tr,
      'body': 'a_short_walk_or_stretch_boosts'.tr,
    },
    {
      'title': 'you_are_closer_than_you_think'.tr,
      'body': 'every_healthy_choice_counts_log_your'.tr,
    },
    {
      'title': 'fuel_your_body_right'.tr,
      'body': 'nourish_yourself_with_balanced_meals_to'.tr,
    },
    {
      'title': 'start_your_day_with_a_check'.tr,
      'body': 'a_quick_5_second_log_this'.tr,
    },
    {
      'title': 'reach_your_ideal_weight_zone'.tr,
      'body': 'find_out_your_recommended_weight_target'.tr,
    },
    {
      'title': 'evening_wellness_reflection'.tr,
      'body': 'review_your_progress_today_and_get'.tr,
    },
    {
      'title': 'small_steps_big_transformation'.tr,
      'body': 'consistency_beats_intensity_open_bmi_calculator'.tr,
    },
  ];

  /// How many notifications to pre-schedule per frequency.
  static const int _dailyCount = 14; // 2 weeks worth (daily)
  static const int _weeklyCount = 8; // 2 months worth (weekly)
  static const int _monthlyCount = 6; // 6 months worth (monthly)

  Future<void> scheduleNotifications() async {
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

    // Fixed reminder time: 9:00 AM local time (morning weigh-in).
    const targetHour = 9;
    const targetMinute = 0;

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
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: null, // one-shot, pre-scheduled batch
      );
    }

    // Debug builds only: one reminder a minute from now, so scheduling can be
    // checked without waiting for the morning slot.
    if (kDebugMode) {
      final testDate = now.add(const Duration(minutes: 1));
      await _plugin.zonedSchedule(
        id: _debugTestId,
        title: '🔔 Test reminder (debug build)',
        body: 'Local notifications are working.',
        scheduledDate: testDate,
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      log('Debug test notification scheduled for $testDate', name: _tag);
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
