class TimelineEvent {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final String type; 

  const TimelineEvent({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    required this.type,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) => TimelineEvent(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        date: DateTime.parse(json['date'] as String),
        type: json['type'] as String,
      );
}