import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstraction over "do we have connectivity right now". Repositories
/// depend on this interface, never on `connectivity_plus` directly, so the
/// check is trivial to fake in tests.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  const NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final results = await connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }
}
