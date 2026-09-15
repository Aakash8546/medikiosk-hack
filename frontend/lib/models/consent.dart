class Consent {
  final String? id;
  final String? patientId;
  final bool granted;
  final String? consentType;
  final DateTime? grantedAt;
  final DateTime? expiresAt;
  final bool? audioPlayed;

  const Consent({
    this.id,
    this.patientId,
    this.granted = false,
    this.consentType,
    this.grantedAt,
    this.expiresAt,
    this.audioPlayed,
  });

  factory Consent.fromJson(Map<String, dynamic> json) => Consent(
        id: json['id'] as String?,
        patientId: json['patientId'] as String?,
        granted: json['granted'] as bool? ?? false,
        consentType: json['consentType'] as String?,
        grantedAt: json['grantedAt'] != null
            ? DateTime.parse(json['grantedAt'] as String)
            : null,
        expiresAt: json['expiresAt'] != null
            ? DateTime.parse(json['expiresAt'] as String)
            : null,
        audioPlayed: json['audioPlayed'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'granted': granted,
        'consentType': consentType,
        'grantedAt': grantedAt?.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
        'audioPlayed': audioPlayed,
      };
}