import 'package:dio/dio.dart';


class OfflineInterceptor extends Interceptor {
  final Future<bool> Function() _isConnected;

  OfflineInterceptor({required Future<bool> Function() isConnected})
      : _isConnected = isConnected;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final connected = await _isConnected();

    if (!connected && err.type == DioExceptionType.connectionError) {
      
      
      return handler.next(err);
    }

    return handler.next(err);
  }
}