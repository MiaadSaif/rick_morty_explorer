import 'package:flutter/material.dart';

import '../tools/network_info.dart';

/// Monitors network connectivity and exposes whether the device is online.
/// The UI uses this to show the offline banner.
class ConnectivityController extends ChangeNotifier {
  final NetworkInfo _networkInfo;
  bool isOnline = true;

  ConnectivityController(this._networkInfo);

  /// Checks the current connectivity status and updates [isOnline].
  Future<void> initConnectivity() async {
    isOnline = await _networkInfo.isConnected;
    notifyListeners();
  }
}
