



library;

int _int(dynamic v) => (v as num?)?.toInt() ?? 0;
String _str(dynamic v) => v?.toString() ?? '';
List<String> _strList(dynamic v) =>
    v is List ? v.where((e) => e != null).map((e) => e.toString()).toList() : const [];
Map<String, String> _strMap(dynamic v) => v is Map
    ? v.map((k, val) => MapEntry(k.toString(), val?.toString() ?? ''))
    : const {};


class DoctorAiSummary {
  final String patientName;
  final String abhaId;
  final String hpiSummary;
  final int hpiConfidence;

  
  final Map<String, String> vitalsSummary;
  final int vitalsConfidence;
  final List<String> pastMedicalHistory;
  final int pastHistoryConfidence;
  final int totalMedications;
  final int totalAllergies;
  final int totalComplaints;
  final String prakritiSummary;
  final String agniSummary;
  final String vikritiSummary;
  final String lifestyleScore;
  final int ayushConfidence;
  final List<String> drugInteractions;
  final String disclaimer;

  const DoctorAiSummary({
    this.patientName = '',
    this.abhaId = '',
    this.hpiSummary = '',
    this.hpiConfidence = 0,
    this.vitalsSummary = const {},
    this.vitalsConfidence = 0,
    this.pastMedicalHistory = const [],
    this.pastHistoryConfidence = 0,
    this.totalMedications = 0,
    this.totalAllergies = 0,
    this.totalComplaints = 0,
    this.prakritiSummary = '',
    this.agniSummary = '',
    this.vikritiSummary = '',
    this.lifestyleScore = '',
    this.ayushConfidence = 0,
    this.drugInteractions = const [],
    this.disclaimer = '',
  });

  factory DoctorAiSummary.fromJson(Map<String, dynamic> j) => DoctorAiSummary(
        patientName: _str(j['patientName']),
        abhaId: _str(j['abhaId']),
        hpiSummary: _str(j['hpiSummary']),
        hpiConfidence: _int(j['hpiConfidence']),
        vitalsSummary: _strMap(j['vitalsSummary']),
        vitalsConfidence: _int(j['vitalsConfidence']),
        pastMedicalHistory: _strList(j['pastMedicalHistory']),
        pastHistoryConfidence: _int(j['pastHistoryConfidence']),
        totalMedications: _int(j['totalMedications']),
        totalAllergies: _int(j['totalAllergies']),
        totalComplaints: _int(j['totalComplaints']),
        prakritiSummary: _str(j['prakritiSummary']),
        agniSummary: _str(j['agniSummary']),
        vikritiSummary: _str(j['vikritiSummary']),
        lifestyleScore: _str(j['lifestyleScore']),
        ayushConfidence: _int(j['ayushConfidence']),
        drugInteractions: _strList(j['drugInteractions']),
        disclaimer: _str(j['disclaimer']),
      );
}


class DoctorTimeline {
  final String patientName;
  final String ageGenderAbha;
  final String priorityBadge;
  final List<String> categoriesFilter;
  final List<TimelineEventItem> events;
  final String disclaimer;

  const DoctorTimeline({
    this.patientName = '',
    this.ageGenderAbha = '',
    this.priorityBadge = '',
    this.categoriesFilter = const [],
    this.events = const [],
    this.disclaimer = '',
  });

  factory DoctorTimeline.fromJson(Map<String, dynamic> j) => DoctorTimeline(
        patientName: _str(j['patientName']),
        ageGenderAbha: _str(j['ageGenderAbha']),
        priorityBadge: _str(j['priorityBadge']),
        categoriesFilter: _strList(j['categoriesFilter']),
        events: (j['timelineEvents'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => TimelineEventItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        disclaimer: _str(j['disclaimer']),
      );
}

class TimelineEventItem {
  final String eventId;
  final String date;
  final String time;
  final String category;
  final String iconType;
  final String title;
  final String resultText;
  final String? highlightTag;
  final String? highlightValue;
  final String badgeColor;

  const TimelineEventItem({
    this.eventId = '',
    this.date = '',
    this.time = '',
    this.category = '',
    this.iconType = '',
    this.title = '',
    this.resultText = '',
    this.highlightTag,
    this.highlightValue,
    this.badgeColor = 'blue',
  });

  factory TimelineEventItem.fromJson(Map<String, dynamic> j) => TimelineEventItem(
        eventId: _str(j['eventId']),
        date: _str(j['date']),
        time: _str(j['time']),
        category: _str(j['category']),
        iconType: _str(j['iconType']),
        title: _str(j['title']),
        resultText: _str(j['resultText']),
        highlightTag: j['highlightTag']?.toString(),
        highlightValue: j['highlightValue']?.toString(),
        badgeColor: _str(j['badgeColor']).isEmpty ? 'blue' : _str(j['badgeColor']),
      );
}



class DoctorRedFlagAlert {
  final String alertLevel;
  final int aiConfidence;
  final Map<String, String> vitalSignsMini;
  final List<RedFlagItem> detectedFlags;
  final List<String> aiRiskAssessment;
  final String recommendedAction;
  final bool consentActive;

  const DoctorRedFlagAlert({
    this.alertLevel = 'NONE',
    this.aiConfidence = 0,
    this.vitalSignsMini = const {},
    this.detectedFlags = const [],
    this.aiRiskAssessment = const [],
    this.recommendedAction = '',
    this.consentActive = false,
  });

  bool get hasFlags => detectedFlags.isNotEmpty;
  bool get isCritical => alertLevel.toUpperCase() == 'CRITICAL' || detectedFlags.any((f) => f.severity.toUpperCase() == 'CRITICAL');
  List<RedFlagItem> get allAlerts => detectedFlags;
  List<RedFlagItem> get alerts => detectedFlags;

  factory DoctorRedFlagAlert.fromJson(Map<String, dynamic> j) {
    final rawFlags = (j['detectedFlags'] as List? ?? j['alerts'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => RedFlagItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final hasRed = j['hasRedFlags'] == true || rawFlags.isNotEmpty;
    final level = _str(j['alertLevel']).isNotEmpty
        ? _str(j['alertLevel'])
        : (hasRed ? (rawFlags.any((f) => f.severity.toUpperCase() == 'CRITICAL') ? 'CRITICAL' : 'HIGH') : 'NONE');

    return DoctorRedFlagAlert(
      alertLevel: level,
      aiConfidence: _int(j['aiConfidence']),
      vitalSignsMini: _strMap(j['vitalSignsMini']),
      detectedFlags: rawFlags,
      aiRiskAssessment: _strList(j['aiRiskAssessment']),
      recommendedAction: _str(j['recommendedAction']),
      consentActive: j['consentActive'] as bool? ?? false,
    );
  }

}

class RedFlagItem {
  final String alertId;
  final String symptom;
  final String description;
  final String severity;

  const RedFlagItem({
    this.alertId = '',
    this.symptom = '',
    this.description = '',
    this.severity = '',
  });

  String get ruleName => symptom;
  String get triggeredBy => description;

  factory RedFlagItem.fromJson(Map<String, dynamic> j) => RedFlagItem(
        alertId: _str(j['alertId']),
        symptom: _str(j['symptom']).isNotEmpty ? _str(j['symptom']) : _str(j['ruleName']),
        description: _str(j['description']).isNotEmpty ? _str(j['description']) : _str(j['triggeredBy']),
        severity: _str(j['severity']),
      );
}




class DoctorConfirmation {
  final String patientName;
  final String abhaId;
  final String tokenNumber;
  final bool aiSummaryVerified;
  final int modificationsCount;
  final String chiefComplaintSummary;
  final String ayushAssessmentSummary;
  final List<String> prescribedMedications;
  final List<String> drugInteractionWarnings;
  final List<String> icdCodesConfirmed;
  final List<String> allergies;

  const DoctorConfirmation({
    this.patientName = '',
    this.abhaId = '',
    this.tokenNumber = '',
    this.aiSummaryVerified = false,
    this.modificationsCount = 0,
    this.chiefComplaintSummary = '',
    this.ayushAssessmentSummary = '',
    this.prescribedMedications = const [],
    this.drugInteractionWarnings = const [],
    this.icdCodesConfirmed = const [],
    this.allergies = const [],
  });

  factory DoctorConfirmation.fromJson(Map<String, dynamic> j) => DoctorConfirmation(
        patientName: _str(j['patientName']),
        abhaId: _str(j['abhaId']),
        tokenNumber: _str(j['tokenNumber']),
        aiSummaryVerified: j['aiSummaryVerified'] as bool? ?? false,
        modificationsCount: _int(j['modificationsCount']),
        chiefComplaintSummary: _str(j['chiefComplaintSummary']),
        ayushAssessmentSummary: _str(j['ayushAssessmentSummary']),
        prescribedMedications: _strList(j['prescribedMedications']),
        drugInteractionWarnings: _strList(j['drugInteractionWarnings']),
        icdCodesConfirmed: _strList(j['icdCodesConfirmed']),
        allergies: _strList(j['allergies']),
      );
}


class DoctorConsultationNotes {
  final String sessionId;
  final String patientId;
  final String patientName;
  final String abhaId;
  final String tokenNumber;
  final String subjective;
  final String objective;
  final String assessment;
  final String plan;
  final List<String> suggestedIcd10Codes;
  final List<String> suggestedIcdTm2Codes;
  final List<String> currentMedications;
  final List<String> allergies;
  final List<String> drugInteractionWarnings;
  final int followUpDays;
  final String status;
  final String disclaimer;

  const DoctorConsultationNotes({
    this.sessionId = '',
    this.patientId = '',
    this.patientName = '',
    this.abhaId = '',
    this.tokenNumber = '',
    this.subjective = '',
    this.objective = '',
    this.assessment = '',
    this.plan = '',
    this.suggestedIcd10Codes = const [],
    this.suggestedIcdTm2Codes = const [],
    this.currentMedications = const [],
    this.allergies = const [],
    this.drugInteractionWarnings = const [],
    this.followUpDays = 0,
    this.status = 'DRAFT',
    this.disclaimer = '',
  });

  factory DoctorConsultationNotes.fromJson(Map<String, dynamic> j) => DoctorConsultationNotes(
        sessionId: _str(j['sessionId']),
        patientId: _str(j['patientId']),
        patientName: _str(j['patientName']),
        abhaId: _str(j['abhaId']),
        tokenNumber: _str(j['tokenNumber']),
        subjective: _str(j['subjective']),
        objective: _str(j['objective']),
        assessment: _str(j['assessment']),
        plan: _str(j['plan']),
        suggestedIcd10Codes: _strList(j['suggestedIcd10Codes']),
        suggestedIcdTm2Codes: _strList(j['suggestedIcdTm2Codes']),
        currentMedications: _strList(j['currentMedications']),
        allergies: _strList(j['allergies']),
        drugInteractionWarnings: _strList(j['drugInteractionWarnings']),
        followUpDays: _int(j['followUpDays']),
        status: _str(j['status']),
        disclaimer: _str(j['disclaimer']),
      );
}
