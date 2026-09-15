
class MediKioskSession {
  final String? sessionId;
  final String? kioskId;
  final String language;
  final String mode;
  final String status;
  final String? patientId;
  final String? patientName;
  final String? identifierType;
  final bool consentGranted;
  final String? consentId;
  final int currentStep;
  final int totalSteps;
  final String? interviewId;
  final String? summaryId;
  final String? submissionId;
  final String? token;

  const MediKioskSession({
    this.sessionId,
    this.kioskId,
    this.language = 'en',
    this.mode = 'allopathic',
    this.status = 'created',
    this.patientId,
    this.patientName,
    this.identifierType,
    this.consentGranted = false,
    this.consentId,
    this.currentStep = 0,
    this.totalSteps = 8,
    this.interviewId,
    this.summaryId,
    this.submissionId,
    this.token,
  });

  MediKioskSession copyWith({
    String? sessionId,
    String? kioskId,
    String? language,
    String? mode,
    String? status,
    String? patientId,
    String? patientName,
    String? identifierType,
    bool? consentGranted,
    String? consentId,
    int? currentStep,
    int? totalSteps,
    String? interviewId,
    String? summaryId,
    String? submissionId,
    String? token,
  }) {
    return MediKioskSession(
      sessionId: sessionId ?? this.sessionId,
      kioskId: kioskId ?? this.kioskId,
      language: language ?? this.language,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      identifierType: identifierType ?? this.identifierType,
      consentGranted: consentGranted ?? this.consentGranted,
      consentId: consentId ?? this.consentId,
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      interviewId: interviewId ?? this.interviewId,
      summaryId: summaryId ?? this.summaryId,
      submissionId: submissionId ?? this.submissionId,
      token: token ?? this.token,
    );
  }
}