
class InterviewResponse {
  final String? sessionId;
  final String status; 
  final String? questionText;
  final String? questionAudioBase64;
  final List<String> quickReplies;
  final String? transcribedAnswer;
  final String? message;
  final List<String> redFlags;
  final String? finalSummary;
  final Map<String, dynamic>? structuredHistory;

  InterviewResponse({
    this.sessionId,
    required this.status,
    this.questionText,
    this.questionAudioBase64,
    this.quickReplies = const [],
    this.transcribedAnswer,
    this.message,
    this.redFlags = const [],
    this.finalSummary,
    this.structuredHistory,
  });

  factory InterviewResponse.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(dynamic list) {
      if (list is List) {
        return list.map((e) => e.toString()).toList();
      }
      return [];
    }

    String? parseString(dynamic val) {
      if (val == null) return null;
      if (val is String) return val;
      return val.toString();
    }

    return InterviewResponse(
      sessionId: parseString(json['session_id'] ?? json['sessionId']),
      status: parseString(json['status']) ?? 'in_progress',
      questionText: parseString(json['question_text'] ?? json['questionText']),
      questionAudioBase64: parseString(json['question_audio_base64'] ?? json['questionAudioBase64']),
      quickReplies: parseStringList(json['quick_replies'] ?? json['quickReplies']),
      transcribedAnswer: parseString(json['transcribed_answer'] ?? json['transcribedAnswer']),
      message: parseString(json['message']),
      redFlags: parseStringList(json['red_flags'] ?? json['redFlags']),
      finalSummary: parseString(json['final_summary'] ?? json['finalSummary']),
      structuredHistory: json['structured_history'] is Map<String, dynamic>
          ? json['structured_history'] as Map<String, dynamic>
          : (json['structuredHistory'] is Map<String, dynamic>
              ? json['structuredHistory'] as Map<String, dynamic>
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'status': status,
      'question_text': questionText,
      'question_audio_base64': questionAudioBase64,
      'quick_replies': quickReplies,
      'transcribed_answer': transcribedAnswer,
      'message': message,
      'red_flags': redFlags,
      'final_summary': finalSummary,
      'structured_history': structuredHistory,
    };
  }
}