import 'package:medikiosk/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/features/ayush/providers/ayush_provider.dart';
import 'package:medikiosk/app/localization/app_localizations.dart';
import 'dart:math' as math;



class AgniOption {
  final String label;
  final String description;
  final String emoji;
  const AgniOption({
    required this.label,
    required this.description,
    required this.emoji,
  });
}



class AgniScreen extends ConsumerStatefulWidget {
  const AgniScreen({super.key});

  @override
  ConsumerState<AgniScreen> createState() => _AgniScreenState();
}

class _AgniScreenState extends ConsumerState<AgniScreen> {
  final int _currentStep = 2; 
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

  
  int? _appetiteAnswer;
  int? _afterMealsAnswer;
  int? _digestionAnswer;

  
  List<AgniOption> _appetiteOptions(AppLocalizations l10n) => [
    AgniOption(label: l10n.agniAppetiteLowLabel, description: l10n.agniAppetiteLowDesc, emoji: '🍵'),
    AgniOption(label: l10n.agniAppetiteModerateLabel, description: l10n.agniAppetiteModerateDesc, emoji: '🥘'),
    AgniOption(label: l10n.agniAppetiteStrongLabel, description: l10n.agniAppetiteStrongDesc, emoji: '🍽️'),
    AgniOption(label: l10n.agniAppetiteIrregularLabel, description: l10n.agniAppetiteIrregularDesc, emoji: '❌'),
  ];

  
  List<AgniOption> _afterMealsOptions(AppLocalizations l10n) => [
    AgniOption(label: l10n.agniAfterMealsLightLabel, description: l10n.agniAfterMealsLightDesc, emoji: '😊'),
    AgniOption(label: l10n.agniAfterMealsSometimesHeavyLabel, description: l10n.agniAfterMealsSometimesHeavyDesc, emoji: '😐'),
    AgniOption(label: l10n.agniAfterMealsOftenHeavyLabel, description: l10n.agniAfterMealsOftenHeavyDesc, emoji: '😟'),
    AgniOption(label: l10n.agniAfterMealsVeryHeavyLabel, description: l10n.agniAfterMealsVeryHeavyDesc, emoji: '😣'),
  ];

  
  List<AgniOption> _digestionOptions(AppLocalizations l10n) => [
    AgniOption(label: l10n.agniDigestionGoodLabel, description: l10n.agniDigestionGoodDesc, emoji: '🟢'),
    AgniOption(label: l10n.agniDigestionSometimesSlowLabel, description: l10n.agniDigestionSometimesSlowDesc, emoji: '🟡'),
    AgniOption(label: l10n.agniDigestionPoorLabel, description: l10n.agniDigestionPoorDesc, emoji: '🟠'),
    AgniOption(label: l10n.agniDigestionVeryPoorLabel, description: l10n.agniDigestionVeryPoorDesc, emoji: '🔴'),
  ];

  
  String get _agniLevel {
    if (_appetiteAnswer == null || _afterMealsAnswer == null || _digestionAnswer == null) {
      return 'Madhyama Agni';
    }
    final total = _appetiteAnswer! + _afterMealsAnswer! + _digestionAnswer!;
    if (total <= 3) return 'Mandagni (Low)';
    if (total <= 6) return 'Madhyama Agni';
    return 'Tikshnagni (High)';
  }

  String get _agniLevelShort {
    if (_appetiteAnswer == null || _afterMealsAnswer == null || _digestionAnswer == null) {
      return 'Moderate';
    }
    final total = _appetiteAnswer! + _afterMealsAnswer! + _digestionAnswer!;
    if (total <= 3) return 'Low';
    if (total <= 6) return 'Moderate';
    return 'High';
  }

  double get _agniGaugeValue {
    if (_appetiteAnswer == null || _afterMealsAnswer == null || _digestionAnswer == null) {
      return 0.5; 
    }
    final total = _appetiteAnswer! + _afterMealsAnswer! + _digestionAnswer!;
    if (total <= 3) return 0.2; 
    if (total <= 6) return 0.5; 
    return 0.8; 
  }

  Color get _agniLevelColor {
    if (_appetiteAnswer == null || _afterMealsAnswer == null || _digestionAnswer == null) {
      return const Color(0xFF0B6B6A);
    }
    final total = _appetiteAnswer! + _afterMealsAnswer! + _digestionAnswer!;
    if (total <= 3) return const Color(0xFFEF4444);
    if (total <= 6) return const Color(0xFF0B6B6A);
    return const Color(0xFFE67E22);
  }

  String _agniDescription(AppLocalizations l10n) {
    if (_appetiteAnswer == null || _afterMealsAnswer == null || _digestionAnswer == null) {
      return l10n.agniDescModerate;
    }
    final total = _appetiteAnswer! + _afterMealsAnswer! + _digestionAnswer!;
    if (total <= 3) return l10n.agniDescLow;
    if (total <= 6) return l10n.agniDescModerate;
    return l10n.agniDescHigh;
  }

  String _ayurvedicTip(AppLocalizations l10n) {
    if (_appetiteAnswer == null || _afterMealsAnswer == null || _digestionAnswer == null) {
      return l10n.agniTipModerate;
    }
    final total = _appetiteAnswer! + _afterMealsAnswer! + _digestionAnswer!;
    if (total <= 3) return l10n.agniTipLow;
    if (total <= 6) return l10n.agniTipModerate;
    return l10n.agniTipHigh;
  }

  bool get _allAnswered =>
      _appetiteAnswer != null && _afterMealsAnswer != null && _digestionAnswer != null;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final l10n = AppLocalizations.of(context);
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

                    
                    _buildOptionQuestion(
                      l10n: l10n,
                      questionNumber: 1,
                      title: l10n.agniHowIsAppetite,
                      options: _appetiteOptions(l10n),
                      selectedIndex: _appetiteAnswer,
                      onSelected: (i) {
                        setState(() => _appetiteAnswer = i);
                        
                        const englishValues = ['low', 'moderate', 'strong', 'irregular'];
                        ref.read(agniAnswersProvider.notifier).setAppetite(englishValues[i]);
                      },
                    ),

                    const SizedBox(height: 16),

                    
                    _buildOptionQuestion(
                      l10n: l10n,
                      questionNumber: 2,
                      title: l10n.agniHowFeelAfterMeals,
                      options: _afterMealsOptions(l10n),
                      selectedIndex: _afterMealsAnswer,
                      onSelected: (i) {
                        setState(() => _afterMealsAnswer = i);
                        
                        const englishValues = ['light', 'some heaviness', 'heavy', 'very heavy'];
                        ref.read(agniAnswersProvider.notifier).setAfterMeals(englishValues[i]);
                      },
                    ),

                    const SizedBox(height: 16),

                    
                    _buildOptionQuestion(
                      l10n: l10n,
                      questionNumber: 3,
                      title: l10n.agniHowIsDigestion,
                      options: _digestionOptions(l10n),
                      selectedIndex: _digestionAnswer,
                      onSelected: (i) {
                        setState(() => _digestionAnswer = i);
                        
                        const englishValues = ['good', 'slow', 'poor', 'very poor'];
                        ref.read(agniAnswersProvider.notifier).setDigestion(englishValues[i]);
                      },
                    ),

                    const SizedBox(height: 16),

                    
                    _buildAgniLevelCard(l10n),

                    const SizedBox(height: 12),

                    
                    _buildAyurvedicTip(l10n),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            
            _buildBottomButtons(l10n),
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
            onTap: () => context.go('/vikriti'),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF0B6B6A), size: 20),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  l10n.agniTitle,
                  style: const TextStyle(
                    fontSize: 25,
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
              l10n.agniInfoDesc,
              style: const TextStyle(
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

  

  Widget _buildOptionQuestion({
    required AppLocalizations l10n,
    required int questionNumber,
    required String title,
    required List<AgniOption> options,
    required int? selectedIndex,
    required ValueChanged<int> onSelected,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
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
          Text(
            '$questionNumber. $title',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.agniChooseOption,
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 14),
          Row(
            children: options.asMap().entries.map((entry) {
              final i = entry.key;
              final option = entry.value;
              final isSelected = selectedIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelected(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE0F2F1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF0B6B6A)
                            : const Color(0xFFE5E7EB),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF0B6B6A)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: isSelected
                                  ? null
                                  : Border.all(
                                      color: const Color(0xFFD1D5DB),
                                      width: 1.5),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 14)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 6),
                        
                        Text(option.emoji,
                            style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 4),
                        
                        Text(
                          option.label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? const Color(0xFF0B6B6A)
                                : const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 2),
                        
                        Text(
                          option.description,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Color(0xFF6B7280),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  

  Widget _buildAgniLevelCard(AppLocalizations l10n) {
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
                const Text('🔥', style: TextStyle(fontSize: 24)),
                const SizedBox(height: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(
                        l10n.agniYourLevel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _agniLevel.contains('Mandagni')
                                  ? l10n.agniLevelMandagni.split(' (')[0]
                                  : _agniLevel.contains('Tikshnagni')
                                      ? l10n.agniLevelTikshnagni.split(' (')[0]
                                      : l10n.agniLevelMadhyama,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _agniLevelColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _agniLevelColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _agniLevelShort == 'Low' ? l10n.agniLevelLow : _agniLevelShort == 'Moderate' ? l10n.agniLevelModerate : l10n.agniLevelHigh,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _agniLevelColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _agniDescription(l10n),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
      height: 70,
      child: CustomPaint(
        size: const Size(80, 70),
        painter: _GaugePainter(value: _agniGaugeValue),
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
                        'Mandagni',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.grey[500],
                        ),
                      ),
                      Text(
                        '(Low)',
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
                        'Madhyama',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: _agniLevelColor,
                        ),
                      ),
                      Text(
                        '(Moderate)',
                        style: TextStyle(
                          fontSize: 7,
                          color: _agniLevelColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'Tikshnagni',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.grey[500],
                        ),
                      ),
                      Text(
                        '(High)',
                        style: TextStyle(
                          fontSize: 7,
                          color: Colors.grey[400],
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

  

  Widget _buildAyurvedicTip(AppLocalizations l10n) {
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

  

  Widget _buildBottomButtons(AppLocalizations l10n) {
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
            child: OutlinedButton.icon(
              onPressed: () => context.go('/vikriti'),
              icon: const Icon(Icons.arrow_back_rounded,
                  size: 18, color: Color(0xFF0B6B6A)),
              label: Text(
                l10n.previous,
                style: TextStyle(
                  color: Color(0xFF0B6B6A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side:
                    const BorderSide(color: Color(0xFF0B6B6A), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _allAnswered
                  ? () {
                      
                      context.go('/dashavidha');
                    }
                  : null,
              icon: Flexible(
                child: Text(
                  l10n.nextKoshthaAssessment,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                        _allAnswered ? Colors.white : Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              label: Icon(Icons.arrow_forward_rounded,
                  color: _allAnswered
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.7),
                  size: 18),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B6B6A),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    const Color(0xFF0B6B6A).withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                elevation: 0,
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
    final center = Offset(size.width / 2, size.height - 20);
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

    
    bgPaint.color = const Color(0xFFF59E0B);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 1.67,
      math.pi * 0.17,
      false,
      bgPaint,
    );

    
    bgPaint.color = const Color(0xFFEF4444);
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