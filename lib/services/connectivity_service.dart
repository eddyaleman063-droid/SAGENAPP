import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'app_logger.dart';

/// Monitors network connectivity and online/offline state.
class ConnectivityService {
  static final ConnectivityService instance = ConnectivityService._();
  final _online = ValueNotifier<bool>(false);
  final _offlineSaveCount = ValueNotifier<int>(0);
  final AppLogger _logger = AppLogger();
  final Connectivity _connectivity = Connectivity();
  ValueNotifier<bool> get online => _online;
  ValueNotifier<int> get offlineSaveCount => _offlineSaveCount;
  int get offlineSavedForLater => _offlineSaveCount.value;
  bool _running = false;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityService._();

  void start() {
    if (_running) return;
    _running = true;
    checkConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
      onError: (e) => _logger.warning('ConnectivityService: stream error: $e'),
    );
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    _online.value = results.any(
      (r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet,
    );
  }

  void stop() {
    _running = false;
    _subscription?.cancel();
    _subscription = null;
  }

  void dispose() {
    _running = false;
    _subscription?.cancel();
    _subscription = null;
    _online.dispose();
    _offlineSaveCount.dispose();
  }

  void onAppResume() {
    checkConnectivity();
  }

  Future<void> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _online.value = results.any(
        (r) =>
            r == ConnectivityResult.wifi ||
            r == ConnectivityResult.mobile ||
            r == ConnectivityResult.ethernet,
      );
    } catch (e) {
      _logger.warning('ConnectivityService: checkConnectivity failed: $e');
    }
  }
}
