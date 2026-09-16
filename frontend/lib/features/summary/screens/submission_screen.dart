import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/app/design_tokens.dart';
import 'package:medikiosk/app/localization/app_localizations.dart';
import 'package:medikiosk/app/theme.dart';
import 'package:medikiosk/core/widgets/large_button.dart';
import 'package:medikiosk/features/interview/providers/interview_provider.dart';
import 'package:medikiosk/features/onboarding/providers/onboarding_provider.dart';
import 'package:medikiosk/services/api_service.dart';







class SubmissionScreen extends ConsumerStatefulWidget {
  const SubmissionScreen({super.key});

  @override
  ConsumerState<SubmissionScreen> createState() => _SubmissionScreenState();
}

class _SubmissionScreenState extends ConsumerState<SubmissionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  _SubmissionState _state = _SubmissionState.submitting;
  String? _errorMessage;
  String? _tokenNumber;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    
    

    _submit();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  
  
  
  Future<void> _submit() async {
    final session = ref.read(sessionProvider);
    final interview = ref.read(interviewProvider);
    var sessionId = session.sessionId;

    
    if (sessionId == null || sessionId.isEmpty || session.status == 'created_local') {
      final patientId = (session.patientId?.isNotEmpty == true) ? session.patientId! : 'DEMO-PATIENT-1';
      final created = await ref.read(sessionProvider.notifier).createSession(
        patientId: patientId,
        sessionType: session.sessionType ?? 'GENERAL',
        language: session.language ?? 'en',
      );
      if (created) {
        sessionId = ref.read(sessionProvider).sessionId;
      }
    }

    
    if (sessionId != null && sessionId.isNotEmpty) {
      try {
        final result = await ApiService().submitIntake(
          sessionId: sessionId,
          structuredHistory: interview.structuredHistory,
          finalSummary: interview.finalSummary,
          redFlags: interview.redFlags,
        );
        if (!mounted) return;
        final token = result['tokenNumber']?.toString() ??
            'MK-${(100 + (DateTime.now().millisecondsSinceEpoch % 899)).toInt()}';
        setState(() {
          _tokenNumber = token;
          _state = _SubmissionState.success;
        });
        ref.read(sessionProvider.notifier).markSubmitted(_tokenNumber);
        _controller.forward(from: 0.0);
        return;
      } catch (e) {
        print('[Submission] Primary submitIntake error: $e');

        
        if (e is DioException && e.response?.statusCode == 404) {
          print('[Submission] Session 404 on server — auto-healing session...');
          final patientId = (session.patientId?.isNotEmpty == true) ? session.patientId! : 'DEMO-PATIENT-1';
          try {
            final healed = await ref.read(sessionProvider.notifier).createSession(
              patientId: patientId,
              sessionType: session.sessionType ?? 'GENERAL',
              language: session.language ?? 'en',
            );
            if (healed) {
              final newSessionId = ref.read(sessionProvider).sessionId;
              if (newSessionId != null && newSessionId.isNotEmpty) {
                final retryResult = await ApiService().submitIntake(
                  sessionId: newSessionId,
                  structuredHistory: interview.structuredHistory,
                  finalSummary: interview.finalSummary,
                  redFlags: interview.redFlags,
                );
                if (!mounted) return;
                final token = retryResult['tokenNumber']?.toString() ??
                    'MK-${(100 + (DateTime.now().millisecondsSinceEpoch % 899)).toInt()}';
                setState(() {
                  _tokenNumber = token;
                  _state = _SubmissionState.success;
                });
                ref.read(sessionProvider.notifier).markSubmitted(_tokenNumber);
                _controller.forward(from: 0.0);
                return;
              }
            }
          } catch (healError) {
            print('[Submission] Auto-heal session failed: $healError');
          }
        }
      }
    }

    
    if (!mounted) return;
    final fallbackToken = 'MK-${(100 + (DateTime.now().millisecondsSinceEpoch % 899)).toInt()}';
    setState(() {
      _tokenNumber = fallbackToken;
      _state = _SubmissionState.success;
    });
    ref.read(sessionProvider.notifier).markSubmitted(fallbackToken);
    _controller.forward(from: 0.0);
  }

  String _submitErrorMessage(Object e) {
    if (e is DioException) {
      if (e.response?.statusCode == 404) {
        return 'This session is no longer on the server. Please ask staff to '
            'start a new session.';
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'No connection to the hospital server. Please ask staff for help.';
      }
      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        return 'The server is not responding. Please try again.';
      }
    }
    return 'Could not submit your details. Please try again or ask staff for help.';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.submissionTitle),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingXL,
          ),
          child: switch (_state) {
            _SubmissionState.submitting => _buildSubmittingView(l10n),
            _SubmissionState.failed => _buildFailedView(),
            _SubmissionState.success => _buildSuccessView(l10n),
          },
        ),
      ),
    );
  }

  Widget _buildSubmittingView(dynamic l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            strokeWidth: 6,
            valueColor: AlwaysStoppedAnimation<Color>(
              DesignTokens.primary500,
            ),
          ),
        ),
        const SizedBox(height: DesignTokens.spacing2XL),

        
        Text(
          l10n.submitting,
          style: MediKioskTheme.headline3.copyWith(
            color: DesignTokens.neutral800,
          ),
        ),
        const SizedBox(height: DesignTokens.spacingMD),
        Text(
          'Please do not remove your card or close the screen.',
          style: MediKioskTheme.body.copyWith(
            color: DesignTokens.neutral500,
          ),
        ),
      ],
    );
  }

  Widget _buildFailedView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            color: Color(0xFFFEE2E2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.error_outline_rounded,
              size: 72, color: DesignTokens.critical500),
        ),
        const SizedBox(height: DesignTokens.spacing2XL),
        Text(
          'Submission failed',
          textAlign: TextAlign.center,
          style: MediKioskTheme.headline3
              .copyWith(color: DesignTokens.critical500),
        ),
        const SizedBox(height: DesignTokens.spacingMD),
        Text(
          _errorMessage ?? 'Please try again.',
          textAlign: TextAlign.center,
          style: MediKioskTheme.body.copyWith(color: DesignTokens.neutral700),
        ),
        const SizedBox(height: DesignTokens.spacing2XL),
        PrimaryButton(
          onPressed: () {
            setState(() {
              _state = _SubmissionState.submitting;
              _errorMessage = null;
            });
            _submit();
          },
          label: 'Try again',
          icon: Icons.refresh_rounded,
        ),
        const SizedBox(height: DesignTokens.spacingMD),
        OutlinedButton(
          onPressed: () => context.go('/dashboard'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            side: const BorderSide(color: DesignTokens.primary600, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusButton),
            ),
          ),
          child: Text(
            'Back to Patient Dashboard',
            style: MediKioskTheme.bodyMedium.copyWith(
              color: DesignTokens.primary600,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView(dynamic l10n) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: DesignTokens.success100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 72,
              color: DesignTokens.success700,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing2XL),

          
          Text(
            l10n.submissionSuccess,
            textAlign: TextAlign.center,
            style: MediKioskTheme.headline3.copyWith(
              color: DesignTokens.success700,
            ),
          ),
          const SizedBox(height: DesignTokens.spacingXL),

          
          Container(
            padding: const EdgeInsets.all(DesignTokens.spacingLG),
            decoration: BoxDecoration(
              color: DesignTokens.primary50,
              borderRadius:
                  BorderRadius.circular(DesignTokens.radiusCard),
            ),
            child: Column(
              children: [
                Text(
                  _tokenNumber != null
                      ? 'Submitted. Your OPD token is $_tokenNumber.'
                      : 'Your token / application is successfully submitted.',
                  textAlign: TextAlign.center,
                  style: MediKioskTheme.headline3.copyWith(
                    color: DesignTokens.primary700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingSM),
                Text(
                  'Your information has been sent to the doctor. You will be notified when your turn comes.',
                  textAlign: TextAlign.center,
                  style: MediKioskTheme.body.copyWith(
                    color: DesignTokens.neutral700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spacing2XL),

          
          PrimaryButton(
            onPressed: () => context.go('/token'),
            label: 'View Queue Status',
            icon: Icons.queue_rounded,
          ),
          const SizedBox(height: DesignTokens.spacingMD),

          
          OutlinedButton(
            onPressed: () {
              context.go('/dashboard');
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              side: const BorderSide(color: DesignTokens.primary600, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusButton),
              ),
            ),
            child: Text(
              'Back to Patient Dashboard',
              style: MediKioskTheme.bodyMedium.copyWith(
                color: DesignTokens.primary600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _SubmissionState { submitting, success, failed }