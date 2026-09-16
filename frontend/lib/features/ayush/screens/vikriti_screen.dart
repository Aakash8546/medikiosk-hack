import 'package:medikiosk/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/app/localization/app_localizations.dart';



class SymptomOption {
  final String label;
  final String emoji;
  const SymptomOption({required this.label, required this.emoji});
}



class VikritiState {
  final Set<String> selectedDoshas;
  final Set<String> selectedSymptoms;
  final int severityIndex; 
  final String duration;

  VikritiState({
    this.selectedDoshas = const {},
    this.selectedSymptoms = const {},
    this.severityIndex = 2, 
    this.duration = '',
  });

  VikritiState copyWith({
    Set<String>? selectedDoshas,
    Set<String>? selectedSymptoms,
    int? severityIndex,
    String? duration,
  }) {
    return VikritiState(
      selectedDoshas: selectedDoshas ?? this.selectedDoshas,
      selectedSymptoms: selectedSymptoms ?? this.selectedSymptoms,
      severityIndex: severityIndex ?? this.severityIndex,
      duration: duration ?? this.duration,
    );
  }

  bool get isComplete =>
      selectedDoshas.isNotEmpty &&
      selectedSymptoms.isNotEmpty &&
      duration.isNotEmpty;
}

class VikritiNotifier extends StateNotifier<VikritiState> {
  VikritiNotifier() : super(VikritiState());

  void toggleDosha(String dosha) {
    final newSet = Set<String>.from(state.selectedDoshas);
    if (newSet.contains(dosha)) {
      newSet.remove(dosha);
    } else {
      newSet.add(dosha);
    }
    state = state.copyWith(selectedDoshas: newSet);
  }

  void toggleSymptom(String symptom) {
    final newSet = Set<String>.from(state.selectedSymptoms);
    if (newSet.contains(symptom)) {
      newSet.remove(symptom);
    } else {
      newSet.add(symptom);
    }
    state = state.copyWith(selectedSymptoms: newSet);
  }

  void setSeverity(int index) {
    state = state.copyWith(severityIndex: index);
  }

  void setDuration(String duration) {
    state = state.copyWith(duration: duration);
  }
}

final vikritiProvider =
    StateNotifierProvider<VikritiNotifier, VikritiState>(
  (ref) => VikritiNotifier(),
);



class VikritiScreen extends ConsumerStatefulWidget {
  const VikritiScreen({super.key});

  @override
  ConsumerState<VikritiScreen> createState() => _VikritiScreenState();
}

class _VikritiScreenState extends ConsumerState<VikritiScreen> {
  final int _currentStep = 1; 
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

  
  List<Map<String, String>> _doshaOptions(AppLocalizations l10n) => [
    {
      'name': 'Vata',
      'desc': l10n.vataDesc,
      'emoji': '🌀',
      'color': '0xFF3B82F6',
    },
    {
      'name': 'Pitta',
      'desc': l10n.pittaDesc,
      'emoji': '🔥',
      'color': '0xFFE67E22',
    },
    {
      'name': 'Kapha',
      'desc': l10n.kaphaDesc,
      'emoji': '🍃',
      'color': '0xFF2E7D32',
    },
  ];

  
  List<SymptomOption> _symptomOptions(AppLocalizations l10n) => [
    SymptomOption(label: l10n.symptomAcidity, emoji: '🔥'),
    SymptomOption(label: l10n.symptomHeadache, emoji: '🤕'),
    SymptomOption(label: l10n.symptomSkinRashes, emoji: '🖐️'),
    SymptomOption(label: l10n.symptomBloating, emoji: '🫃'),
    SymptomOption(label: l10n.symptomConstipation, emoji: '💩'),
    SymptomOption(label: l10n.symptomFatigue, emoji: '🔋'),
    SymptomOption(label: l10n.symptomJointPain, emoji: '🦴'),
    SymptomOption(label: l10n.symptomPoorSleep, emoji: '🌙'),
    SymptomOption(label: l10n.symptomWeightGain, emoji: '⚖️'),
    SymptomOption(label: l10n.symptomOthers, emoji: '💬'),
  ];

  
  List<Map<String, String>> _severityOptions(AppLocalizations l10n) => [
    {'label': l10n.severityNone, 'emoji': '😊', 'color': '0xFF22C55E'},
    {'label': l10n.severityMild, 'emoji': '🙂', 'color': '0xFF86EFAC'},
    {'label': l10n.severityModerate, 'emoji': '😐', 'color': '0xFFF59E0B'},
    {'label': l10n.severitySevere, 'emoji': '😟', 'color': '0xFFEF4444'},
    {'label': l10n.severityVerySevere, 'emoji': '😣', 'color': '0xFFDC2626'},
  ];

  
  List<String> _durationOptions(AppLocalizations l10n) => [
    l10n.durationLessThan1Week,
    l10n.duration1to4Weeks,
    l10n.duration1to3Months,
    l10n.durationMoreThan3Months,
  ];

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final vikriti = ref.watch(vikritiProvider);
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

                    
                    _buildDoshaQuestion(vikriti, l10n),

                    const SizedBox(height: 16),

                    
                    _buildSymptomQuestion(vikriti, l10n),

                    const SizedBox(height: 16),

                    
                    _buildSeverityQuestion(vikriti, l10n),

                    const SizedBox(height: 16),

                    
                    _buildDurationQuestion(vikriti, l10n),

                    const SizedBox(height: 12),

                    
                    _buildBottomNotice(l10n),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            
            _buildBottomButtons(vikriti, l10n),
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
            onTap: () => context.go('/ayush'),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF0B6B6A), size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                children: [
                  Text(
                    l10n.vikritiTitle,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Text(
                    l10n.stepOfLabel(_currentStep + 1, _totalSteps),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0B6B6A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.volume_up_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Listen',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
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
                      fontWeight:
                          isActive || isCompleted ? FontWeight.w600 : FontWeight.normal,
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
            child: const Icon(Icons.info_outline, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.vikritiInfoDesc,
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

  

  Widget _buildDoshaQuestion(VikritiState vikriti, AppLocalizations l10n) {
    final doshaOptions = _doshaOptions(l10n);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.whichDoshasImbalanced,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.selectAllThatApply,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 14),
          Row(
            children: doshaOptions.map((dosha) {
              final isSelected = vikriti.selectedDoshas.contains(dosha['name']);
              final doshaColor = Color(int.parse(dosha['color']!));
              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      ref.read(vikritiProvider.notifier).toggleDosha(dosha['name']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? doshaColor.withValues(alpha: 0.06)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? doshaColor : const Color(0xFFE5E7EB),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isSelected ? doshaColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: isSelected
                                  ? null
                                  : Border.all(color: const Color(0xFFD1D5DB), width: 1.5),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 16)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        Text(dosha['emoji']!, style: const TextStyle(fontSize: 36)),
                        const SizedBox(height: 8),
                        
                        Text(
                          dosha['name']!,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? doshaColor : const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        
                        Text(
                          dosha['desc']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                            height: 1.3,
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

  

  Widget _buildSymptomQuestion(VikritiState vikriti, AppLocalizations l10n) {
    final symptomOptions = _symptomOptions(l10n);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  l10n.whatSymptomsExperiencing,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          l10n.viewAllSymptoms,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF0B6B6A),
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: Color(0xFF0B6B6A), size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.selectAllThatApply,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: symptomOptions.map((symptom) {
              final isSelected =
                  vikriti.selectedSymptoms.contains(symptom.label);
              return GestureDetector(
                onTap: () => ref
                    .read(vikritiProvider.notifier)
                    .toggleSymptom(symptom.label),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE0F2F1)
                        : const Color(0xFFF9FAFB),
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
                      Text(symptom.emoji,
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          symptom.label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected
                                ? const Color(0xFF0B6B6A)
                                : const Color(0xFF374151),
                          ),
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

  

  Widget _buildSeverityQuestion(VikritiState vikriti, AppLocalizations l10n) {
    final severityOptions = _severityOptions(l10n);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.severityQuestion,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.severityRatePrompt,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(severityOptions.length, (i) {
              final option = severityOptions[i];
              final isSelected = vikriti.severityIndex == i;
              final color = Color(int.parse(option['color']!.replaceFirst('0x', '0xFF')));
              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      ref.read(vikritiProvider.notifier).setSeverity(i),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSelected ? 56 : 48,
                        height: isSelected ? 56 : 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? color.withValues(alpha: 0.15)
                              : Colors.transparent,
                          border: isSelected
                              ? Border.all(color: color, width: 2.5)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            option['emoji']!,
                            style: TextStyle(fontSize: isSelected ? 30 : 26),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        option['label']!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? color : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  

  Widget _buildDurationQuestion(VikritiState vikriti, AppLocalizations l10n) {
    final durationOptions = _durationOptions(l10n);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.durationQuestion,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 14),
          ...durationOptions.map((option) {
            final isSelected = vikriti.duration == option;
            return GestureDetector(
              onTap: () =>
                  ref.read(vikritiProvider.notifier).setDuration(option),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE0F2F1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0B6B6A)
                        : const Color(0xFFE5E7EB),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF0B6B6A)
                              : const Color(0xFFD1D5DB),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Center(
                              child: Icon(Icons.circle,
                                  size: 10, color: Color(0xFF0B6B6A)),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFF0B6B6A)
                              : const Color(0xFF374151),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  

  Widget _buildBottomNotice(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text('🌿', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.answersHelpCreateSummary,
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

  

  Widget _buildBottomButtons(VikritiState vikriti, AppLocalizations l10n) {
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
              onPressed: () => context.go('/ayush'),
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
              onPressed: vikriti.isComplete
                  ? () => context.go('/agni')
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B6B6A),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF0B6B6A).withValues(alpha: 0.5),
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
                        l10n.nextAgniAssessment,
                        style: TextStyle(
                          color: vikriti.isComplete
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: vikriti.isComplete
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.7),
                    size: 18,
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