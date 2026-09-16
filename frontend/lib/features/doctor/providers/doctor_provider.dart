import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/patient.dart';
import '../../../models/clinical_summary.dart';

class DoctorQueueItem {
  final Patient patient;
  final ClinicalSummary summary;
  final String token;
  final String status; 

  const DoctorQueueItem({
    required this.patient,
    required this.summary,
    required this.token,
    this.status = 'waiting',
  });
}

class DoctorNotifier extends StateNotifier<List<DoctorQueueItem>> {
  DoctorNotifier() : super([]);

  void setStatus(String token, String status) {
    state = [
      for (final item in state)
        if (item.token == token)
          DoctorQueueItem(
            patient: item.patient,
            summary: item.summary,
            token: item.token,
            status: status,
          )
        else
          item,
    ];
  }
}

final doctorQueueProvider =
    StateNotifierProvider<DoctorNotifier, List<DoctorQueueItem>>(
        (ref) => DoctorNotifier());