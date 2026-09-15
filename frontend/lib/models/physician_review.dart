class PhysicianReview {
  final String? id;
  final String? physicianId;
  final String? summaryId;
  final String? status; 
  final String? notes;
  final DateTime? reviewedAt;
  final int? timeSavedMinutes;

  const PhysicianReview({
    this.id,
    this.physicianId,
    this.summaryId,
    this.status,
    this.notes,
    this.reviewedAt,
    this.timeSavedMinutes,
  });

  factory PhysicianReview.fromJson(Map<String, dynamic> json) =>
      PhysicianReview(
        id: json['id'] as String?,
        physicianId: json['physicianId'] as String?,
        summaryId: json['summaryId'] as String?,
        status: json['status'] as String?,
        notes: json['notes'] as String?,
        reviewedAt: json['reviewedAt'] != null
            ? DateTime.parse(json['reviewedAt'] as String)
            : null,
        timeSavedMinutes: json['timeSavedMinutes'] as int?,
      );
}