import 'package:web/web.dart' as web;
import 'dart:js_interop';

class ForegroundNotifier {
  static void Function(String? payload)? _onTap;

  static bool get isGranted {
    return web.Notification.permission == 'granted';
  }

  static Future<bool> ensurePermission() async {
    if (isGranted) return true;

    final res = await web.Notification.requestPermission().toDart;
    return res == 'granted';
  }

  static Future<void> init({void Function(String? payload)? onTap}) async {
    _onTap = onTap;
  }

  static Future<String?> getLaunchPayload() async => null;

  static Future<void> show({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!isGranted) return;

    final n = web.Notification(title, web.NotificationOptions(body: body));

    n.onclick = ((web.Event _) {
      _onTap?.call(payload);
      n.close();
    }).toJS;
  }
}
