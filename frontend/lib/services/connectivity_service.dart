import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get isConnected => _controller.stream;

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen((result) {
      final connected = result.any((r) => r != ConnectivityResult.none);
      _controller.add(connected);
    });
  }

  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result.any((r) => r != ConnectivityResult.none);
  }

  void dispose() {
    _controller.close();
  }
}