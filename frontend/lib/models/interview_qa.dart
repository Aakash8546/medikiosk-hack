class InterviewQA {
  final String id;
  final String questionText;
  final String? questionTextHi;
  final String? answer;
  final String inputMode; 
  final DateTime? answeredAt;
  final double? confidence;

  const InterviewQA({
    required this.id,
    required this.questionText,
    this.questionTextHi,
    this.answer,
    this.inputMode = 'tap',
    this.answeredAt,
    this.confidence,
  });

  factory InterviewQA.fromJson(Map<String, dynamic> json) => InterviewQA(
        id: json['id'] as String,
        questionText: json['questionText'] as String,
        questionTextHi: json['questionTextHi'] as String?,
        answer: json['answer'] as String?,
        inputMode: json['inputMode'] as String? ?? 'tap',
        answeredAt: json['answeredAt'] != null
            ? DateTime.parse(json['answeredAt'] as String)
            : null,
        confidence: (json['confidence'] as num?)?.toDouble(),
          );

  InterviewQA copyWith({
    String? answer,
    String? inputMode,
    DateTime? answeredAt,
    double? confidence,
  }) =>
      InterviewQA(
        id: id,
        questionText: questionText,
        questionTextHi: questionTextHi,
        answer: answer ?? this.answer,
        inputMode: inputMode ?? this.inputMode,
        answeredAt: answeredAt ?? this.answeredAt,
        confidence: confidence ?? this.confidence,
      );
}