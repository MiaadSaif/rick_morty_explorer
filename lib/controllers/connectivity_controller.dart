import 'dart:async';

import 'package:flutter/material.dart';

import '../tools/network_info.dart';

/// Monitors network connectivity and exposes whether the device is online.
/// The UI uses this to show the offline banner.
class ConnectivityController extends ChangeNotifier {
  final NetworkInfo _networkInfo;
  final Future<void> Function()? _onConnectionRestored;
  StreamSubscription<bool>? _subscription;
  bool isOnline = true;

  ConnectivityController(
    this._networkInfo, {
    Future<void> Function()? onConnectionRestored,
  }) : _onConnectionRestored = onConnectionRestored;

  /// Checks the current connectivity status and updates [isOnline].
  Future<void> initConnectivity() async {
    isOnline = await _networkInfo.isConnected;
    _subscription = _networkInfo.onConnectivityChanged.listen((online) {
      final wasOffline = !isOnline;
      isOnline = online;
      notifyListeners();
      if (online && wasOffline) {
        _onConnectionRestored?.call();
      }
    });
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
