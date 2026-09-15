import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/opd_queue.dart';

class DashboardState {
  final String patientName;
  final String abhaId;
  final List<OpdQueue> recentVisits;
  final int prescriptionCount;
  final int labReportCount;
  final int documentCount;
  final int allergyCount;

  const DashboardState({
    this.patientName = 'Patient',
    this.abhaId = '91-XXXX-XXXX-XXXX',
    this.recentVisits = const [],
    this.prescriptionCount = 2,
    this.labReportCount = 5,
    this.documentCount = 8,
    this.allergyCount = 1,
  });
}

final dashboardProvider = Provider<DashboardState>((ref) {
  return const DashboardState();
});