

abstract final class ApiEndpoints {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://medikioskbackend.duckdns.org/api/v1',
  );
 

  
  static const String authToken = '/auth/token';
  static const String registerDoctor = '/auth/register';
  static const String loginDoctor = '/auth/login';

  
  static const String createSession = '/sessions';

  
  static const String registerPatient = '/patients';
  static const String identifyPatient = '/patients/identify';

  
  static const String createConsent = '/consent';

  
  static const String startInterview = '/interview/start';
  static const String interviewReply = '/interview/reply';
  static String submitAnswer(String interviewId) =>
      '/interview/$interviewId/answers';
  static String getInterviewAlerts(String interviewId) =>
      '/interview/$interviewId/alerts';

  
  static const String uploadDocument = '/documents/upload';
  static String sessionDocuments(String sessionId) => '/documents/session/$sessionId';
  static String processOcr(String documentId) =>
      '/documents/$documentId/ocr';
  static String extractDocument(String documentId) =>
      '/documents/$documentId/extract';
  static const String getUploadUrl = '/documents/upload-url';

  
  static const String processOcrBatch = '/ocr/process';

  
  static const String generateSummary = '/clinical-summary/generate';

  
  
  
  static const String submitIntake = '/intake/submit';
  static const String submitCase = '/submissions';
  static String getQueueStatus(String submissionId) =>
      '/queue/$submissionId';

  
  static const String generateAbhaOtp = '/abha/generate-otp';
  static const String verifyAbhaOtp = '/abha/verify-otp';
  static const String aadhaarGenerateOtp = '/abha/aadhaar/generate-otp';
  static const String aadhaarVerifyOtp = '/abha/aadhaar/verify-otp';
  static const String abhaRegister = '/abha/register';
  static String linkedAccounts(String phone) => '/abha/linked-accounts/$phone';
  static const String verifyFaceBiometric = '/abha/face/verify';
  static const String verifyFingerprintBiometric = '/abha/biometric/fingerprint';
  static const String enrollFaceBiometric = '/abha/biometric/enroll-face';
  static const String enrollFingerprintBiometric = '/abha/biometric/enroll-fingerprint';
  static const String matchFingerprintByDevice = '/abha/biometric/match-fingerprint';


  
  static const String verifyAbha = '/abdm/abha/verify';
  static const String requestAbdmConsent = '/abdm/consent/request';

  
  static const String createFhirPatient = '/fhir/patient';

  
  static String submitToHis(String encounterId) =>
      '/his/encounters/$encounterId/history';

  
  static const String transcribe = '/speech/transcribe';
  static const String synthesize = '/speech/synthesize';

  
  static const String clinicalStructure = '/ai/clinical-structure';

  
  static const String ayushAssessment = '/ayush/assessment';
  static String ayushReport(String sessionId) => '/ayush/session/$sessionId/report';
  static String ayushPdf(String sessionId, [String lang = 'en']) =>
      '/ayush/session/$sessionId/pdf?lang=$lang';

  
  static const String doctorDashboard = '/doctor/dashboard';
  static String doctorPatientDetail(String sessionId) => '/doctor/patient-detail/$sessionId';
  static String doctorClinicalView(String sessionId) => '/doctor/clinical-view/$sessionId';
  static String doctorAiSummary(String sessionId) => '/doctor/ai-summary/$sessionId';
  static String doctorDocuments(String sessionId) => '/doctor/documents/$sessionId';
  static String doctorTimeline(String sessionId) => '/doctor/timeline/$sessionId';
  static String doctorConsultationNotes(String sessionId) => '/doctor/consultation-notes/$sessionId';
  static String doctorRedFlagAlert(String sessionId) => '/doctor/red-flag-alert/$sessionId';
  static String doctorConfirmationSummary(String sessionId) => '/doctor/confirmation-summary/$sessionId';
  static const String editClinicalSummary = '/consultation/summary/edit';
  static String doctorCompletionStatus(String sessionId) => '/doctor/completion-status/$sessionId';
  static String acknowledgeRedFlag(String alertId) => '/red-flags/$alertId/acknowledge';
}
