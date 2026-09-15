class PatientQueueDetailResponse {
  final String sessionId;
  final String patientId;
  final String tokenNumber;
  final String patientName;
  final String abhaId;
  final int age;
  final String gender;
  final String language;
  final String priority;
  final bool consentGranted;
  final String sessionType;
  final String prakritiBadge;
  final bool hasRedFlag;
  final List<String> redFlagSymptoms;
  final List<String> drugInteractionWarnings;

  PatientQueueDetailResponse({
    required this.sessionId,
    required this.patientId,
    required this.tokenNumber,
    required this.patientName,
    required this.abhaId,
    required this.age,
    required this.gender,
    required this.language,
    required this.priority,
    required this.consentGranted,
    required this.sessionType,
    required this.prakritiBadge,
    required this.hasRedFlag,
    required this.redFlagSymptoms,
    required this.drugInteractionWarnings,
  });

  factory PatientQueueDetailResponse.fromJson(Map<String, dynamic> json) {
    return PatientQueueDetailResponse(
      sessionId: json['sessionId'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      tokenNumber: json['tokenNumber'] as String? ?? '',
      patientName: json['patientName'] as String? ?? '',
      abhaId: json['abhaId'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      gender: json['gender'] as String? ?? '',
      language: json['language'] as String? ?? '',
      priority: json['priority'] as String? ?? 'NORMAL',
      consentGranted: json['consentGranted'] as bool? ?? false,
      sessionType: json['sessionType'] as String? ?? 'GENERAL',
      prakritiBadge: json['prakritiBadge'] as String? ?? '',
      hasRedFlag: json['hasRedFlag'] as bool? ?? false,
      redFlagSymptoms: (json['redFlagSymptoms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      drugInteractionWarnings: (json['drugInteractionWarnings'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}