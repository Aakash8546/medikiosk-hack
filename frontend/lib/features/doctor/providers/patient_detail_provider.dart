import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/patient_queue_detail_response.dart';
import 'doctor_dashboard_provider.dart';

final patientDetailProvider = FutureProvider.family<PatientQueueDetailResponse, String>((ref, sessionId) async {
  final apiService = ref.watch(apiServiceProvider);
  final data = await apiService.getPatientQueueDetail(sessionId);
  return PatientQueueDetailResponse.fromJson(data);
});