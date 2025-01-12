import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract interface class ConnectionChecker {
  Future<bool> get isConnected;
  Stream<bool> get onConnectionChange;
}

class ConnectionCheckerImpl implements ConnectionChecker {
  final InternetConnection checker;

  ConnectionCheckerImpl(this.checker);

  @override
  Future<bool> get isConnected async => await checker.hasInternetAccess;

  @override
  Stream<bool> get onConnectionChange => checker.onStatusChange.map(
        (status) => status == InternetStatus.connected,
      );
}
