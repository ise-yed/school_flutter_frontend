import 'dart:async';
import 'dart:convert';
import 'dart:ui' show DartPluginRegistrant;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:school_flutter_frontend/core/constants/app_setting.dart';
import 'package:school_flutter_frontend/features/profile/service/profile_service.dart';
import 'package:school_flutter_frontend/features/splash/screens/splash_screen.dart';

import 'firebase_web_options.dart';
import 'foreground_notifier.dart';

const String kAllUsersTopic = 'all_user';

String userTopic(String userId) => 'user_$userId';

// VAPID Public Key (Firebase Console -> Cloud Messaging -> Web Push certificates)
const String kWebVapidKey =
    'BBH011rqC1c9m5qrhU3ooQ7ukE2DhwAeKkfI2hpRIG1EE2Myt2M4pMJ5757TLO_ZiOay44KaTzCrNhIFjpP0HA8';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Needed when using other plugins in the background isolate (Android).
  try {
    DartPluginRegistrant.ensureInitialized();
  } catch (_) {}

  try {
    if (Firebase.apps.isEmpty) {
      if (kIsWeb) {
        await Firebase.initializeApp(options: firebaseWebOptions);
      } else {
        await Firebase.initializeApp();
      }
    }
  } catch (_) {}

  if (message.notification == null) {
    try {
      await ForegroundNotifier.init();
      final data = Map<String, dynamic>.from(message.data);
      final title = _titleFromData(data, fallback: 'پیام جدید');
      final body = _bodyFromData(data, fallback: data.toString());
      if (title.isEmpty && body.isEmpty) return;
      await ForegroundNotifier.show(
        title: title,
        body: body,
        payload: data.isNotEmpty ? jsonEncode(data) : null,
      );
    } catch (_) {}
  }
}

class MessagingService {
  MessagingService._();

  static final MessagingService instance = MessagingService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  bool _initialized = false;

  // Prevent handling both initialMessage + local launch payload twice.
  bool _launchHandled = false;

  String? _lastSentToken;
  int _sendRetry = 0;
  Timer? _sendRetryTimer;

  final Map<String, int> _topicRetry = {};

  // --- Dedup map to prevent duplicate local notifications in short time window.
  // key: messageId (or fallback), value: DateTime when shown
  final Map<String, DateTime> _recentlyShownMessageTimestamps = {};

  // Track reminder ids handled while app is alive to avoid duplicate dialog on tray taps.
  final Set<String> _handledReminderIds = <String>{};

  // Duration to keep an id in dedup map (tunable).
  final Duration _dedupWindow = const Duration(seconds: 5);

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      if (Firebase.apps.isEmpty) {
        if (kIsWeb) {
          await Firebase.initializeApp(options: firebaseWebOptions);
        } else {
          await Firebase.initializeApp();
        }
      }
    } catch (_) {}

    await ForegroundNotifier.init(onTap: _onLocalNotificationTap);

    final launchPayload = await ForegroundNotifier.getLaunchPayload();
    if (!_launchHandled && launchPayload != null && launchPayload.isNotEmpty) {
      _launchHandled = true;
      _handlePayload(launchPayload);
    }

    if (!kIsWeb) {
      await _fcm.requestPermission(alert: true, badge: true, sound: true);
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // iOS: we rely on local notifications while app is in foreground.
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      unawaited(_sendCurrentTokenToBackendIfAny());
    }

    _fcm.onTokenRefresh.listen((_) async {
      await syncTokenToServer(promptOnWeb: false);
      ensureBaseSubscriptions();
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _handleForegroundMessage(message);
      debugPrint('FCM onMessage id=${message.messageId}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteTap);

    // If app launched from terminated by tapping an FCM notification.
    try {
      final initial = await _fcm.getInitialMessage();
      if (!_launchHandled && initial != null) {
        _launchHandled = true;
        _handleRemoteTap(initial);
      }
    } catch (_) {}

    _initialized = true;
    ensureBaseSubscriptions();
  }

  bool _shouldShowNotification(RemoteMessage message) {
    final idCandidates = <String?>[
      message.messageId,
      message.data['message_id']?.toString(),
      message.data['id']?.toString(),
      message.data['notification_id']?.toString(),
    ];
    final id = idCandidates.firstWhere(
      (e) => e != null && e.trim().isNotEmpty,
      orElse: () => null,
    );

    if (id == null) {
      return true;
    }

    final now = DateTime.now();
    // cleanup old entries
    _recentlyShownMessageTimestamps.removeWhere(
      (k, v) => now.difference(v) > const Duration(minutes: 5),
    );

    final prev = _recentlyShownMessageTimestamps[id];
    if (prev != null && now.difference(prev) < _dedupWindow) {
      // Duplicate within dedup window -> skip showing
      debugPrint('Skipping duplicate notification for id=$id');
      return false;
    }
    // mark shown
    _recentlyShownMessageTimestamps[id] = now;
    return true;
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final data = Map<String, dynamic>.from(message.data);
    final notification = message.notification;

    final reminderId = _reminderIdFromData(data);

    debugPrint('handleForegroundMessage data=${message.data.toString()}');

    final title = _titleFromData(data, fallback: notification?.title ?? '');
    final body = _bodyFromData(data, fallback: notification?.body ?? '');

    if (title.isEmpty && body.isEmpty) return;

    // Deduplicate to avoid double shows for same message id in short time.
    if (_shouldShowNotification(message)) {
      await ForegroundNotifier.show(
        title: title,
        body: body,
        payload: data.isNotEmpty ? jsonEncode(data) : null,
      );
    }

    // Only reminders show the in-app dialog.
    if (_isReminder(data)) {
      if (reminderId != null && reminderId.isNotEmpty) {
        _handledReminderIds.add(reminderId);
      }
      // unawaited(

      // );
    }
  }

  void _handleRemoteTap(RemoteMessage message) {
    final data = Map<String, dynamic>.from(message.data);
    final reminderId = _reminderIdFromData(data);

    if (_isReminder(data)) {
      if (reminderId != null && _handledReminderIds.contains(reminderId)) {
        debugPrint('Skipping reminder tap for already handled id=$reminderId');
        return;
      }

      if (reminderId != null && reminderId.isNotEmpty) {
        _handledReminderIds.add(reminderId);
      }

      return;
    }

    // Non-reminder: open notifications inbox screen.
    _openNotificationInbox();
  }

  void _onLocalNotificationTap(String? payload) {
    if (payload == null || payload.trim().isEmpty) {
      _openNotificationInbox();
      return;
    }
    _handlePayload(payload);
  }

  void _handlePayload(String payload) {
    Map<String, dynamic>? data;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) {
        data = decoded.map((k, v) => MapEntry(k.toString(), v));
      }
    } catch (_) {
      // Sometimes old payloads were stored with toString().
    }

    if (data != null && _isReminder(data)) {
      final reminderId = _reminderIdFromData(data);
      if (reminderId != null && _handledReminderIds.contains(reminderId)) {
        debugPrint(
          'Skipping reminder payload for already handled id=$reminderId',
        );
        return;
      }

      if (reminderId != null && reminderId.isNotEmpty) {
        _handledReminderIds.add(reminderId);
      }

      return;
    }

    _openNotificationInbox();
  }

  void _openNotificationInbox() {
    try {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const SplashScreen()),
      );
    } catch (_) {}
  }

  Future<String?> getToken({bool promptOnWeb = false}) async {
    if (kIsWeb) {
      if (promptOnWeb) {
        final ok = await ForegroundNotifier.ensurePermission();
        if (!ok) return null;
      } else {
        return null;
      }

      final token = await _fcm.getToken(vapidKey: kWebVapidKey);
      if (token != null && token.isNotEmpty) {
        unawaited(syncTokenToServer(promptOnWeb: false));
      }
      return token;
    }

    final token = await _fcm.getToken();
    if (token != null && token.isNotEmpty) {
      unawaited(syncTokenToServer(promptOnWeb: false));
    }
    return token;
  }

  Future<void> _sendCurrentTokenToBackendIfAny() async {
    try {
      final token = await _fcm.getToken();
      if (token == null || token.isEmpty) return;
      final deviceType = kIsWeb
          ? 'web'
          : (defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android');
      await ProfileService().updateFirebaseToken(
        firebaseToken: token,
        deviceType: deviceType,
      );
    } catch (_) {}
  }

  void ensureBaseSubscriptions() {
    _trySubscribe(kAllUsersTopic);
  }

  void onLogin(String userId) {
    _lastSentToken = null;
    ensureBaseSubscriptions();
    _trySubscribe(userTopic(userId));
    unawaited(syncTokenToServer(promptOnWeb: kIsWeb, force: true));
  }

  void onLogout(String userId) {
    _tryUnsubscribe(userTopic(userId));
    _lastSentToken = null;
  }

  void _trySubscribe(String topic) {
    if (kIsWeb) return;
    unawaited(
      _fcm
          .getToken()
          .then((token) {
            if (token == null || token.isEmpty) {
              _scheduleRetry(topic);
              return;
            }

            unawaited(
              _fcm
                  .subscribeToTopic(topic)
                  .then((_) {
                    _topicRetry[topic] = 0;
                  })
                  .catchError((_) {
                    _scheduleRetry(topic);
                  }),
            );
          })
          .catchError((_) {
            _scheduleRetry(topic);
          }),
    );
  }

  void _tryUnsubscribe(String topic) {
    if (kIsWeb) return;

    unawaited(
      _fcm.getToken().then((token) {
        if (token == null || token.isEmpty) return;
        unawaited(_fcm.unsubscribeFromTopic(topic));
      }),
    );
  }

  void _scheduleRetry(String topic) {
    final current = _topicRetry[topic] ?? 0;
    final next = (current + 1).clamp(1, 5);
    _topicRetry[topic] = next;
    Timer(Duration(seconds: 2 * next), () => _trySubscribe(topic));
  }

  Future<void> syncTokenToServer({
    bool promptOnWeb = false,
    bool force = false,
  }) async {
    try {
      String? token;

      if (kIsWeb) {
        if (promptOnWeb) {
          final ok = await ForegroundNotifier.ensurePermission();
          if (!ok) return;
        } else {
          return;
        }
        token = await _fcm.getToken(vapidKey: kWebVapidKey);
      } else {
        token = await _fcm.getToken();
      }

      if (token == null || token.isEmpty) return;

      if (!force && _lastSentToken == token) return;

      final deviceType = kIsWeb
          ? 'web'
          : (defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android');

      await ProfileService().updateFirebaseToken(
        firebaseToken: token,
        deviceType: deviceType,
      );

      _lastSentToken = token;
      _sendRetry = 0;
      _sendRetryTimer?.cancel();
      _sendRetryTimer = null;
    } catch (_) {
      _scheduleSendRetry(promptOnWeb: promptOnWeb);
    }
  }

  void _scheduleSendRetry({required bool promptOnWeb}) {
    _sendRetry = (_sendRetry + 1).clamp(1, 5);
    _sendRetryTimer?.cancel();
    _sendRetryTimer = Timer(Duration(seconds: 2 * _sendRetry), () {
      unawaited(syncTokenToServer(promptOnWeb: promptOnWeb));
    });
  }
}

final messagingService = MessagingService.instance;

bool _isReminder(Map<String, dynamic> data) {
  final t = (data['type'] ?? data['notification_type'] ?? '').toString();
  return t.toLowerCase() == 'reminder';
}

String _titleFromData(Map<String, dynamic> data, {required String fallback}) {
  final v = (data['title'] ?? data['name'] ?? '').toString();
  return v.trim().isEmpty ? fallback : v;
}

String _bodyFromData(Map<String, dynamic> data, {required String fallback}) {
  final v = (data['body'] ?? data['description'] ?? data['message'] ?? '')
      .toString();
  return v.trim().isEmpty ? fallback : v;
}

String? _reminderIdFromData(Map<String, dynamic> data) {
  final v = (data['reminder_id'] ?? data['reminderId'] ?? data['id'])
      ?.toString();
  final trimmed = v?.trim();
  return (trimmed != null && trimmed.isNotEmpty) ? trimmed : null;
}
