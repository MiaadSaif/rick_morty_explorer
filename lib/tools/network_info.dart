import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstract interface for checking network connectivity.
/// This allows us to swap implementations in tests.
abstract class NetworkInfo {
  /// Returns true if the device has an active network connection.
  Future<bool> get isConnected;
}

/// Concrete implementation that uses the `connectivity_plus` package.
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  const NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final results = await connectivity.checkConnectivity();

    // connectivity_plus returns a list of active connection types.
    // If the list is empty or only contains `none`, there is no connection.
    final hasConnection = results.isNotEmpty &&
        results.any((type) => type != ConnectivityResult.none);

    return hasConnection;
  }
}
