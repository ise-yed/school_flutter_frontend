import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkManager {
  static final Connectivity _connectivity = Connectivity();

  static final StreamController<bool> _statusController =
      StreamController<bool>.broadcast();

  static StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  static bool? _lastStatus;

  static Future<bool> hasInternetConnection({
    Duration timeout = const Duration(seconds: 2),
  }) async {
    final status = await _connectivity.checkConnectivity();
    if (status == ConnectivityResult.none) return false;

    if (kIsWeb) return true;

    Future<bool> probe(String host) async {
      try {
        final s = await Socket.connect(host, 53, timeout: timeout);
        s.destroy();
        return true;
      } catch (_) {
        return false;
      }
    }

    if (await probe('1.1.1.1')) return true;
    if (await probe('8.8.8.8')) return true;

    try {
      final lookup = await InternetAddress.lookup(
        'example.com',
      ).timeout(timeout);
      return lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
    } on Exception {
      return false;
    }
  }

  static void _startMonitoring() {
    if (_connectivitySub != null) return;

    _connectivitySub = _connectivity.onConnectivityChanged.listen((list) async {
      final result = list.isNotEmpty ? list.first : ConnectivityResult.none;

      final hasNet = result == ConnectivityResult.none
          ? false
          : await hasInternetConnection();

      if (hasNet != _lastStatus) {
        _lastStatus = hasNet;
        _statusController.add(hasNet);
      }
    });

    hasInternetConnection().then((value) {
      _lastStatus = value;
      _statusController.add(value);
    });
  }

  static Stream<bool> get internetStatusStream async* {
    _startMonitoring();
    if (_lastStatus != null) {
      yield _lastStatus!;
    }
    yield* _statusController.stream;
  }

  static bool? get lastKnownStatus => _lastStatus;

  static Future<void> dispose() async {
    await _connectivitySub?.cancel();
    _connectivitySub = null;
    // await _statusController.close();
  }
}
