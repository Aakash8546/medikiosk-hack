import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/app/design_tokens.dart';
import 'package:medikiosk/app/localization/app_localizations.dart';
import 'package:medikiosk/app/theme.dart';
import 'package:medikiosk/features/interview/providers/interview_provider.dart';
import 'package:medikiosk/features/summary/providers/summary_provider.dart';

class ClinicalSummaryScreen extends ConsumerStatefulWidget {
  const ClinicalSummaryScreen({super.key});

  @override
  ConsumerState<ClinicalSummaryScreen> createState() =>
      _ClinicalSummaryScreenState();
}

class _ClinicalSummaryScreenState extends ConsumerState<ClinicalSummaryScreen> {
  late final Map<String, String> _summary;
  final Map<String, bool> _expandedSections = {};
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final interviewState = ref.read(interviewProvider);
      dynamic extraData;
      try {
        extraData = GoRouterState.of(context).extra;
      } catch (_) {}


      Map<String, dynamic>? structuredHistory = interviewState.structuredHistory;
      String? finalSummaryText = interviewState.finalSummary;

      if (extraData is Map<String, dynamic>) {
        if (extraData['structuredHistory'] is Map<String, dynamic>) {
          structuredHistory = extraData['structuredHistory'] as Map<String, dynamic>;
        }
        if (extraData['finalSummary'] is String) {
          finalSummaryText = extraData['finalSummary'] as String;
        }
      }

      String formatChiefComplaint() {
        if (structuredHistory != null && structuredHistory['chief_complaint'] != null) {
          final val = structuredHistory['chief_complaint'].toString().trim();
          if (val.isNotEmpty && val.toLowerCase() != 'null') return val;
        }
        final liveSummary = ref.read(summaryProvider);
        if (liveSummary?.soapNote != null || liveSummary?.aiGeneratedText != null) {
          return 'Recorded from consultation';
        }
        return 'No chief complaint recorded.';
      }

      String formatHpi() {
        final parts = <String>[];
        if (structuredHistory != null && structuredHistory['history_of_present_illness'] is Map) {
          final hpiMap = structuredHistory['history_of_present_illness'] as Map;
          hpiMap.forEach((k, v) {
            if (v != null && v.toString().trim().isNotEmpty && v.toString().trim() != '[]' && v.toString().trim() != 'null') {
              final formattedKey = k.toString().replaceAll('_', ' ').toUpperCase();
              parts.add('$formattedKey: $v');
            }
          });
        }
        if (parts.isNotEmpty) {
          return parts.join('\n');
        }
        if (finalSummaryText != null && finalSummaryText.trim().isNotEmpty) {
          return finalSummaryText;
        }
        final liveSummary = ref.read(summaryProvider);
        final text = liveSummary?.soapNote ?? liveSummary?.aiGeneratedText;
        if (text != null && text.trim().isNotEmpty) {
          return text;
        }
        return 'No history of present illness recorded.';
      }

      String formatListOrField(String key, String defaultText) {
        if (structuredHistory != null && structuredHistory.containsKey(key)) {
          final val = structuredHistory[key];
          if (val is List && val.isNotEmpty) {
            final validItems = val.map((e) => e.toString()).where((s) => s.trim().isNotEmpty).toList();
            if (validItems.isNotEmpty) return validItems.join(', ');
          } else if (val is Map && val.isNotEmpty) {
            final parts = <String>[];
            val.forEach((k, v) {
              if (v != null && v.toString().trim().isNotEmpty && v.toString().trim() != 'null') {
                parts.add('$k: $v');
              }
            });
            if (parts.isNotEmpty) return parts.join(', ');
          } else if (val != null && val.toString().trim().isNotEmpty && val.toString().trim() != 'null' && val.toString().trim() != '[]') {
            return val.toString().trim();
          }
        }
        return defaultText;
      }

      _summary = {
        'chief_complaint': formatChiefComplaint(),
        'hpi': formatHpi(),
        'past_history': formatListOrField('past_medical_history', 'No past medical history recorded.'),
        'medications': formatListOrField('medications', 'None'),
        'allergies': formatListOrField('allergies', 'No known allergies.'),
        'family_history': formatListOrField('family_history', 'No significant family history.'),
        'personal_history': formatListOrField('personal_history', 'Non-smoker. No alcohol.'),
        'review_of_systems': formatListOrField('review_of_systems', 'Unremarkable.'),
        'prior_investigations': formatListOrField('prior_investigations', 'None reported.'),
      };
      _initialized = true;
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: DesignTokens.white,
      appBar: AppBar(
        title: const Text(
          'Clinical Summary',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: DesignTokens.primary600,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.go('/review-confirm'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingXL,
            vertical: DesignTokens.spacingLG,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
              Container(
                padding: const EdgeInsets.all(DesignTokens.spacingMD),
                decoration: BoxDecoration(
                  color: DesignTokens.warning50,
                  borderRadius:
                      BorderRadius.circular(DesignTokens.radiusInput),
                  border: Border.all(
                    color: DesignTokens.warning200,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: DesignTokens.warning600,
                      size: 24,
                    ),
                    const SizedBox(width: DesignTokens.spacingSM),
                    Expanded(
                      child: Text(
                        l10n.aiGeneratedDraft,
                        style: MediKioskTheme.body.copyWith(
                          color: DesignTokens.warning700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DesignTokens.spacingXL),

              
              Text(
                l10n.patientHistory.toUpperCase(),
                style: MediKioskTheme.headline3.copyWith(
                  color: DesignTokens.neutral900,
                  letterSpacing: 1.0,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: DesignTokens.spacingMD),

              
              _buildSection(
                l10n.chiefComplaint,
                'chief_complaint',
              ),
              _buildSection(
                l10n.historyOfPresentIllness,
                'hpi',
              ),
              _buildSection(
                l10n.pastMedicalHistory,
                'past_history',
              ),
              _buildSection(
                l10n.medications,
                'medications',
              ),
              _buildSection(
                l10n.allergies,
                'allergies',
              ),
              _buildSection(
                l10n.familyHistory,
                'family_history',
              ),
              _buildSection(
                l10n.personalHistory,
                'personal_history',
              ),
              _buildSection(
                l10n.reviewOfSystems,
                'review_of_systems',
              ),
              _buildSection(
                l10n.priorInvestigations,
                'prior_investigations',
              ),

              const SizedBox(height: DesignTokens.spacing2XL),

              
              ElevatedButton(
                onPressed: () => context.go('/submit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.primary600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusButton),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send_rounded, size: 20),
                    const SizedBox(width: DesignTokens.spacingSM),
                    Text(
                      l10n.submit,
                      style: MediKioskTheme.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DesignTokens.spacingMD),

              
              OutlinedButton(
                onPressed: () => context.go('/review-confirm'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: DesignTokens.primary600,
                  side: const BorderSide(color: DesignTokens.primary600, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusButton),
                  ),
                ),
                child: Text(
                  l10n.editLabel,
                  style: MediKioskTheme.bodyMedium.copyWith(
                    color: DesignTokens.primary600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String key) {
    final isExpanded = _expandedSections[key] ?? true;
    final content = _summary[key] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacingSM),
      elevation: 0,
      color: DesignTokens.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusCard),
        side: const BorderSide(
          color: DesignTokens.neutral200,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _expandedSections[key] = !isExpanded;
          });
        },
        borderRadius: BorderRadius.circular(DesignTokens.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: MediKioskTheme.bodyMedium.copyWith(
                            color: DesignTokens.primary700,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        if (!isExpanded && content.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            content,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: MediKioskTheme.caption.copyWith(
                              color: DesignTokens.neutral500,
                            ),

                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: DesignTokens.neutral500,
                  ),
                ],
              ),


              
              if (isExpanded) ...[
                const SizedBox(height: DesignTokens.spacingMD),
                const Divider(height: 1, color: DesignTokens.neutral200),
                const SizedBox(height: DesignTokens.spacingMD),
                Text(
                  content,
                  style: MediKioskTheme.body.copyWith(
                    color: DesignTokens.neutral700,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingSM),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      final controller = TextEditingController(text: content);
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Edit $title'),
                          content: TextField(
                            controller: controller,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter updated information...',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _summary[key] = controller.text;
                                });
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('$title updated successfully.')),
                                );
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: Text(
                      'Edit',
                      style: MediKioskTheme.caption.copyWith(
                        color: DesignTokens.primary700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}