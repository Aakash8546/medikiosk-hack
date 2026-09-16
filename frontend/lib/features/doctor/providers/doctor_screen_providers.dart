import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/doctor_portal_responses.dart';
import 'doctor_dashboard_provider.dart';








final doctorAiSummaryProvider =
    FutureProvider.family<DoctorAiSummary, String>((ref, sessionId) async {
  final data = await ref.watch(apiServiceProvider).getDoctorAiSummary(sessionId);
  return DoctorAiSummary.fromJson(data);
});


final doctorTimelineProvider =
    FutureProvider.family<DoctorTimeline, String>((ref, sessionId) async {
  final data = await ref.watch(apiServiceProvider).getDoctorTimeline(sessionId);
  return DoctorTimeline.fromJson(data);
});


final doctorRedFlagProvider =
    FutureProvider.family<DoctorRedFlagAlert, String>((ref, sessionId) async {
  final data = await ref.watch(apiServiceProvider).getDoctorRedFlagAlert(sessionId);
  return DoctorRedFlagAlert.fromJson(data);
});


final doctorConfirmationProvider =
    FutureProvider.family<DoctorConfirmation, String>((ref, sessionId) async {
  final data =
      await ref.watch(apiServiceProvider).getDoctorConfirmationSummary(sessionId);
  return DoctorConfirmation.fromJson(data);
});


final doctorConsultationNotesProvider =
    FutureProvider.family<DoctorConsultationNotes, String>((ref, sessionId) async {
  final data =
      await ref.watch(apiServiceProvider).getDoctorConsultationNotes(sessionId);
  return DoctorConsultationNotes.fromJson(data);
});


void invalidateDoctorPatientProviders(WidgetRef ref, String sessionId) {
  ref.invalidate(doctorAiSummaryProvider(sessionId));
  ref.invalidate(doctorTimelineProvider(sessionId));
  ref.invalidate(doctorRedFlagProvider(sessionId));
  ref.invalidate(doctorConfirmationProvider(sessionId));
  ref.invalidate(doctorConsultationNotesProvider(sessionId));
}

