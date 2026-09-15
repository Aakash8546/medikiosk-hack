









class AyushAssessmentRequest {
  final String sessionId;
  final int? vataScore;
  final int? pittaScore;
  final int? kaphaScore;
  final Map<String, String> prakritiAnswers;
  final Map<String, dynamic>? vikriti;
  final Map<String, String>? agniAnswers;
  final Map<String, dynamic>? aharaAnswers;
  final Map<String, String>? viharaAnswers;
  final Map<String, String>? dashavidhaAnswers;

  const AyushAssessmentRequest({
    required this.sessionId,
    this.vataScore,
    this.pittaScore,
    this.kaphaScore,
    required this.prakritiAnswers,
    this.vikriti,
    this.agniAnswers,
    this.aharaAnswers,
    this.viharaAnswers,
    this.dashavidhaAnswers,
  });

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        if (vataScore != null) 'vataScore': vataScore,
        if (pittaScore != null) 'pittaScore': pittaScore,
        if (kaphaScore != null) 'kaphaScore': kaphaScore,
        'prakritiAnswers': prakritiAnswers,
        if (vikriti != null) 'vikriti': vikriti,
        if (agniAnswers != null) 'agniAnswers': agniAnswers,
        if (aharaAnswers != null) 'aharaAnswers': aharaAnswers,
        if (viharaAnswers != null) 'viharaAnswers': viharaAnswers,
        if (dashavidhaAnswers != null) 'dashavidhaAnswers': dashavidhaAnswers,
      };

  
  static const int questionsPerStep = 3;

  
  static const Map<int, List<String>> _prakritiOptionLabels = {
    1: ['thin', 'medium', 'large'],
    2: ['dry', 'normal', 'oily'],
    3: ['moderate', 'low', 'high'],
    4: ['irregular', 'strong', 'slow'],
    5: ['variable', 'high', 'low'],
    6: ['cold hands', 'warm body', 'balanced'],
    7: ['light', 'moderate', 'deep'],
    8: ['active', 'moderate', 'low'],
    9: ['minimal', 'moderate', 'excessive'],
    10: ['quick learn', 'sharp', 'slow steady'],
    11: ['anxious', 'irritable', 'calm'],
    12: ['adaptable', 'outgoing', 'reserved'],
    13: ['dry & frizzy', 'fine & oily', 'thick & wavy'],
    14: ['small & dry', 'sharp & bright', 'large & calm'],
    15: ['narrow', 'medium', 'round'],
    16: ['fast & talkative', 'clear & direct', 'soft & steady'],
    17: ['variety', 'spicy & salty', 'sweet & mild'],
    18: ['warm', 'cool', 'any'],
    19: ['irregular', 'regular', 'loose'],
    20: ['low', 'medium', 'high'],
    21: ['hard gain', 'stable', 'easy gain'],
    22: ['variable', 'high', 'steady'],
    23: ['cold & windy', 'hot & humid', 'all climate'],
    24: ['vata', 'pitta', 'kapha'],
  };

  
  static const Map<String, String> _defaultPrakritiAnswers = {
    "q1": "thin",
    "q2": "dry",
    "q3": "high",
    "q4": "strong",
    "q5": "high",
    "q6": "warm body",
    "q7": "light",
    "q8": "active",
    "q9": "moderate",
    "q10": "sharp",
    "q11": "irritable",
    "q12": "outgoing",
    "q13": "fine & oily",
    "q14": "sharp & bright",
    "q15": "medium",
    "q16": "fast & talkative",
    "q17": "spicy & salty",
    "q18": "cool",
    "q19": "regular",
    "q20": "medium",
    "q21": "stable",
    "q22": "high",
    "q23": "hot & humid",
    "q24": "pitta",
  };

  
  static Map<String, String> buildPrakritiAnswersMap(Map<int, Map<int, int>> rawAnswers) {
    final Map<String, String> answers = Map.from(_defaultPrakritiAnswers);

    for (final stepEntry in rawAnswers.entries) {
      final step = stepEntry.key;
      for (final qEntry in stepEntry.value.entries) {
        final questionIndex = qEntry.key;
        final optionIndex = qEntry.value;
        final qNum = step * questionsPerStep + questionIndex + 1;
        final questionKey = 'q$qNum';

        final labels = _prakritiOptionLabels[qNum];
        if (labels != null && optionIndex >= 0 && optionIndex < labels.length) {
          answers[questionKey] = labels[optionIndex];
        }
      }
    }

    return answers;
  }

  
  static AyushAssessmentRequest fromPrakritiAnswers({
    required String sessionId,
    required Map<int, Map<int, int>> rawAnswers,
    Map<String, dynamic>? vikriti,
    Map<String, String>? agniAnswers,
    Map<String, dynamic>? aharaAnswers,
    Map<String, String>? viharaAnswers,
    Map<String, String>? dashavidhaAnswers,
  }) {
    int vata = 0;
    int pitta = 0;
    int kapha = 0;

    for (final stepEntry in rawAnswers.entries) {
      for (final qEntry in stepEntry.value.entries) {
        switch (qEntry.value) {
          case 0:
            vata++;
            break;
          case 1:
            pitta++;
            break;
          case 2:
            kapha++;
            break;
        }
      }
    }

    final answersMap = buildPrakritiAnswersMap(rawAnswers);

    return AyushAssessmentRequest(
      sessionId: sessionId,
      vataScore: vata,
      pittaScore: pitta,
      kaphaScore: kapha,
      prakritiAnswers: answersMap,
      vikriti: vikriti,
      agniAnswers: agniAnswers,
      aharaAnswers: aharaAnswers,
      viharaAnswers: viharaAnswers,
      dashavidhaAnswers: dashavidhaAnswers,
    );
  }
}
