class ExtractedEntity {
  final String label;
  final String value;
  final double confidence;
  final bool isVerified;
  final String? source; 

  const ExtractedEntity({
    required this.label,
    required this.value,
    required this.confidence,
    this.isVerified = false,
    this.source,
  });

  ExtractedEntity copyWith({
    String? value,
    bool? isVerified,
    double? confidence,
  }) =>
      ExtractedEntity(
        label: label,
        value: value ?? this.value,
        confidence: confidence ?? this.confidence,
        isVerified: isVerified ?? this.isVerified,
        source: source,
      );

  factory ExtractedEntity.fromJson(Map<String, dynamic> json) =>
      ExtractedEntity(
        label: json['label'] as String,
        value: json['value'] as String,
        confidence: (json['confidence'] as num).toDouble(),
        isVerified: json['isVerified'] as bool? ?? false,
        source: json['source'] as String?,
      );
}