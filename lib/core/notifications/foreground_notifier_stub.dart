import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin localNotifications =
    FlutterLocalNotificationsPlugin();

class ForegroundNotifier {
  static const String channelId = 'nestak_alerts_v3';
  static const String channelName = 'Nestak Alerts';
  static const String channelDescription =
      'Important notifications for Nestak (sound + heads-up)';

  static const Color notificationColor = Color(0xFFCD0012);

  static bool _initialized = false;
  static void Function(String? payload)? _onTap;

  static Future<bool> ensurePermission() async {
    // Android 13+
    if (Platform.isAndroid) {
      final android = localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? true;
    }

    // iOS
    if (Platform.isIOS) {
      final ios = localNotifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? true;
    }

    if (Platform.isMacOS) {
      final mac = localNotifications
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >();
      final granted = await mac?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? true;
    }

    return true;
  }

  static Future<void> init({void Function(String? payload)? onTap}) async {
    if (_initialized) {
      // Allow updating the tap callback.
      _onTap = onTap;
      return;
    }

    _onTap = onTap;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _onTap?.call(response.payload);
      },
    );

    // Ask permissions (Android 13+ & iOS)
    await ensurePermission();

    // Android: create a high-importance channel.
    const channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  static Future<void> requestAndroidPermissionIfNeeded() async {
    if (!Platform.isAndroid) return;

    try {
      final androidPlugin = localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      // Available on Android 13+. On older versions it returns null or throws.
      await androidPlugin?.requestNotificationsPermission();
    } catch (_) {}
  }

  static Future<String?> getLaunchPayload() async {
    try {
      final details = await localNotifications
          .getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp ?? false) {
        return details?.notificationResponse?.payload;
      }
    } catch (_) {}
    return null;
  }

  static Future<void> show({
    required String title,
    required String body,
    int? id,
    String? payload,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        icon: '@mipmap/ic_launcher_monochrome',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        onlyAlertOnce: true,
        channelShowBadge: true,
        visibility: NotificationVisibility.public,
        color: notificationColor,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      ),
    );

    await localNotifications.show(
      id ?? (DateTime.now().millisecondsSinceEpoch % 100000),
      title,
      body,
      details,
      payload: payload,
    );
  }
}
