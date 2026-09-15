class ClinicalSummary {
  final String? id;
  final String? patientId;
  final String? soapNote;
  final String? aiGeneratedText;
  final List<String>? sourceTraceIds;
  final DateTime? generatedAt;
  final bool? physicianVerified;
  final String? physicianId;

  const ClinicalSummary({
    this.id,
    this.patientId,
    this.soapNote,
    this.aiGeneratedText,
    this.sourceTraceIds,
    this.generatedAt,
    this.physicianVerified,
    this.physicianId,
  });

  factory ClinicalSummary.fromJson(Map<String, dynamic> json) =>
      ClinicalSummary(
        id: json['id'] as String?,
        patientId: json['patientId'] as String?,
        soapNote: json['soapNote'] as String?,
        aiGeneratedText: json['aiGeneratedText'] as String?,
        sourceTraceIds: (json['sourceTraceIds'] as List?)?.cast<String>(),
        generatedAt: json['generatedAt'] != null
            ? DateTime.parse(json['generatedAt'] as String)
            : null,
        physicianVerified: json['physicianVerified'] as bool?,
        physicianId: json['physicianId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'soapNote': soapNote,
        'aiGeneratedText': aiGeneratedText,
        'sourceTraceIds': sourceTraceIds,
        'generatedAt': generatedAt?.toIso8601String(),
        'physicianVerified': physicianVerified,
        'physicianId': physicianId,
      };
}