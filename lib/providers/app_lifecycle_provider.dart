import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/app_logger.dart';
import '../services/auth_service.dart';
import '../services/cloud_sync_service.dart';
import 'providers.dart';

class AppLifecycleNotifier extends StateNotifier<AppLifecycleState>
    with WidgetsBindingObserver {
  final CloudSyncService _cloudSync;
  final AuthService _authService;
  final Ref _ref;
  Timer? _syncDebounce;

  AppLifecycleNotifier(this._cloudSync, this._authService, this._ref)
    : super(AppLifecycleState.resumed) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _syncDebounce?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    this.state = state;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _ref.read(connectivityServiceProvider).stop();
      _syncDebounce?.cancel();
      _syncDebounce = Timer(const Duration(seconds: 2), _syncToCloud);
    } else if (state == AppLifecycleState.resumed) {
      _ref.read(connectivityServiceProvider).start();
      _ref.read(authProvider.notifier).refreshCurrentUser();
    }
  }

  Future<void> _syncToCloud() async {
    try {
      final auth = _ref.read(authProvider);
      if (!auth.isAuthenticated) return;
      final prefs = _ref.read(prefsProvider);
      final uid = _authService.currentUser?.uid;
      if (uid != null) {
        await _cloudSync.saveAll(uid, prefs);
        // After a full cloud sync the local gem cache is reconciled with the
        // authoritative server balance (NUEVO-03).
        _ref.read(gemProvider.notifier).syncBalanceFromServer();
        // Server-authoritative inventory reconciliation (NUEVO-08).
        await _ref.read(itemProvider.notifier).syncFromServer();
      }
    } catch (e) {
      AppLogger().error('Cloud sync on app pause failed', e);
    }
  }
}

final appLifecycleProvider =
    StateNotifierProvider<AppLifecycleNotifier, AppLifecycleState>((ref) {
      final cloudSync = ref.read(cloudSyncServiceProvider);
      final authService = ref.read(authServiceProvider);
      return AppLifecycleNotifier(cloudSync, authService, ref);
    });
