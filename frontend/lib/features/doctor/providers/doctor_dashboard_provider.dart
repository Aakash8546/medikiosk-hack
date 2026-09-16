import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/doctor_dashboard_response.dart';
import '../../../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());





class DoctorDashboardException implements Exception {
  final String message;
  final bool requiresLogin;

  const DoctorDashboardException(this.message, {this.requiresLogin = false});

  @override
  String toString() => message;
}

final doctorDashboardProvider =
    FutureProvider<DoctorDashboardResponse>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final data = await apiService.getDoctorDashboard();
    return DoctorDashboardResponse.fromJson(data);
  } on DioException catch (e) {
    final status = e.response?.statusCode;
    if (status == 401 || status == 403) {
      throw const DoctorDashboardException(
        'Your session has expired. Please sign in again.',
        requiresLogin: true,
      );
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw const DoctorDashboardException(
        'The server is taking too long to respond. Pull down to retry.',
      );
    }
    if (e.type == DioExceptionType.connectionError) {
      throw const DoctorDashboardException(
        'No connection to the hospital server.',
      );
    }
    throw DoctorDashboardException(
      'Could not load the OPD queue (error ${status ?? 'unknown'}).',
    );
  }
});