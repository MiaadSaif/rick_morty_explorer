import 'dart:async';

import 'package:flutter/material.dart';

import '../tools/network_info.dart';

/// Monitors network connectivity and exposes whether the device is online.
/// The UI uses this to show the offline banner.
class ConnectivityController extends ChangeNotifier {
  final NetworkInfo _networkInfo;
  final Future<void> Function()? _onConnectionRestored;
  StreamSubscription<bool>? _subscription;
  Timer? _pollingTimer;
  bool isOnline = true;
  bool _disposed = false;
  bool _isChecking = false;
  bool _receivedChange = false;

  ConnectivityController(
    this._networkInfo, {
    Future<void> Function()? onConnectionRestored,
  }) : _onConnectionRestored = onConnectionRestored;

  /// Checks the current connectivity status and updates [isOnline].
  Future<void> initConnectivity() async {
    _subscription = _networkInfo.onConnectivityChanged.listen((online) {
      _receivedChange = true;
      _updateStatus(online);
    });

    final initialOnline = await _networkInfo.isConnected;
    if (!_disposed && !_receivedChange) {
      _updateStatus(initialOnline);
    }

    if (_disposed) return;
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _refreshStatus(),
    );
  }

  Future<void> _refreshStatus() async {
    if (_disposed || _isChecking) return;
    _isChecking = true;
    try {
      final online = await _networkInfo.isConnected;
      if (!_disposed) _updateStatus(online);
    } finally {
      _isChecking = false;
    }
  }

  void _updateStatus(bool online) {
    if (_disposed || isOnline == online) return;
    final wasOffline = !isOnline;
    isOnline = online;
    notifyListeners();
    if (online && wasOffline) {
      final onConnectionRestored = _onConnectionRestored;
      if (onConnectionRestored != null) {
        unawaited(onConnectionRestored());
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _pollingTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}
