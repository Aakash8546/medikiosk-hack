import '../network/dio_client.dart';

class ConnectivityChecker {
  
  static Future<bool> isBackendReachable() async {
    try {
      final dio = MediKioskDio.instance;
      final response = await dio.get('/health');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}