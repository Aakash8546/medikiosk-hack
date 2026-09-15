class ClinicalHistory {
  final String? chiefComplaint;
  final String? hpi;
  final String? pastMedicalHistory;
  final String? medications;
  final String? allergies;
  final String? familyHistory;
  final String? personalHistory;
  final String? reviewOfSystems;
  final String? priorInvestigations;

  const ClinicalHistory({
    this.chiefComplaint,
    this.hpi,
    this.pastMedicalHistory,
    this.medications,
    this.allergies,
    this.familyHistory,
    this.personalHistory,
    this.reviewOfSystems,
    this.priorInvestigations,
  });

  factory ClinicalHistory.fromJson(Map<String, dynamic> json) =>
      ClinicalHistory(
        chiefComplaint: json['chiefComplaint'] as String?,
        hpi: json['hpi'] as String?,
        pastMedicalHistory: json['pastMedicalHistory'] as String?,
        medications: json['medications'] as String?,
        allergies: json['allergies'] as String?,
        familyHistory: json['familyHistory'] as String?,
        personalHistory: json['personalHistory'] as String?,
        reviewOfSystems: json['reviewOfSystems'] as String?,
        priorInvestigations: json['priorInvestigations'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'chiefComplaint': chiefComplaint,
        'hpi': hpi,
        'pastMedicalHistory': pastMedicalHistory,
        'medications': medications,
        'allergies': allergies,
        'familyHistory': familyHistory,
        'personalHistory': personalHistory,
        'reviewOfSystems': reviewOfSystems,
        'priorInvestigations': priorInvestigations,
      };
}