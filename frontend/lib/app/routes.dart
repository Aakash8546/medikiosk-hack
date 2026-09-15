import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/core/utils/page_transitions.dart';


import '../features/onboarding/screens/welcome_screen.dart';
import '../features/onboarding/screens/role_selection_screen.dart';
import '../features/onboarding/screens/mode_selection_screen.dart';


import '../features/patient/screens/identification_screen.dart';
import '../features/patient/screens/registration_screen.dart';
import '../features/patient/screens/aadhaar_registration_screen.dart';
import '../features/patient/screens/patient_otp_screen.dart';


import '../features/consent/screens/consent_screen.dart';


import '../features/interview/screens/voice_conversation_screen.dart';


import '../features/ayush/screens/consultation_type_screen.dart';
import '../features/ayush/screens/what_is_ayush_screen.dart';
import '../features/ayush/screens/prakriti_screen.dart';
import '../features/ayush/screens/dashavidha_screen.dart';
import '../features/ayush/screens/agni_screen.dart';
import '../features/ayush/screens/ahara_vihara_screen.dart';
import '../features/ayush/screens/ayush_assessment_report_screen.dart';
import '../features/ayush/screens/vikriti_screen.dart';
import '../models/ayush_report_response.dart';


import '../features/documents/screens/upload_documents_screen.dart';
import '../features/documents/screens/camera_scan_screen.dart';
import '../features/documents/screens/document_preview_screen.dart';
import '../features/documents/screens/extracted_data_screen.dart';


import '../features/summary/screens/ai_summary_screen.dart';
import '../features/summary/screens/review_confirm_screen.dart';
import '../features/summary/screens/submission_screen.dart';


import '../features/queue/screens/token_queue_screen.dart';


import '../features/dashboard/screens/patient_dashboard_screen.dart';
import '../features/dashboard/screens/profile_screen.dart';
import '../features/dashboard/screens/appointment_screen.dart';
import '../features/dashboard/screens/help_support_screen.dart';
import '../features/dashboard/screens/sidebar_screen.dart';


import '../features/doctor/screens/doctor_registration_screen.dart';
import '../features/doctor/screens/doctor_login_screen.dart';
import '../features/doctor/screens/doctor_dashboard_screen.dart';
import '../features/doctor/screens/patient_clinical_view_screen.dart';


import '../features/patient/screens/patient_summary_screen.dart';
import '../features/patient/screens/ai_clinical_summary_screen.dart';
import '../features/patient/screens/medical_timeline_screen.dart';
import '../features/patient/screens/edit_clinical_summary_screen.dart';
import '../features/patient/screens/red_flag_alert_screen.dart';
import '../features/patient/screens/doctor_confirmation_screen.dart';
import '../features/patient/screens/consultation_notes_screen.dart';
import '../features/patient/screens/consultation_completed_screen.dart';
import '../features/doctor/screens/patient_queue_detail_screen.dart';








import '../core/utils/navigation_service.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: NavigationService.navigatorKey,
    initialLocation: '/',
    routes: [
      
      GoRoute(
        path: '/',
        name: 'welcome',
        builder: (_, __) => const WelcomeScreen(),
      ),

      
      GoRoute(
        path: '/role-selection',
        name: 'roleSelection',
        builder: (_, __) => const RoleSelectionScreen(),
      ),

      
      GoRoute(
        path: '/mode-selection',
        name: 'modeSelection',
        builder: (_, __) => const ModeSelectionScreen(),
      ),

      
      GoRoute(
        path: '/identify',
        name: 'identify',
        builder: (_, __) => const IdentificationScreen(),
      ),

      
      GoRoute(
        path: '/patient-otp',
        name: 'patientOtp',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PatientOtpScreen(
            phoneNumber: extra?['phoneNumber'] as String?,
            abhaId: extra?['abhaId'] as String?,
            txnId: extra?['txnId'] as String?,
            maskedMobile: extra?['maskedMobile'] as String?,
            isAadhaarLogin: extra?['isAadhaarLogin'] as bool? ?? false,
          );
        },
      ),

      
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (_, __) => const RegistrationScreen(),
      ),

      GoRoute(
        path: '/aadhaar-register',
        name: 'aadhaarRegister',
        builder: (_, __) => const AadhaarRegistrationScreen(),
      ),

      
      GoRoute(
        path: '/consent',
        name: 'consent',
        builder: (_, __) => const ConsentScreen(),
      ),

      
      GoRoute(
        path: '/voice-conversation',
        name: 'voiceConversation',
        builder: (_, __) => const VoiceConversationScreen(),
      ),

      
      GoRoute(
        path: '/consultation-type',
        name: 'consultationType',
        builder: (_, __) => const ConsultationTypeScreen(),
      ),

      
      GoRoute(
        path: '/what-is-ayush',
        name: 'whatIsAyush',
        pageBuilder: (context, state) => ayushTransition(
          child: const WhatIsAyushScreen(),
          state: state,
        ),
      ),

      
      GoRoute(
        path: '/ayush',
        name: 'ayush',
        builder: (_, __) => const AyurvedicAssessmentScreen(),
      ),

      
      GoRoute(
        path: '/personalized-recommendations',
        name: 'ayushReport',
        pageBuilder: (context, state) => ayushTransition(
          child: AyushAssessmentReportScreen(
            report: state.extra is AyushReportResponse
                ? state.extra as AyushReportResponse
                : null,
          ),
          state: state,
        ),
      ),

      
      GoRoute(
        path: '/ahara-vihara',
        name: 'aharaVihara',
        pageBuilder: (context, state) => ayushTransition(
          child: const AharaViharaScreen(),
          state: state,
        ),
      ),

      
      GoRoute(
        path: '/agni',
        name: 'agni',
        pageBuilder: (context, state) => ayushTransition(
          child: const AgniScreen(),
          state: state,
        ),
      ),

      
      GoRoute(
        path: '/vikriti',
        name: 'vikriti',
        pageBuilder: (context, state) => ayushTransition(
          child: const VikritiScreen(),
          state: state,
        ),
      ),

      
      GoRoute(
        path: '/dashavidha',
        name: 'dashavidha',
        pageBuilder: (context, state) => ayushTransition(
          child: const DashavidhaScreen(),
          state: state,
        ),
      ),

      
      GoRoute(
        path: '/upload-documents',
        name: 'uploadDocuments',
        builder: (_, __) => const DocumentScanScreen(),
      ),

      
      GoRoute(
        path: '/scan-camera',
        name: 'scanCamera',
        builder: (_, __) => const ScanCameraScreen(),
      ),

      
      GoRoute(
        path: '/document-preview',
        name: 'documentPreview',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return DocumentPreviewScreen(
            filePath: extra?['filePath'] as String?,
            
            
            filePaths: (extra?['filePaths'] as List?)?.cast<String>(),
          );
        },
      ),

      
      GoRoute(
        path: '/extracted-data',
        name: 'extractedData',
        builder: (_, __) => const OcrReviewScreen(),
      ),

      
      GoRoute(
        path: '/review-confirm',
        name: 'reviewConfirm',
        builder: (_, __) => const ReviewConfirmScreen(),
      ),

      
      GoRoute(
        path: '/ai-summary',
        name: 'aiSummary',
        builder: (_, __) => const ClinicalSummaryScreen(),
      ),

      
      GoRoute(
        path: '/submit',
        name: 'submit',
        builder: (_, __) => const SubmissionScreen(),
      ),

      
      GoRoute(
        path: '/token',
        name: 'token',
        builder: (_, __) => const TokenQueueScreen(),
      ),

      
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (_, __) => const DashboardScreen(),
      ),

      
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (_, __) => const ProfileScreen(),
      ),

      
      GoRoute(
        path: '/sidebar',
        name: 'sidebar',
        builder: (_, __) => const SidebarScreen(),
      ),

      
      GoRoute(
        path: '/appointment',
        name: 'appointment',
        builder: (_, __) => const AppointmentScreen(),
      ),

      
      GoRoute(
        path: '/help',
        name: 'help',
        builder: (_, __) => const HelpSupportScreen(),
      ),

      
      GoRoute(
        path: '/doctor-register',
        name: 'doctorRegister',
        builder: (_, __) => const DoctorRegistrationScreen(),
      ),

      
      GoRoute(
        path: '/doctor-login',
        name: 'doctorLogin',
        builder: (_, __) => const DoctorLoginScreen(),
      ),

      
      GoRoute(
        path: '/doctor-dashboard',
        name: 'doctorDashboard',
        builder: (_, __) => const DoctorDashboardScreen(),
      ),

      
      GoRoute(
        path: '/patient-clinical-view',
        name: 'patientClinicalView',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PatientClinicalViewScreen(
            sessionId: extra?['sessionId'] as String?,
            patientId: extra?['patientId'] as String?,
            patientName: extra?['patientName'] as String?,
            abhaId: extra?['abhaId'] as String?,
            token: extra?['token'] as String?,
          );
        },
      ),

      
      GoRoute(
        path: '/patient-summary',
        name: 'patientSummary',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PatientSummaryScreen(
            patientName: extra?['patientName'] as String?,
            abhaId: extra?['abhaId'] as String?,
            sessionId: extra?['sessionId'] as String?,
          );
        },
      ),

      
      GoRoute(
        path: '/ai-clinical-summary',
        name: 'aiClinicalSummary',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return AiClinicalSummaryScreen(
            patientName: extra?['patientName'] as String?,
            abhaId: extra?['abhaId'] as String?,
            sessionId: extra?['sessionId'] as String?,
          );
        },
      ),

      
      GoRoute(
        path: '/medical-timeline',
        name: 'medicalTimeline',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return MedicalTimelineScreen(
            patientName: extra?['patientName'] as String?,
            abhaId: extra?['abhaId'] as String?,
            sessionId: extra?['sessionId'] as String?,
          );
        },
      ),

      
      GoRoute(
        path: '/edit-clinical-summary',
        name: 'editClinicalSummary',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return EditClinicalSummaryScreen(
            patientName: extra?['patientName'] as String?,
            abhaId: extra?['abhaId'] as String?,
            sessionId: extra?['sessionId'] as String?,
          );
        },
      ),

      
      GoRoute(
        path: '/red-flag-alert',
        name: 'redFlagAlert',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return RedFlagAlertScreen(
            patientName: extra?['patientName'] as String?,
            abhaId: extra?['abhaId'] as String?,
            message: extra?['message'] as String?,
            redFlags: (extra?['redFlags'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
            sessionId: extra?['sessionId'] as String?,
          );
        },
      ),

      
      GoRoute(
        path: '/doctor-confirmation',
        name: 'doctorConfirmation',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return DoctorConfirmationScreen(
            patientName: extra?['patientName'] as String?,
            abhaId: extra?['abhaId'] as String?,
            sessionId: extra?['sessionId'] as String?,
          );
        },
      ),

      
      
      
      
      
      

      
      
      
      
      
      

      
      
      
      
      
      

      
      
      
      
      
      

      
      
      
      
      
      

      
      
      
      
      
      

      
      
      
      
      
      

      
      
      
      
      
      

      
      GoRoute(
        path: '/patient-queue-detail',
        name: 'patientQueueDetail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PatientQueueDetailScreen(
            sessionId: extra?['sessionId'] as String?,
            patientName: extra?['patientName'] as String?,
            abhaId: extra?['abhaId'] as String?,
            token: extra?['token'] as String?,
          );
        },
      ),

      
      GoRoute(
        path: '/consultation-notes',
        name: 'consultationNotes',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ConsultationNotesScreen(
            patientName: extra?['patientName'] as String?,
            abhaId: extra?['abhaId'] as String?,
            sessionId: extra?['sessionId'] as String?,
          );
        },
      ),

      
      GoRoute(
        path: '/consultation-completed',
        name: 'consultationCompleted',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ConsultationCompletedScreen(
            patientName: extra?['patientName'] as String?,
            abhaId: extra?['abhaId'] as String?,
            sessionId: extra?['sessionId'] as String?,
          );
        },
      ),
    ],
  );
});