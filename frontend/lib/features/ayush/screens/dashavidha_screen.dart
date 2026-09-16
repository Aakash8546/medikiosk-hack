import 'package:medikiosk/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/app/localization/app_localizations.dart';
import 'package:medikiosk/app/providers/locale_provider.dart';



class DashavidhaParameter {
  final int number;
  final String title;
  final String subtitle;
  final String emoji;
  final Color emojiBgColor;
  String? answer;
  final Color? answerColor;

  DashavidhaParameter({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.emojiBgColor,
    this.answer,
    this.answerColor,
  });
}



class DashavidhaNotifier extends StateNotifier<List<DashavidhaParameter>> {
  DashavidhaNotifier(this.l10n) : super(_defaultParameters(l10n));
  final AppLocalizations l10n;

  
  static List<DashavidhaParameter> _defaultParameters(AppLocalizations l10n) => [
    DashavidhaParameter(number: 1, title: l10n.dashParam1Title, subtitle: l10n.dashParam1Subtitle, emoji: '👅', emojiBgColor: const Color(0xFFFFEBEE)),
    DashavidhaParameter(number: 2, title: l10n.dashParam2Title, subtitle: l10n.dashParam2Subtitle, emoji: '🧘', emojiBgColor: const Color(0xFFE8F5E9)),
    DashavidhaParameter(number: 3, title: l10n.dashParam3Title, subtitle: l10n.dashParam3Subtitle, emoji: '🫀', emojiBgColor: const Color(0xFFFFEBEE)),
    DashavidhaParameter(number: 4, title: l10n.dashParam4Title, subtitle: l10n.dashParam4Subtitle, emoji: '💪', emojiBgColor: const Color(0xFFFFF3E0)),
    DashavidhaParameter(number: 5, title: l10n.dashParam5Title, subtitle: l10n.dashParam5Subtitle, emoji: '🔥', emojiBgColor: const Color(0xFFFFF3E0)),
    DashavidhaParameter(number: 6, title: l10n.dashParam6Title, subtitle: l10n.dashParam6Subtitle, emoji: '🫘', emojiBgColor: const Color(0xFFE8F5E9)),
    DashavidhaParameter(number: 7, title: l10n.dashParam7Title, subtitle: l10n.dashParam7Subtitle, emoji: '🧍', emojiBgColor: const Color(0xFFE3F2FD)),
    DashavidhaParameter(number: 8, title: l10n.dashParam8Title, subtitle: l10n.dashParam8Subtitle, emoji: '🍛', emojiBgColor: const Color(0xFFE8F5E9)),
    DashavidhaParameter(number: 9, title: l10n.dashParam9Title, subtitle: l10n.dashParam9Subtitle, emoji: '🧘‍♀️', emojiBgColor: const Color(0xFFE3F2FD)),
    DashavidhaParameter(number: 10, title: l10n.dashParam10Title, subtitle: l10n.dashParam10Subtitle, emoji: '🛏️', emojiBgColor: const Color(0xFFFCE4EC)),
  ];

  void setAnswer(int index, String answer) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          DashavidhaParameter(
            number: state[i].number,
            title: state[i].title,
            subtitle: state[i].subtitle,
            emoji: state[i].emoji,
            emojiBgColor: state[i].emojiBgColor,
            answer: answer,
            answerColor: _getColorForAnswer(answer),
          )
        else
          state[i],
    ];
  }

  Color _getColorForAnswer(String answer) {
    if (answer.contains('↑') || answer == 'Kapha-Pitta') {
      return const Color(0xFFE67E22); 
    }
    if (answer == 'Uttama') {
      return const Color(0xFF2E7D32); 
    }
    if (answer.contains('Years')) {
      return const Color(0xFFC62828); 
    }
    return const Color(0xFF6B7280); 
  }

  int get completedCount => state.where((p) => p.answer != null).length;
}

final dashavidhaProvider =
    StateNotifierProvider<DashavidhaNotifier, List<DashavidhaParameter>>(
  
  
  (ref) => DashavidhaNotifier(AppLocalizations(ref.watch(localeProvider))),
);



class DashavidhaScreen extends ConsumerStatefulWidget {
  const DashavidhaScreen({super.key});

  @override
  ConsumerState<DashavidhaScreen> createState() => _DashavidhaScreenState();
}

class _DashavidhaScreenState extends ConsumerState<DashavidhaScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _progressAnim;
  final int _currentStep = 3; 
  final int _totalSteps = 7;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _progressAnim = Tween<double>(
      begin: 0,
      end: (_currentStep + 1) / _totalSteps,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color _getAnswerBadgeColor(String answer) {
    if (answer.contains('↑') || answer == 'Kapha-Pitta') {
      return const Color(0xFFE67E22);
    }
    if (answer == 'Uttama') {
      return const Color(0xFF2E7D32);
    }
    if (answer.contains('Years')) {
      return const Color(0xFFC62828);
    }
    return const Color(0xFF6B7280);
  }

  void _showAnswerPicker(int index, String title) {
    final params = ref.read(dashavidhaProvider);
    final l10n = AppLocalizations.of(context);

    
    List<Map<String, String>> options;
    switch (index) {
      case 0: 
        options = [
          {'d': l10n.dashOptVata, 'v': 'Vata'},
          {'d': l10n.dashOptPitta, 'v': 'Pitta'},
          {'d': l10n.dashOptKapha, 'v': 'Kapha'},
          {'d': l10n.dashOptVataPitta, 'v': 'Vata-Pitta'},
          {'d': l10n.dashOptPittaKapha, 'v': 'Pitta-Kapha'},
          {'d': l10n.dashOptVataKapha, 'v': 'Vata-Kapha'},
        ];
        break;
      case 1: 
        options = [
          {'d': l10n.dashOptVataUp, 'v': 'Vata ↑'},
          {'d': l10n.dashOptPittaUp, 'v': 'Pitta ↑'},
          {'d': l10n.dashOptKaphaUp, 'v': 'Kapha ↑'},
          {'d': l10n.dashOptVataPittaUp, 'v': 'Vata-Pitta ↑'},
          {'d': l10n.dashOptBalanced, 'v': 'Balanced'},
        ];
        break;
      case 2: 
        options = [
          {'d': l10n.dashOptUttamaExcellent, 'v': 'Uttama (Excellent)'},
          {'d': l10n.dashOptMadhyamaModerate, 'v': 'Madhyama (Moderate)'},
          {'d': l10n.dashOptAdhamaPoor, 'v': 'Adhama (Poor)'},
        ];
        break;
      case 3: 
        options = [
          {'d': l10n.dashOptUttamaCompact, 'v': 'Uttama (Compact)'},
          {'d': l10n.dashOptMadhyamaModerate, 'v': 'Madhyama (Moderate)'},
          {'d': l10n.dashOptAdhamaLoose, 'v': 'Adhama (Loose)'},
        ];
        break;
      case 4: 
        options = [
          {'d': l10n.dashOptUttamaLarge, 'v': 'Uttama (Large)'},
          {'d': l10n.dashOptMadhyamaModerate, 'v': 'Madhyama (Moderate)'},
          {'d': l10n.dashOptAdhamaSmall, 'v': 'Adhama (Small)'},
        ];
        break;
      case 5: 
        options = [
          {'d': l10n.dashOptUttamaAdaptable, 'v': 'Uttama (Adaptable)'},
          {'d': l10n.dashOptMadhyamaModerate, 'v': 'Madhyama (Moderate)'},
          {'d': l10n.dashOptAdhamaPoor, 'v': 'Adhama (Poor)'},
        ];
        break;
      case 6: 
        options = [
          {'d': l10n.dashOptUttamaStrong, 'v': 'Uttama (Strong)'},
          {'d': l10n.dashOptMadhyamaModerate, 'v': 'Madhyama (Moderate)'},
          {'d': l10n.dashOptAdhamaWeak, 'v': 'Adhama (Weak)'},
        ];
        break;
      case 7: 
        options = [
          {'d': l10n.dashOptUttamaStrong, 'v': 'Uttama (Strong)'},
          {'d': l10n.dashOptMadhyamaModerate, 'v': 'Madhyama (Moderate)'},
          {'d': l10n.dashOptAdhamaWeak, 'v': 'Adhama (Weak)'},
        ];
        break;
      case 8: 
        options = [
          {'d': l10n.dashOptUttamaStrong, 'v': 'Uttama (Strong)'},
          {'d': l10n.dashOptMadhyamaModerate, 'v': 'Madhyama (Moderate)'},
          {'d': l10n.dashOptAdhamaWeak, 'v': 'Adhama (Weak)'},
        ];
        break;
      case 9: 
        options = [
          {'d': l10n.dashOpt10Years, 'v': '10 Years'},
          {'d': l10n.dashOpt20Years, 'v': '20 Years'},
          {'d': l10n.dashOpt30Years, 'v': '30 Years'},
          {'d': l10n.dashOpt40Years, 'v': '40 Years'},
          {'d': l10n.dashOpt50Years, 'v': '50 Years'},
          {'d': l10n.dashOpt60Years, 'v': '60 Years'},
          {'d': l10n.dashOpt70PlusYears, 'v': '70+ Years'},
        ];
        break;
      default:
        options = [];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.65,
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B6B6A),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: options.map((opt) => ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        title: Text(
                          opt['d']!,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        trailing: params[index].answer == opt['v']
                            ? const Icon(Icons.check_circle, color: Color(0xFF0B6B6A))
                            : null,
                        onTap: () {
                          ref.read(dashavidhaProvider.notifier).setAnswer(index, opt['v']!);
                          Navigator.pop(ctx);
                        },
                      )).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final l10n = AppLocalizations.of(context);
    final params = ref.watch(dashavidhaProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            
            Padding(
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
                          l10n.dashavidhaTitle,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B6B6A),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B6B6A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.volume_up_rounded,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Listen',
                          style: const TextStyle(
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
            ),

            const SizedBox(height: 12),

            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(_totalSteps, (i) {
                  final isCompleted = i < _currentStep;
                  final isActive = i == _currentStep;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
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
            ),

            const SizedBox(height: 12),

            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 16),
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
                            child: const Icon(Icons.info_outline,
                                color: Colors.white, size: 14),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.dashavidhaInfoDesc,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF374151),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.dashavidhaTenParameters,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.dashavidhaTapInstruction,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    
                    ...List.generate(params.length, (i) {
                      return _buildParameterCard(params[i], i);
                    }),

                    const SizedBox(height: 12),

                    
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.dashavidhaUpdateNotice,
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF374151),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            
            Container(
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
                        side: const BorderSide(color: Color(0xFF0B6B6A), width: 1.5),
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
                      onPressed: () {
                        context.go('/ahara-vihara');
                      },
                      icon: Flexible(
                        child: Text(
                          l10n.nextAshtavidhaPariksha,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      label: const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 18),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B6B6A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterCard(DashavidhaParameter param, int index) {
    final hasAnswer = param.answer != null;

    return GestureDetector(
      onTap: () => _showAnswerPicker(index, param.title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: hasAnswer
              ? Border.all(color: const Color(0xFF0B6B6A).withValues(alpha: 0.3), width: 1)
              : Border.all(color: const Color(0xFFE5E7EB), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: param.emojiBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(param.emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),

            
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF0B6B6A),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${param.number}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    param.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    param.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            
            if (hasAnswer)
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getAnswerBadgeColor(param.answer!).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    param.answer!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getAnswerBadgeColor(param.answer!),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

            const SizedBox(width: 6),

            
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey[400],
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}