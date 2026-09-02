import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

/// Abstract interface for checking network connectivity.
/// This allows us to swap implementations in tests.
abstract class NetworkInfo {
  /// Returns true if the device has an active network connection.
  Future<bool> get isConnected;

  Stream<bool> get onConnectivityChanged;
}

/// Concrete implementation that uses the `connectivity_plus` package.
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;
  final http.Client client;
  final Uri healthCheckUri;

  NetworkInfoImpl(this.connectivity, {http.Client? client, Uri? healthCheckUri})
    : client = client ?? http.Client(),
      healthCheckUri =
          healthCheckUri ?? Uri.parse('https://rickandmortyapi.com');

  @override
  Stream<bool> get onConnectivityChanged => connectivity.onConnectivityChanged
      .map((results) => results.any((type) => type != ConnectivityResult.none));

  @override
  Future<bool> get isConnected async {
    final results = await connectivity.checkConnectivity();
    final hasNetwork = results.any((type) => type != ConnectivityResult.none);
    if (!hasNetwork) return false;

    try {
      final response = await client
          .head(healthCheckUri)
          .timeout(const Duration(seconds: 3));
      return response.statusCode >= 200 && response.statusCode < 400;
    } on Object {
      return false;
    }
  }
}
