class FhirBundle {
  final String? resourceType;
  final String? id;
  final String? type;
  final List<Map<String, dynamic>>? entries;

  const FhirBundle({this.resourceType, this.id, this.type, this.entries});

  factory FhirBundle.fromJson(Map<String, dynamic> json) => FhirBundle(
        resourceType: json['resourceType'] as String?,
        id: json['id'] as String?,
        type: json['type'] as String?,
        entries: (json['entry'] as List?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'resourceType': resourceType,
        'id': id,
        'type': type,
        'entry': entries,
      };
}