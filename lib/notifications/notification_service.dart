import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'local_notification_scheduler.dart';

/// Top-level function required for background/terminated FCM messages.
/// Must be a top-level function (not a class method or closure).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('FCM background message: ${message.messageId}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  late FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize FCM + Local Notifications. Call once from main().
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    _messaging = FirebaseMessaging.instance;

    // ── 1. Register FCM background handler ──
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // ── 2. Initialize flutter_local_notifications (permissions deferred to Home) ──
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(
      iOS: darwinSettings,
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // ── 4. Configure foreground notification presentation (iOS) ──
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // ── 5. Listen for foreground FCM messages ──
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // ── 6. Handle notification taps (app in background) ──
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // ── 7. Handle notification tap that launched the app (terminated state) ──
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // ── 8. Get FCM token ──
    await _fetchAndLogToken();

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      log('FCM token refreshed: $newToken');
    });
  }

  /// Requests push notification permissions (call when user reaches Home).
  Future<NotificationSettings> requestPermission() async {
    if (!_isInitialized) {
      await initialize();
    }
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    log('FCM permission status: ${settings.authorizationStatus}');
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      try {
        await LocalNotificationScheduler.instance.scheduleNotifications();
      } catch (e) {
        log('Error scheduling local notifications: $e');
      }
    }
    return settings;
  }

  /// Fetch the FCM token and log it.
  Future<String?> _fetchAndLogToken() async {
    try {
      final token = await _messaging.getToken();
      log('FCM Token: $token');
      return token;
    } catch (e) {
      log('Error fetching FCM token: $e');
      return null;
    }
  }

  /// Get the current FCM token (useful for sending to your server).
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  /// Handle an incoming FCM message while app is in the foreground.
  void _handleForegroundMessage(RemoteMessage message) {
    log('FCM foreground message: ${message.messageId}');

    final notification = message.notification;
    if (notification != null) {
      showNotification(
        title: notification.title ?? 'BMI Calculator',
        body: notification.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  /// Handle when user taps a notification (app was in background/terminated).
  void _handleNotificationTap(RemoteMessage message) {
    log('FCM notification tapped: ${message.data}');
    _forceShowAppOpenAd();
  }

  /// Called when user taps a local notification.
  void _onNotificationTap(NotificationResponse response) {
    log('Local notification tapped: ${response.payload}');
    _forceShowAppOpenAd();
  }

  void _forceShowAppOpenAd() {
    log('Notification tapped - app opened');
  }

  /// Show a local notification on the device.
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const androidDetails = AndroidNotificationDetails(
      'bmi_calculator_channel',
      'BMI Calculator Notifications',
      channelDescription: 'Important updates and health reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      iOS: iosDetails,
      android: androidDetails,
    );

    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  /// Subscribe to a topic for targeted push notifications.
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    log('Subscribed to FCM topic: $topic');
  }

  /// Unsubscribe from a topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    log('Unsubscribed from FCM topic: $topic');
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // handle background tap action
}
