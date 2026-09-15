import 'package:dio/dio.dart';
import 'api_endpoints.dart';
import 'interceptors.dart';


class MediKioskDio {
  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    
    dio.interceptors.addAll([
      AuthInterceptor(),
      RetryInterceptor(),
      LoggingInterceptor(),
    ]);

    return dio;
  }

  
  static Dio get uploadInstance {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 120),
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(),
      RetryInterceptor(),
    ]);

    return dio;
  }

  
  static void reset() {
    _instance = null;
  }
}