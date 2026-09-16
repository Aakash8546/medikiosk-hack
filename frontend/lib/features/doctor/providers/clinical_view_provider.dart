import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/patient_clinical_view_response.dart';
import 'doctor_dashboard_provider.dart';

final clinicalViewProvider = FutureProvider.family<PatientClinicalViewResponse, String>((ref, sessionId) async {
  final apiService = ref.watch(apiServiceProvider);
  final data = await apiService.getClinicalView(sessionId);
  return PatientClinicalViewResponse.fromJson(data);
});