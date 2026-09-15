class PatientClinicalViewResponse {
  final String sessionId;
  final String patientId;
  final String patientName;
  final String abhaId;
  final String ageGenderAbha;
  final String consentStatusBanner;
  final Map<String, String> vitalsGrid;
  final List<String> chiefComplaints;
  final List<String> pastMedicalHistory;
  final List<String> currentMedications;
  final List<String> allergies;
  final List<String> familyHistory;
  final String ayushSummary;
  final String prakritiSnapshot;
  final bool hasRedFlag;
  final List<String> redFlags;

  const PatientClinicalViewResponse({
    required this.sessionId,
    required this.patientId,
    required this.patientName,
    required this.abhaId,
    this.ageGenderAbha = '',
    required this.consentStatusBanner,
    required this.vitalsGrid,
    required this.chiefComplaints,
    this.pastMedicalHistory = const [],
    required this.prakritiSnapshot,
    this.ayushSummary = '',
    required this.currentMedications,
    required this.familyHistory,
    required this.allergies,
    this.hasRedFlag = false,
    this.redFlags = const [],
  });

  factory PatientClinicalViewResponse.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(dynamic value) {
      if (value is List) {
        return value.where((e) => e != null).map((e) => e.toString()).toList();
      } else if (value is String && value.trim().isNotEmpty) {
        return [value.trim()];
      }
      return [];
    }

    final ayush = (json['ayushSummary'] as String?)?.trim().isNotEmpty == true
        ? (json['ayushSummary'] as String).trim()
        : (json['prakritiSnapshot'] as String? ?? '').trim();

    final complaints = json['chiefComplaints'] != null
        ? parseStringList(json['chiefComplaints'])
        : parseStringList(json['chiefComplaint']);

    final pastHistory = parseStringList(json['pastMedicalHistory']);

    final redFlagsList = parseStringList(json['redFlags']);
    final hasRedFlagVal = (json['hasRedFlag'] as bool?) ?? redFlagsList.isNotEmpty;

    return PatientClinicalViewResponse(
      sessionId: json['sessionId'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      patientName: json['patientName'] as String? ?? 'Unknown Patient',
      abhaId: json['abhaId'] as String? ?? '',
      ageGenderAbha: json['ageGenderAbha'] as String? ?? '',
      consentStatusBanner:
          json['consentStatusBanner'] as String? ?? 'Consent: Granted',
      vitalsGrid: (json['vitalsGrid'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k.toString(), v.toString()),
          ) ??
          {},
      chiefComplaints: complaints,
      pastMedicalHistory: pastHistory,
      prakritiSnapshot: ayush,
      ayushSummary: ayush,
      currentMedications: parseStringList(json['currentMedications']),
      familyHistory: parseStringList(json['familyHistory']),
      allergies: parseStringList(json['allergies']),
      hasRedFlag: hasRedFlagVal,
      redFlags: redFlagsList,
    );
  }
}