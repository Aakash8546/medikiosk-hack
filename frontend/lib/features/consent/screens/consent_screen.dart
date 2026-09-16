import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/app/providers/locale_provider.dart';
import 'package:medikiosk/features/consent/providers/consent_provider.dart';
import 'package:medikiosk/app/localization/app_localizations.dart';
import 'package:medikiosk/features/onboarding/providers/onboarding_provider.dart';

class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  bool _dataConsent = false;
  bool _aiConsent = false;
  bool _sessionReady = false;
  bool _isAccepting = false;
  bool _isDeclining = false;
  String? _sessionError;

  @override
  void initState() {
    super.initState();
    _createSession();
  }

  
  Future<void> _createSession() async {
    final session = ref.read(sessionProvider);
    final patientId = session.patientId;

    if (patientId == null || patientId.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _sessionError = AppLocalizations.of(context).consentSessionError;
          });
        }
      });
      return;
    }

    
    final existingId = session.sessionId;
    if (existingId != null && existingId.isNotEmpty) {
      print('[Consent] Session already exists: $existingId (type: ${session.sessionType})');
      if (mounted) setState(() => _sessionReady = true);
      return;
    }

    
    final sessionType = session.mode == 'ayush' ? 'AYUSH' : 'GENERAL';
    print('[Consent] Creating session for patient: $patientId (type: $sessionType)');
    final success = await ref.read(sessionProvider.notifier).createSession(
      patientId: patientId,
      sessionType: sessionType,
      language: session.language ?? 'en',
    );

    if (mounted) {
      setState(() {
        _sessionReady = true;
        if (!success) {
          _sessionError = null; 
        }
      });
    }
  }

  
  
  
  Future<void> _submitDecision({required bool accept}) async {
    if (_isAccepting || _isDeclining) return;
    setState(() {
      if (accept) {
        _isAccepting = true;
        _dataConsent = true;
        _aiConsent = true;
      } else {
        _isDeclining = true;
        _dataConsent = false;
        _aiConsent = false;
      }
    });

    final consentNotifier = ref.read(consentProvider.notifier);
    final success = await consentNotifier.submitBoth(
      decision: accept ? 'ACCEPTED' : 'DECLINED',
      granted: accept,
    );

    if (!mounted) return;

    setState(() {
      if (accept) {
        _isAccepting = false;
      } else {
        _isDeclining = false;
      }
    });

    final isError = !success;
    final errorMsg = ref.read(consentProvider).errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isError
              ? (errorMsg ?? AppLocalizations.of(context).consentFailedRecord)
              : (accept
                  ? AppLocalizations.of(context).consentRecordedSuccess
                  : AppLocalizations.of(context).consentDeclinedMsg),
        ),
        backgroundColor: isError
            ? const Color(0xFFDC2626)
            : (accept ? const Color(0xFF166534) : const Color(0xFFDC2626)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );

    if (accept) {
      context.go('/consultation-type');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7F7),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.consentScreenTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A2332)),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              final codes = ['en', 'hi', 'ta', 'bn', 'te', 'mr'];
              final current = ref.read(localeProvider).languageCode;
              final idx = codes.indexOf(current);
              final next = codes[(idx + 1) % codes.length];
              ref.read(localeProvider.notifier).setLanguageCode(next);
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                l10n.nextLanguage,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF00796B)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          
          _buildProgressStepper(l10n),
          const SizedBox(height: 8),

          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  
                  if (_sessionError != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, size: 18, color: Color(0xFFDC2626)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _sessionError!,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF991B1B), fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),

                  
                  _buildMainCard(l10n),
                  const SizedBox(height: 16),

                  
                  _buildSectionHeader(l10n),
                  const SizedBox(height: 12),

                  
                  _buildConsentCard(
                    l10n: l10n,
                    number: '1',
                    title: l10n.consentDataTitle,
                    description: l10n.consentDataDesc,
                    bullets: [
                            l10n.consentDataBullet1,
                            l10n.consentDataBullet2,
                            l10n.consentDataBullet3,
                            l10n.consentDataBullet4,
                          ],
                    icon: Icons.storage_rounded,
                    iconLabel: 'DATA_COLLECTION',
                    agreed: _dataConsent,
                    radioLabel: l10n.consentDataRadio,
                    onToggle: () => setState(() => _dataConsent = !_dataConsent),
                  ),
                  const SizedBox(height: 16),

                  
                  _buildConsentCard(
                    l10n: l10n,
                    number: '2',
                    title: l10n.consentAiTitle,
                    description: l10n.consentAiDesc,
                    bullets: [
                            l10n.consentAiBullet1,
                            l10n.consentAiBullet2,
                            l10n.consentAiBullet3,
                          ],
                    icon: Icons.psychology_rounded,
                    iconLabel: 'AI_PROCESSING',
                    agreed: _aiConsent,
                    radioLabel: l10n.consentAiRadio,
                    onToggle: () => setState(() => _aiConsent = !_aiConsent),
                  ),
                  const SizedBox(height: 16),

                  
                  _buildWithdrawalNotice(l10n),
                  const SizedBox(height: 16),

                  
                  _buildActionButtons(l10n),
                  const SizedBox(height: 12),

                  
                  _buildFooterNote(l10n),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildProgressStepper(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _step(1, l10n.consentStepLanguage, true, true),
          _line(true),
          _step(2, l10n.consentStepInputMode, true, true),
          _line(true),
          _step(3, l10n.consentStepConsent, false, true),
          _line(false),
          _step(4, l10n.consentStepStartInterview, false, false),
        ],
      ),
    );
  }

  Widget _step(int number, String label, bool completed, bool active) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed
                  ? const Color(0xFF00796B)
                  : active
                      ? const Color(0xFF00796B)
                      : const Color(0xFFE5E7EB),
              border: Border.all(
                color: completed || active ? const Color(0xFF00796B) : const Color(0xFFD1D5DB),
                width: 2,
              ),
            ),
            child: Center(
              child: completed
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : Text(
                      '$number',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: active ? Colors.white : const Color(0xFF9CA3AF),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? const Color(0xFF00796B) : const Color(0xFF9CA3AF),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _line(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: active ? const Color(0xFF00796B) : const Color(0xFFE5E7EB),
      ),
    );
  }

  
  
  
  Widget _buildMainCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2F1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_rounded, size: 28, color: Color(0xFF00796B)),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.consentMainTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF00796B)),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.consentMainDesc,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2F1),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.description_rounded, size: 32, color: Color(0xFF00796B)),
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00796B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, size: 14, color: Colors.white),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00796B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 12, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildSectionHeader(AppLocalizations l10n) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        l10n.consentSectionHeader,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A2332)),
      ),
    );
  }

  
  
  
  Widget _buildConsentCard({
    required AppLocalizations l10n,
    required String number,
    required String title,
    required String description,
    required List<String> bullets,
    required IconData icon,
    required String iconLabel,
    required bool agreed,
    required String radioLabel,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0F2F1),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(icon, size: 36, color: Color(0xFF00796B)),
                          Positioned(
                            right: 4,
                            bottom: 4,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: Color(0xFF00796B),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, size: 11, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      iconLabel,
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF00796B), letterSpacing: 0.5),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$number. $title',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF00796B)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.4),
                      ),
                      const SizedBox(height: 10),
                      ...bullets.map((b) => Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF00796B)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    b,
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF374151), height: 1.3),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          GestureDetector(
            onTap: onToggle,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: agreed ? const Color(0xFFF0FDF4) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: agreed ? const Color(0xFF00796B) : const Color(0xFFE5E7EB),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    agreed ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    size: 22,
                    color: agreed ? const Color(0xFF00796B) : const Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      radioLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: agreed ? const Color(0xFF00796B) : const Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildWithdrawalNotice(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_outline_rounded, size: 20, color: Color(0xFF00796B)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.consentWithdrawal,
              style: const TextStyle(fontSize: 13, color: Color(0xFF374151), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildActionButtons(AppLocalizations l10n) {
    final consentState = ref.watch(consentProvider);

    return Column(
      children: [
        
        if (consentState.status == ConsentStatus.error && consentState.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 18, color: Color(0xFFDC2626)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      consentState.errorMessage!,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF991B1B), fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Row(
          children: [
            
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isAccepting || _isDeclining
                    ? null
                    : () => _submitDecision(accept: false),
                icon: _isDeclining
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFDC2626)))
                    : const Icon(Icons.close_rounded, size: 20),
                label: Text(
                  l10n.consentDeclineAll,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isAccepting || _isDeclining
                    ? null
                    : () => _submitDecision(accept: true),
                icon: _isAccepting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_circle_rounded, size: 20),
                label: Text(
                  l10n.consentAcceptAll,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  backgroundColor: const Color(0xFF00796B),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF00796B).withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  
  
  
  Widget _buildFooterNote(AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.shield_rounded, size: 18, color: Color(0xFF00796B)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            l10n.consentFooter,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.4),
          ),
        ),
      ],
    );
  }
}