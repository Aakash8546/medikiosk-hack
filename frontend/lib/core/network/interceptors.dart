import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_logger.dart';
import '../utils/navigation_service.dart';
import 'dio_client.dart';


class AuthInterceptor extends Interceptor {
  final _storage = const FlutterSecureStorage();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    
    if (options.path.contains('/auth/login') || options.path.contains('/auth/register')) {
      return handler.next(options);
    }

    try {
      final token = await _storage.read(key: 'access_token');
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      
      
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      try {
        await _storage.delete(key: 'access_token');
        await _storage.deleteAll();
      } catch (_) {
        
      }

      
      final context = NavigationService.navigatorKey.currentContext;
      if (context != null && context.mounted) {
        context.go('/doctor-login');
      }
    }
    return handler.next(err);
  }
}


class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration baseDelay;

  RetryInterceptor({
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 1),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryableStatuses = {502, 503, 504};
    final isRetryable = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        (err.response?.statusCode != null &&
            retryableStatuses.contains(err.response!.statusCode));      if (isRetryable) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;
      if (retryCount < maxRetries) {
        final delay = baseDelay * (1 << retryCount); 
        await Future.delayed(delay);

        err.requestOptions.extra['retryCount'] = retryCount + 1;
        try {
          
          final dio = MediKioskDio.instance;
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (_) {
          return handler.next(err);
        }
      }
    }
    return handler.next(err);
  }
}


class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    logApi('${options.method} ${options.uri.path}');
    return handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    logApi('${response.statusCode} ${response.requestOptions.uri.path}');
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    
    
    
    logApi('ERROR ${err.type} ${err.requestOptions.uri.path} '
        'status=${err.response?.statusCode}');
    logDebug('API ERROR', 'response: ${err.response?.data}');
    return handler.next(err);
  }
}