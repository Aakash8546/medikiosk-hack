



































class AyushReportResponse {
  final String? id;
  final String? sessionId;

  
  final int vataScore;
  final int pittaScore;
  final int kaphaScore;
  final double vataPercentage;
  final double pittaPercentage;
  final double kaphaPercentage;
  final String prakritiResult;
  final String prakritiDescription;

  
  final int agniScore;
  final double agniGauge;
  final String agniType;

  
  final int lifestyleScore;
  final String lifestyleBadge;
  final List<String> tastePreference;
  final String waterIntake;

  
  final VikritiSummary vikritiSummary;

  
  final DashavidhaDetails? dashavidhaDetails;

  
  final List<String>? _doctorsQuickView;
  final List<String>? _suggestedFocusAreas;
  final List<String> dietRecommendations;
  final List<String> lifestyleRecommendations;
  final List<String> recommendedYoga;

  
  final int completenessScore;
  final bool isFinalized;

  const AyushReportResponse({
    this.id,
    this.sessionId,
    this.vataScore = 0,
    this.pittaScore = 0,
    this.kaphaScore = 0,
    this.vataPercentage = 0,
    this.pittaPercentage = 0,
    this.kaphaPercentage = 0,
    this.prakritiResult = 'UNKNOWN',
    this.prakritiDescription = '',
    this.agniScore = 0,
    this.agniGauge = 0,
    this.agniType = '',
    this.lifestyleScore = 0,
    this.lifestyleBadge = '',
    this.tastePreference = const [],
    this.waterIntake = '',
    required this.vikritiSummary,
    this.dashavidhaDetails,
    List<String>? doctorsQuickView,
    List<String>? suggestedFocusAreas,
    this.dietRecommendations = const [],
    this.lifestyleRecommendations = const [],
    this.recommendedYoga = const [],
    this.completenessScore = 0,
    this.isFinalized = false,
  })  : _doctorsQuickView = doctorsQuickView,
        _suggestedFocusAreas = suggestedFocusAreas;

  
  String? get pdfUrl =>
      sessionId != null ? '/ayush/session/$sessionId/pdf' : null;

  
  String get agniDescription {
    switch (agniType.toUpperCase()) {
      case 'MANDAGNI':
        return 'Your digestive fire is low. Warm, light foods recommended.';
      case 'TIKSHNAGNI':
        return 'Your digestive fire is high. Cooling, balanced foods recommended.';
      case 'MADHYAMA_AGNI':
      case 'MADHYAMA':
        return 'Your digestive fire is moderate and balanced.';
      default:
        return 'Digestive assessment completed.';
    }
  }

  
  String get lifestyleDescription {
    switch (lifestyleBadge.toLowerCase()) {
      case 'excellent':
        return 'You follow healthy lifestyle habits.';
      case 'good':
        return 'Your lifestyle habits are mostly healthy.';
      case 'fair':
        return 'Some lifestyle improvements are recommended.';
      default:
        return 'Lifestyle assessment completed.';
    }
  }

  
  String get vikritiDoshasSummary => vikritiSummary.doshas.join(', ');

  
  String get vikritiDescription {
    if (vikritiSummary.symptoms.isEmpty) return '';
    return 'Mild imbalance observed: ${vikritiSummary.symptoms.join(", ")}.';
  }

  
  String get hydrationDescription {
    switch (waterIntake.toLowerCase()) {
      case 'adequate':
        return 'You maintain good water intake.';
      case 'low':
        return 'Increase your daily water intake.';
      case 'high':
        return 'You drink more water than usual.';
      default:
        return 'Hydration assessment completed.';
    }
  }

  
  List<String> get doctorsQuickView {
    final docs = _doctorsQuickView;
    if (docs != null && docs.isNotEmpty) {
      return docs;
    }
    final List<String> points = [];
    if (pittaScore > vataScore && pittaScore > kaphaScore) {
      points.add('Pitta dominance with strong metabolic activity');
    } else if (vataScore > pittaScore && vataScore > kaphaScore) {
      points.add('Vata dominance with variable energy patterns');
    } else {
      points.add('Kapha dominance with steady constitution');
    }
    if (agniScore <= 3) {
      points.add('Weak digestive fire — recommend warming foods');
    } else if (agniScore >= 7) {
      points.add('Strong digestive fire — good metabolic capacity');
    } else {
      points.add('Metabolic strength is moderate');
    }
    if (vikritiSummary.severity == 'moderate' || vikritiSummary.severity == 'severe') {
      points.add('Watch for ${vikritiSummary.symptoms.join(" and ")} related issues');
    }
    points.add('Recommend cooling, grounding and nourishing practices');
    return points;
  }

  
  List<String> get suggestedFocusAreas {
    final focus = _suggestedFocusAreas;
    if (focus != null && focus.isNotEmpty) {
      return focus;
    }
    final List<String> areas = ['Cooling & calming diet', 'Regular routine & hydration'];
    if (vikritiSummary.severity != 'mild') {
      areas.add('Stress management');
    }
    areas.add('Adequate sleep');
    return areas;
  }

  factory AyushReportResponse.fromJson(Map<String, dynamic> json) {
    final vikritiSummaryJson = json['vikritiSummary'] as Map<String, dynamic>? ?? {};
    final dashavidhaJson = json['dashavidhaDetails'] as Map<String, dynamic>?;

    return AyushReportResponse(
      id: json['id'] as String?,
      sessionId: json['sessionId'] as String?,
      vataScore: json['vataScore'] as int? ?? 0,
      pittaScore: json['pittaScore'] as int? ?? 0,
      kaphaScore: json['kaphaScore'] as int? ?? 0,
      vataPercentage: (json['vataPercentage'] as num?)?.toDouble() ?? 0,
      pittaPercentage: (json['pittaPercentage'] as num?)?.toDouble() ?? 0,
      kaphaPercentage: (json['kaphaPercentage'] as num?)?.toDouble() ?? 0,
      prakritiResult: json['prakritiResult'] as String? ?? 'UNKNOWN',
      prakritiDescription: json['prakritiDescription'] as String? ?? '',
      agniScore: json['agniScore'] as int? ?? 0,
      agniGauge: (json['agniGauge'] as num?)?.toDouble() ?? 0,
      agniType: json['agniType'] as String? ?? '',
      lifestyleScore: json['lifestyleScore'] as int? ?? 0,
      lifestyleBadge: json['lifestyleBadge'] as String? ?? '',
      tastePreference: (json['tastePreference'] as List?)?.cast<String>() ?? [],
      waterIntake: json['waterIntake'] as String? ?? '',
      vikritiSummary: VikritiSummary.fromJson(vikritiSummaryJson),
      dashavidhaDetails: dashavidhaJson != null ? DashavidhaDetails.fromJson(dashavidhaJson) : null,
      doctorsQuickView: (json['doctorsQuickView'] as List?)?.cast<String>(),
      suggestedFocusAreas: (json['suggestedFocusAreas'] as List?)?.cast<String>(),
      dietRecommendations: (json['dietRecommendations'] as List?)?.cast<String>() ?? [],
      lifestyleRecommendations: (json['lifestyleRecommendations'] as List?)?.cast<String>() ?? [],
      recommendedYoga: (json['recommendedYoga'] as List?)?.cast<String>() ?? [],
      completenessScore: json['completenessScore'] as int? ?? 0,
      isFinalized: json['isFinalized'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sessionId': sessionId,
        'vataScore': vataScore,
        'pittaScore': pittaScore,
        'kaphaScore': kaphaScore,
        'vataPercentage': vataPercentage,
        'pittaPercentage': pittaPercentage,
        'kaphaPercentage': kaphaPercentage,
        'prakritiResult': prakritiResult,
        'prakritiDescription': prakritiDescription,
        'agniScore': agniScore,
        'agniGauge': agniGauge,
        'agniType': agniType,
        'lifestyleScore': lifestyleScore,
        'lifestyleBadge': lifestyleBadge,
        'tastePreference': tastePreference,
        'waterIntake': waterIntake,
        'vikritiSummary': vikritiSummary.toJson(),
        'dashavidhaDetails': dashavidhaDetails?.toJson(),
        'doctorsQuickView': doctorsQuickView,
        'suggestedFocusAreas': suggestedFocusAreas,
        'dietRecommendations': dietRecommendations,
        'lifestyleRecommendations': lifestyleRecommendations,
        'recommendedYoga': recommendedYoga,
        'completenessScore': completenessScore,
        'isFinalized': isFinalized,
      };
}

class VikritiSummary {
  final List<String> doshas;
  final List<String> symptoms;
  final String severity;
  final String duration;

  const VikritiSummary({
    this.doshas = const [],
    this.symptoms = const [],
    this.severity = '',
    this.duration = '',
  });

  factory VikritiSummary.fromJson(Map<String, dynamic> json) => VikritiSummary(
        doshas: (json['doshas'] as List?)?.cast<String>() ?? [],
        symptoms: (json['symptoms'] as List?)?.cast<String>() ?? [],
        severity: json['severity'] as String? ?? '',
        duration: json['duration'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'doshas': doshas,
        'symptoms': symptoms,
        'severity': severity,
        'duration': duration,
      };
}

class DashavidhaDetails {
  final DashavidhaItem? sara;
  final DashavidhaItem? samhanana;
  final DashavidhaItem? pramana;
  final DashavidhaItem? satmya;
  final DashavidhaItem? satva;
  final AharaShakti? aharaShakti;
  final DashavidhaItem? vyayama;
  final VayaItem? vaya;

  const DashavidhaDetails({
    this.sara,
    this.samhanana,
    this.pramana,
    this.satmya,
    this.satva,
    this.aharaShakti,
    this.vyayama,
    this.vaya,
  });

  factory DashavidhaDetails.fromJson(Map<String, dynamic> json) => DashavidhaDetails(
        sara: json['sara'] != null ? DashavidhaItem.fromJson(json['sara']) : null,
        samhanana: json['samhanana'] != null ? DashavidhaItem.fromJson(json['samhanana']) : null,
        pramana: json['pramana'] != null ? DashavidhaItem.fromJson(json['pramana']) : null,
        satmya: json['satmya'] != null ? DashavidhaItem.fromJson(json['satmya']) : null,
        satva: json['satva'] != null ? DashavidhaItem.fromJson(json['satva']) : null,
        aharaShakti: json['aharaShakti'] != null ? AharaShakti.fromJson(json['aharaShakti']) : null,
        vyayama: json['vyayama'] != null ? DashavidhaItem.fromJson(json['vyayama']) : null,
        vaya: json['vaya'] != null ? VayaItem.fromJson(json['vaya']) : null,
      );

  Map<String, dynamic> toJson() => {
        'sara': sara?.toJson(),
        'samhanana': samhanana?.toJson(),
        'pramana': pramana?.toJson(),
        'satmya': satmya?.toJson(),
        'satva': satva?.toJson(),
        'aharaShakti': aharaShakti?.toJson(),
        'vyayama': vyayama?.toJson(),
        'vaya': vaya?.toJson(),
      };
}

class DashavidhaItem {
  final String grade;
  final int score;
  final double percentage;

  const DashavidhaItem({this.grade = '', this.score = 0, this.percentage = 0});

  factory DashavidhaItem.fromJson(Map<String, dynamic> json) => DashavidhaItem(
        grade: json['grade'] as String? ?? '',
        score: json['score'] as int? ?? 0,
        percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {'grade': grade, 'score': score, 'percentage': percentage};
}

class AharaShakti {
  final String abhyavaharana;
  final String jarana;
  final double score;
  final double percentage;

  const AharaShakti({this.abhyavaharana = '', this.jarana = '', this.score = 0, this.percentage = 0});

  factory AharaShakti.fromJson(Map<String, dynamic> json) => AharaShakti(
        abhyavaharana: json['abhyavaharana'] as String? ?? '',
        jarana: json['jarana'] as String? ?? '',
        score: (json['score'] as num?)?.toDouble() ?? 0,
        percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'abhyavaharana': abhyavaharana,
        'jarana': jarana,
        'score': score,
        'percentage': percentage,
      };
}

class VayaItem {
  final String category;
  final String description;

  const VayaItem({this.category = '', this.description = ''});

  factory VayaItem.fromJson(Map<String, dynamic> json) => VayaItem(
        category: json['category'] as String? ?? '',
        description: json['description'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'category': category, 'description': description};
}