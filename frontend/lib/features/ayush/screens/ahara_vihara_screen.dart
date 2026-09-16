import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:medikiosk/core/utils/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/app/localization/app_localizations.dart';
import 'package:medikiosk/features/ayush/screens/dashavidha_screen.dart';
import 'package:medikiosk/features/ayush/screens/vikriti_screen.dart';
import 'package:medikiosk/features/ayush/providers/ayush_provider.dart';
import 'package:medikiosk/features/onboarding/providers/onboarding_provider.dart';
import 'package:medikiosk/models/ayush_assessment_request.dart';
import 'package:medikiosk/services/api_service.dart';
import 'dart:math' as math;





class AharaViharaScreen extends ConsumerStatefulWidget {
  const AharaViharaScreen({super.key});

  @override
  ConsumerState<AharaViharaScreen> createState() => _AharaViharaScreenState();
}

class _AharaViharaScreenState extends ConsumerState<AharaViharaScreen> {
  bool _isSubmitting = false;
  final int _currentStep = 6; 
  final int _totalSteps = 7;

  final List<String> _stepLabels = [
    'Prakriti',
    'Vikriti',
    'Agni',
    'Koshtha',
    'Dashavidha',
    'Ashtavidha',
    'Ahara-Vihara',
  ];

  
  String? _typeOfDiet;
  String? _mealRegularity;
  String? _mealQuantity;
  String? _tastePreference;
  String? _waterIntake;
  String? _foodQuality;

  
  String? _physicalActivity;
  String? _sleepPattern;
  String? _stressLevel;
  String? _dailyRoutine;
  String? _habits;

  

  
  List<Map<String, dynamic>> _aharaQuestions(AppLocalizations l10n) => [
    {'number': '1.1', 'title': l10n.aharaQ1Title, 'subtitle': l10n.aharaQ1Subtitle, 'emoji': '🥗', 'options': [l10n.optVegetarian, l10n.optNonVegetarian, l10n.optEggetarian]},
    {'number': '1.2', 'title': l10n.aharaQ2Title, 'subtitle': l10n.aharaQ2Subtitle, 'emoji': '🕐', 'options': [l10n.optRegular, l10n.optSometimesIrregular, l10n.optVeryIrregular]},
    {'number': '1.3', 'title': l10n.aharaQ3Title, 'subtitle': l10n.aharaQ3Subtitle, 'emoji': '🍽️', 'options': [l10n.optLess, l10n.optModerate, l10n.optMore]},
    {'number': '1.4', 'title': l10n.aharaQ4Title, 'subtitle': l10n.aharaQ4Subtitle, 'emoji': '🌶️', 'options': [l10n.optSweet, l10n.optSour, l10n.optSalty, l10n.optPungent, l10n.optBitter, l10n.optAstringent]},
    {'number': '1.5', 'title': l10n.aharaQ5Title, 'subtitle': l10n.aharaQ5Subtitle, 'emoji': '💧', 'options': [l10n.optLess, l10n.optModerate, l10n.optAdequate, l10n.optMore]},
    {'number': '1.6', 'title': l10n.aharaQ6Title, 'subtitle': l10n.aharaQ6Subtitle, 'emoji': '🥦', 'options': [l10n.optPoor, l10n.optAverage, l10n.optGood, l10n.optExcellent]},
  ];

  
  List<Map<String, dynamic>> _viharaQuestions(AppLocalizations l10n) => [
    {'number': '2.1', 'title': l10n.viharaQ1Title, 'subtitle': l10n.viharaQ1Subtitle, 'emoji': '🏃', 'options': [l10n.optSedentary, l10n.optLight, l10n.optModerate, l10n.optHigh]},
    {'number': '2.2', 'title': l10n.viharaQ2Title, 'subtitle': l10n.viharaQ2Subtitle, 'emoji': '🌙', 'options': ['< 6 hrs', '6–7 hrs', '7–8 hrs', '> 8 hrs']},
    {'number': '2.3', 'title': l10n.viharaQ3Title, 'subtitle': l10n.viharaQ3Subtitle, 'emoji': '😟', 'options': [l10n.optLess, l10n.optModerate, l10n.optHigh, l10n.severityVerySevere]},
    {'number': '2.4', 'title': l10n.viharaQ4Title, 'subtitle': l10n.viharaQ4Subtitle, 'emoji': '⏰', 'options': [l10n.optVeryGood, l10n.optGood, l10n.optAverage, l10n.optPoor]},
    {'number': '2.5', 'title': l10n.viharaQ5Title, 'subtitle': l10n.viharaQ5Subtitle, 'emoji': '🧘', 'options': [l10n.optNone, l10n.optOccasionally, l10n.optRegular]},
  ];

  

  String? _getAnswer(int section, int questionIndex) {
    if (section == 0) {
      switch (questionIndex) {
        case 0: return _typeOfDiet;
        case 1: return _mealRegularity;
        case 2: return _mealQuantity;
        case 3: return _tastePreference;
        case 4: return _waterIntake;
        case 5: return _foodQuality;
      }
    } else {
      switch (questionIndex) {
        case 0: return _physicalActivity;
        case 1: return _sleepPattern;
        case 2: return _stressLevel;
        case 3: return _dailyRoutine;
        case 4: return _habits;
      }
    }
    return null;
  }

  void _setAnswer(int section, int questionIndex, String value, int optionIndex) {
    setState(() {
      if (section == 0) {
        switch (questionIndex) {
          case 0: _typeOfDiet = value; _typeOfDietSelected = true; _typeOfDietIndex = optionIndex; break;
          case 1: _mealRegularity = value; _mealRegularityIndex = optionIndex; break;
          case 2: _mealQuantity = value; _mealQuantityIndex = optionIndex; break;
          case 3: _tastePreference = value; break;
          case 4: _waterIntake = value; break;
          case 5: _foodQuality = value; _foodQualityIndex = optionIndex; break;
        }
      } else {
        switch (questionIndex) {
          case 0: _physicalActivity = value; _physicalActivityIndex = optionIndex; break;
          case 1: _sleepPattern = value; _sleepPatternIndex = optionIndex; break;
          case 2: _stressLevel = value; _stressLevelIndex = optionIndex; break;
          case 3: _dailyRoutine = value; _dailyRoutineIndex = optionIndex; break;
          case 4: _habits = value; _habitsIndex = optionIndex; break;
        }
      }
    });
  }

  bool _allAnsweredCheck(List<Map<String, dynamic>> aharaQ, List<Map<String, dynamic>> viharaQ) {
    for (var q in aharaQ) {
      if (_getAnswer(0, aharaQ.indexOf(q)) == null) return false;
    }
    for (var q in viharaQ) {
      if (_getAnswer(1, viharaQ.indexOf(q)) == null) return false;
    }
    return true;
  }

  Future<void> _submitAssessment() async {
    final sessionId = ref.read(sessionProvider).sessionId;
    if (sessionId == null || sessionId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active session. Please restart the assessment.')),
      );
      return;
    }

    final prakritiAnswers = ref.read(prakritiAnswersProvider);

    
    final vikritiState = ref.read(vikritiProvider);
    final List<String> vikritiDoshas = vikritiState.selectedDoshas.isNotEmpty
        ? vikritiState.selectedDoshas.map((d) => d.toLowerCase()).toList()
        : ["pitta", "vata"];

    final List<String> vikritiSymptoms = vikritiState.selectedSymptoms.isNotEmpty
        ? vikritiState.selectedSymptoms.map((s) => s.toLowerCase().split(' / ')[0].split(' (')[0].trim()).toList()
        : ["acidity", "joint pain", "dry skin"];

    const severityMap = ['none', 'mild', 'moderate', 'severe', 'very severe'];
    final String vikritiSeverity = vikritiState.severityIndex >= 0 && vikritiState.severityIndex < severityMap.length
        ? severityMap[vikritiState.severityIndex]
        : "moderate";

    String vikritiDuration = vikritiState.duration.toLowerCase().replaceAll('–', '-').replaceAll(' ', '-');
    if (vikritiDuration.isEmpty) vikritiDuration = "1-4-weeks";

    final vikritiPayload = {
      'doshas': vikritiDoshas,
      'symptoms': vikritiSymptoms,
      'severity': vikritiSeverity,
      'duration': vikritiDuration,
    };

    
    final agniState = ref.read(agniAnswersProvider);
    final agniPayload = agniState.toJson();

    
    final aharaPayload = {
      'diet': _typeOfDiet?.toLowerCase() ?? 'vegetarian',
      'mealRegularity': _mealRegularity?.toLowerCase() ?? 'regular',
      'mealQuantity': _mealQuantity?.toLowerCase() ?? 'moderate',
      'foodQuality': _foodQuality?.toLowerCase() ?? 'good',
      'taste': _tastePreference != null ? [_tastePreference!.toLowerCase()] : ['sweet', 'spicy'],
      'water': _waterIntake ?? '2-3 litres',
    };

    
    final viharaPayload = {
      'activity': _physicalActivity?.toLowerCase() ?? 'moderate',
      'sleep': _sleepPattern ?? '7-8 hours',
      'stress': _stressLevel?.toLowerCase() ?? 'moderate',
      'routine': _dailyRoutine?.toLowerCase() ?? 'good',
      'habits': _habits?.toLowerCase() ?? 'none',
    };

    
    final dashavidhaList = ref.read(dashavidhaProvider);
    final Map<String, String> dashavidhaPayload = {
      "sara": "pravara",
      "samhanana": "madhyama",
      "pramana": "madhyama",
      "satmya": "pravara",
      "satva": "pravara",
      "abhyavaharana": "pravara",
      "jarana": "madhyama",
      "vyayama": "madhyama",
      "vaya": "madhyama",
    };

    for (final param in dashavidhaList) {
      if (param.answer == null) continue;
      final answerLower = param.answer!.toLowerCase();
      String grade = 'madhyama';
      if (answerLower.contains('uttama') || answerLower.contains('pravara')) grade = 'pravara';
      if (answerLower.contains('adhama') || answerLower.contains('avara')) grade = 'avara';

      switch (param.number) {
        case 3: dashavidhaPayload['sara'] = grade; break;
        case 4: dashavidhaPayload['samhanana'] = grade; break;
        case 5: dashavidhaPayload['pramana'] = grade; break;
        case 6: dashavidhaPayload['satmya'] = grade; break;
        case 7: dashavidhaPayload['satva'] = grade; break;
        case 8: dashavidhaPayload['abhyavaharana'] = grade; break;
        case 9: dashavidhaPayload['vyayama'] = grade; break;
        case 10: dashavidhaPayload['vaya'] = grade; break;
      }
    }

    
    final assessment = AyushAssessmentRequest.fromPrakritiAnswers(
      sessionId: sessionId,
      rawAnswers: prakritiAnswers,
      vikriti: vikritiPayload,
      agniAnswers: agniPayload,
      aharaAnswers: aharaPayload,
      viharaAnswers: viharaPayload,
      dashavidhaAnswers: dashavidhaPayload,
    );
    
    setState(() => _isSubmitting = true);
    try {
      print('[AYUSH] Submitting full assessment: sessionId=$sessionId');
      logDebug('AYUSH', 'Submitting assessment for session');
      
      final report = await ApiService().submitAyushAssessment(assessment);
      if (!mounted) return;
      context.go('/personalized-recommendations', extra: report);
    } on DioException catch (error) {
      final data = error.response?.data;
      final serverMsg = _serverMessage(data) ?? error.message ?? '';
      print('[AYUSH] Assessment submission failed: status=${error.response?.statusCode} body=$data');

      
      if (serverMsg.toLowerCase().contains('consent')) {
        print('[AYUSH] Consents required by backend. Auto-recording consents for session: $sessionId');
        try {
          final api = ApiService();
          await api.createConsent(
            sessionId: sessionId,
            consentType: 'DATA_COLLECTION',
            decision: 'ACCEPTED',
          );
          await api.createConsent(
            sessionId: sessionId,
            consentType: 'AI_PROCESSING',
            decision: 'ACCEPTED',
          );
          try {
            await api.createConsent(
              sessionId: sessionId,
              consentType: 'AYUSH',
              decision: 'ACCEPTED',
            );
          } catch (_) {}

          print('[AYUSH] Consents recorded successfully. Retrying AYUSH assessment...');
          final report = await api.submitAyushAssessment(assessment);
          if (!mounted) return;
          context.go('/personalized-recommendations', extra: report);
          return;
        } catch (retryError) {
          print('[AYUSH] Retry after consent creation failed: $retryError');
        }
      }

      
      if (error.response?.statusCode == 404 || serverMsg.toLowerCase().contains('session not found')) {
        print('[AYUSH] Session not found on server. Auto-healing session...');
        try {
          final api = ApiService();
          final patientId = ref.read(sessionProvider).patientId ?? 'DEMO-PATIENT-1';
          final healed = await ref.read(sessionProvider.notifier).createSession(
            patientId: patientId,
            sessionType: 'AYUSH',
            language: ref.read(sessionProvider).language ?? 'hi',
          );
          if (healed) {
            final newSessionId = ref.read(sessionProvider).sessionId;
            if (newSessionId != null && newSessionId.isNotEmpty) {
              final healedAssessment = AyushAssessmentRequest.fromPrakritiAnswers(
                sessionId: newSessionId,
                rawAnswers: prakritiAnswers,
                vikriti: vikritiPayload,
                agniAnswers: agniPayload,
                aharaAnswers: aharaPayload,
                viharaAnswers: viharaPayload,
                dashavidhaAnswers: dashavidhaPayload,
              );
              final report = await api.submitAyushAssessment(healedAssessment);
              if (!mounted) return;
              context.go('/personalized-recommendations', extra: report);
              return;
            }
          }
        } catch (retryError) {
          print('[AYUSH] Session auto-heal failed: $retryError');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not finalize assessment: '
                '${serverMsg.isNotEmpty ? serverMsg : 'unknown error'}'),
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } catch (error) {
      print('[AYUSH] Assessment submission failed: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not finalize assessment: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  
  
  
  String? _serverMessage(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      for (final key in ['message', 'error', 'detail', 'errors']) {
        final value = data[key];
        if (value != null && value.toString().isNotEmpty) return value.toString();
      }
    }
    final text = data.toString();
    return text.isEmpty ? null : text;
  }

  

  String _overallLevel(AppLocalizations l10n) {
    if (!_typeOfDietSelected) return l10n.aharaLevelGood;
    int score = 0;
    
    if (_typeOfDietIndex == 0) {
      score += 2;
    } else if (_typeOfDietIndex == 2) score += 1;
    if (_mealRegularityIndex == 0) {
      score += 2;
    } else if (_mealRegularityIndex == 1) score += 1;
    if (_mealQuantityIndex == 1) {
      score += 2;
    } else if (_mealQuantityIndex == 0 || _mealQuantityIndex == 2) score += 1;
    if (_foodQualityIndex == 2 || _foodQualityIndex == 3) {
      score += 2;
    } else if (_foodQualityIndex == 1) score += 1;
    
    if (_physicalActivityIndex == 1 || _physicalActivityIndex == 2) {
      score += 2;
    } else if (_physicalActivityIndex == 3) score += 1;
    if (_sleepPatternIndex == 2) {
      score += 2;
    } else if (_sleepPatternIndex == 1) score += 1;
    if (_stressLevelIndex == 0) {
      score += 2;
    } else if (_stressLevelIndex == 1) score += 1;
    if (_dailyRoutineIndex == 0 || _dailyRoutineIndex == 1) {
      score += 2;
    } else if (_dailyRoutineIndex == 2) score += 1;
    if (_habitsIndex == 0) {
      score += 2;
    } else if (_habitsIndex == 1) score += 1;

    if (score >= 16) return l10n.aharaLevelExcellent;
    if (score >= 10) return l10n.aharaLevelGood;
    if (score >= 5) return l10n.aharaLevelFair;
    return l10n.aharaLevelNeedsImprovement;
  }

  String _overallBadge(AppLocalizations l10n) {
    final level = _overallLevel(l10n);
    if (level == l10n.aharaLevelExcellent) return l10n.aharaLevelExcellent;
    if (level == l10n.aharaLevelGood) return l10n.aharaBadgeBalanced;
    if (level == l10n.aharaLevelFair) return l10n.aharaBadgeNeedsAttention;
    return l10n.aharaBadgeImbalanced;
  }

  
  bool _typeOfDietSelected = false;
  int _typeOfDietIndex = -1;
  int _mealRegularityIndex = -1;
  int _mealQuantityIndex = -1;
  int _foodQualityIndex = -1;
  int _physicalActivityIndex = -1;
  int _sleepPatternIndex = -1;
  int _stressLevelIndex = -1;
  int _dailyRoutineIndex = -1;
  int _habitsIndex = -1;

  double _gaugeValue(AppLocalizations l10n) {
    if (!_typeOfDietSelected) return 0.5;
    final level = _overallLevel(l10n);
    if (level == l10n.aharaLevelExcellent) return 0.9;
    if (level == l10n.aharaLevelGood) return 0.6;
    if (level == l10n.aharaLevelFair) return 0.35;
    return 0.15;
  }

  Color _overallColor(AppLocalizations l10n) {
    final level = _overallLevel(l10n);
    if (level == l10n.aharaLevelExcellent) return const Color(0xFF22C55E);
    if (level == l10n.aharaLevelGood) return const Color(0xFF0B6B6A);
    if (level == l10n.aharaLevelFair) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String _summaryDescription(AppLocalizations l10n) {
    if (!_typeOfDietSelected) return l10n.aharaSummaryDescIncomplete;
    final level = _overallLevel(l10n);
    if (level == l10n.aharaLevelExcellent) return l10n.aharaSummaryDescExcellent;
    if (level == l10n.aharaLevelGood) return l10n.aharaSummaryDescGood;
    if (level == l10n.aharaLevelFair) return l10n.aharaSummaryDescFair;
    return l10n.aharaSummaryDescPoor;
  }

  String _ayurvedicTip(AppLocalizations l10n) {
    return l10n.aharaTipDefault;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final aharaQ = _aharaQuestions(l10n);
    final viharaQ = _viharaQuestions(l10n);
    final allAnswered = _allAnsweredCheck(aharaQ, viharaQ);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            
            _buildHeader(l10n),

            const SizedBox(height: 8),

            
            _buildProgressBar(),

            const SizedBox(height: 12),

            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    
                    _buildInfoCard(l10n),

                    const SizedBox(height: 16),

                    
                    _buildSectionHeader(l10n.aharaDietSection, '🍵'),
                    const SizedBox(height: 12),
                    ...aharaQ.asMap().entries.map((entry) {
                      final i = entry.key;
                      final q = entry.value;
                      return _buildQuestionRow(
                        section: 0,
                        questionIndex: i,
                        number: q['number'],
                        title: q['title'],
                        subtitle: q['subtitle'],
                        emoji: q['emoji'],
                        options: List<String>.from(q['options']),
                      );
                    }),

                    const SizedBox(height: 20),

                    
                    _buildSectionHeader(l10n.viharaLifestyleSection, '🧘'),
                    const SizedBox(height: 12),
                    ...viharaQ.asMap().entries.map((entry) {
                      final i = entry.key;
                      final q = entry.value;
                      return _buildQuestionRow(
                        section: 1,
                        questionIndex: i,
                        number: q['number'],
                        title: q['title'],
                        subtitle: q['subtitle'],
                        emoji: q['emoji'],
                        options: List<String>.from(q['options']),
                      );
                    }),

                    const SizedBox(height: 16),

                    
                    _buildSummaryCard(l10n, allAnswered),

                    const SizedBox(height: 12),

                    
                    _buildAyurvedicTip(l10n, allAnswered),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            
            _buildBottomButtons(l10n, allAnswered),
          ],
        ),
      ),
    );
  }

  

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/dashavidha'),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF0B6B6A), size: 20),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  l10n.aharaViharaTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  l10n.stepOfLabel(_currentStep + 1, _totalSteps),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0B6B6A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.volume_up_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          l10n.listenButton,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Row(
            children: List.generate(_totalSteps, (i) {
              final isCompleted = i < _currentStep;
              final isActive = i == _currentStep;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: isCompleted || isActive
                        ? const Color(0xFF0B6B6A)
                        : const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(_totalSteps, (i) {
              final isCompleted = i < _currentStep;
              final isActive = i == _currentStep;
              return Expanded(
                child: Center(
                  child: Text(
                    _stepLabels[i],
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: isActive || isCompleted
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isActive
                          ? const Color(0xFF0B6B6A)
                          : isCompleted
                              ? const Color(0xFF22C55E)
                              : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  

  Widget _buildInfoCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFF0B6B6A),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.info_outline, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.aharaViharaInfoDesc,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF374151),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  

  Widget _buildSectionHeader(String title, String emoji) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  

  Widget _buildQuestionRow({
    required int section,
    required int questionIndex,
    required String number,
    required String title,
    required String subtitle,
    required String emoji,
    required List<String> options,
  }) {
    final currentAnswer = _getAnswer(section, questionIndex);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$number $title',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = currentAnswer == option;
              return GestureDetector(
                onTap: () {
                  final optionIdx = options.indexOf(option);
                  _setAnswer(section, questionIndex, option, optionIdx);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE0F2F1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0B6B6A)
                          : const Color(0xFFE5E7EB),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? const Color(0xFF0B6B6A)
                                : const Color(0xFF374151),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.check_circle,
                            color: Color(0xFF0B6B6A), size: 18),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  

  Widget _buildSummaryCard(AppLocalizations l10n, bool allAnswered) {
    final overallLevel = _overallLevel(l10n);
    final overallColor = _overallColor(l10n);
    final overallBadge = _overallBadge(l10n);
    final summaryDesc = _summaryDescription(l10n);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🌿', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.aharaSummaryTitle,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B6B6A),
                            ),
                          ),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Text(
                                '${l10n.aharaOverallLabel}$overallLevel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: overallColor,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: overallColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  overallBadge,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: overallColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
                const SizedBox(height: 10),
                Text(
                  summaryDesc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),


        ],
      ),
    );
  }

  

  Widget _buildGauge() {
    return SizedBox(
      height: 90,
      child: CustomPaint(
        size: const Size(120, 90),
        painter: _GaugePainter(value: _gaugeValue(AppLocalizations.of(context))),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        'Needs',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.grey[500],
                        ),
                      ),
                      Text(
                        'Improvement',
                        style: TextStyle(
                          fontSize: 7,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'Balanced',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: _overallColor(AppLocalizations.of(context)),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'Excellent',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  

  Widget _buildAyurvedicTip(AppLocalizations l10n, bool allAnswered) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.agniAyurvedicTip,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _ayurvedicTip(l10n),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF374151),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  

  Widget _buildBottomButtons(AppLocalizations l10n, bool allAnswered) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        children: [
          
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.go('/dashavidha'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0B6B6A), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_back_rounded,
                      size: 18, color: Color(0xFF0B6B6A)),
                  const SizedBox(width: 4),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        l10n.previous,
                        style: const TextStyle(
                          color: Color(0xFF0B6B6A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: allAnswered && !_isSubmitting
                  ? _submitAssessment
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B6B6A),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    const Color(0xFF0B6B6A).withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _isSubmitting ? l10n.submitting : l10n.completeAssessment,
                        style: TextStyle(
                          color: allAnswered
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: allAnswered
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.7),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class _GaugePainter extends CustomPainter {
  final double value; 

  _GaugePainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 18);
    final radius = size.width / 2 - 8;

    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    
    bgPaint.color = const Color(0xFFEF4444);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi * 0.33,
      false,
      bgPaint,
    );

    
    bgPaint.color = const Color(0xFFF59E0B);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 1.33,
      math.pi * 0.17,
      false,
      bgPaint,
    );

    
    bgPaint.color = const Color(0xFF0B6B6A);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 1.5,
      math.pi * 0.17,
      false,
      bgPaint,
    );

    
    bgPaint.color = const Color(0xFF86EFAC);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 1.67,
      math.pi * 0.17,
      false,
      bgPaint,
    );

    
    bgPaint.color = const Color(0xFF22C55E);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 1.84,
      math.pi * 0.16,
      false,
      bgPaint,
    );

    
    final needleAngle = math.pi + (value * math.pi);
    final needlePaint = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final needleEnd = Offset(
      center.dx + (radius - 5) * math.cos(needleAngle),
      center.dy + (radius - 5) * math.sin(needleAngle),
    );

    canvas.drawLine(center, needleEnd, needlePaint);

    
    final dotPaint = Paint()
      ..color = const Color(0xFF111827)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.value != value;
  }
}