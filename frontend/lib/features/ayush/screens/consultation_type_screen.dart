import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/app/design_tokens.dart';
import 'package:medikiosk/app/localization/app_localizations.dart';
import 'package:medikiosk/core/utils/responsive.dart';
import 'package:medikiosk/features/onboarding/providers/onboarding_provider.dart';

class ConsultationTypeScreen extends ConsumerStatefulWidget {
  const ConsultationTypeScreen({super.key});

  @override
  ConsumerState<ConsultationTypeScreen> createState() =>
      _ConsultationTypeScreenState();
}

class _ConsultationTypeScreenState
    extends ConsumerState<ConsultationTypeScreen>
    with SingleTickerProviderStateMixin {
  String _selectedType = 'ayush';
  bool _isCreatingSession = false;
  String? _sessionError;

  
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _glowAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onCardTap(String type) {
    if (_selectedType == type) return;
    setState(() {
      _selectedType = type;
      _sessionError = null;
    });
    
    _animController.reset();
    _animController.forward();
  }

  Future<void> _onContinue() async {
    final session = ref.read(sessionProvider);
    final patientId = session.patientId;
    final language = session.language ?? 'en';
    final sessionType = _selectedType == 'ayush' ? 'AYUSH' : 'GENERAL';

    if (patientId == null || patientId.isEmpty) {
      setState(() {
        _sessionError = 'No patient found. Please register or login first.';
      });
      return;
    }

    setState(() {
      _isCreatingSession = true;
      _sessionError = null;
    });

    try {
      
      ref.read(sessionProvider.notifier).setMode(
        _selectedType == 'ayush' ? 'ayush' : 'general',
      );

      
      final success = await ref.read(sessionProvider.notifier).createSession(
        patientId: patientId,
        sessionType: sessionType,
        language: language,
      );

      if (!mounted) return;

      if (success) {
        final sessionId = ref.read(sessionProvider).sessionId;
        print('[ConsultationType] Session created: $sessionId (type: $sessionType)');

        if (_selectedType == 'ayush') {
          context.go('/what-is-ayush');
        } else {
          context.go('/mode-selection');
        }
      } else {
        
        print('[ConsultationType] Session created locally (server unavailable)');
        if (_selectedType == 'ayush') {
          context.go('/what-is-ayush');
        } else {
          context.go('/mode-selection');
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sessionError = 'Failed to create session: ${e.toString()}';
        _isCreatingSession = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: DesignTokens.white,
      body: SafeArea(
        child: Center(
        child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: r.maxContentWidth ?? double.infinity),
        child: Column(
          children: [
            
            Padding(
              padding: EdgeInsets.fromLTRB(r.horizontalPadding, 8, r.horizontalPadding, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: DesignTokens.neutral800,
                      size: 20,
                    ),
                    onPressed: () => context.go('/consent'),
                  ),
                  const SizedBox(width: 8),
                  
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 0.3),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        builder: (_, value, __) => LinearProgressIndicator(
                          value: value,
                          minHeight: 8,
                          backgroundColor: DesignTokens.neutral200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF0B6B6A),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: r.sectionSpacing * 1.5),

                    
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      builder: (_, opacity, child) => Opacity(
                        opacity: opacity,
                        child: Transform.translate(
                          offset: Offset(0, 12 * (1 - opacity)),
                          child: child,
                        ),
                      ),
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                              l10n.consultationTypeTitle,
                              style: TextStyle(
                                fontSize: r.fontSize(24),
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A2E),
                                fontFamily: 'NotoSans',
                              ),
                            ),
                          ),
                          SizedBox(height: r.optionSpacing),
                          Center(
                            child: Text(
                              l10n.consultationTypeSubtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: r.bodyFontSize,
                                color: Color(0xFF6B7280),
                                fontFamily: 'NotoSans',
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: r.sectionSpacing * 2),

                    
                    _AnimatedConsultationCard(
                      icon: Icons.spa_rounded,
                      title: l10n.ayushConsultation,
                      description:
                          l10n.ayushConsultationDesc,
                      isSelected: _selectedType == 'ayush',
                      scaleAnimation: _scaleAnimation,
                      glowAnimation: _glowAnimation,
                      onTap: () => _onCardTap('ayush'),
                    ),
                    SizedBox(height: r.sectionSpacing),

                    
                    _AnimatedConsultationCard(
                      icon: Icons.add_rounded,
                      title: l10n.generalConsultation,
                      description:
                          l10n.generalConsultationDesc,
                      isSelected: _selectedType == 'general',
                      scaleAnimation: _scaleAnimation,
                      glowAnimation: _glowAnimation,
                      onTap: () => _onCardTap('general'),
                    ),
                    SizedBox(height: r.sectionSpacing * 2),

                    
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOut,
                      builder: (_, opacity, child) => Opacity(
                        opacity: opacity,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - opacity)),
                          child: child,
                        ),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FAF9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFB2DFDB),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 20,
                              color: Color(0xFF0B6B6A),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.consultationTypeInfo,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF374151),
                                  fontFamily: 'NotoSans',
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            
            if (_sessionError != null)
              Padding(
                padding: EdgeInsets.fromLTRB(r.horizontalPadding, 0, r.horizontalPadding, 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFEF4444), width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _sessionError!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFDC2626),
                            fontFamily: 'NotoSans',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            
            Padding(
              padding: EdgeInsets.fromLTRB(r.horizontalPadding, 0, r.horizontalPadding, 24),
              child: SizedBox(
                width: double.infinity,
                height: r.buttonHeight,
                child: ElevatedButton(
                  onPressed: _isCreatingSession ? null : _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B6B6A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isCreatingSession
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          l10n.continueLabel,
                          style: TextStyle(
                            fontSize: r.buttonFontSize + 3,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'NotoSans',
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ),
          ],
          ),
          ),
        ),
      ),
    );
  }
}


class _AnimatedConsultationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final Animation<double> scaleAnimation;
  final Animation<double> glowAnimation;
  final VoidCallback onTap;

  const _AnimatedConsultationCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.scaleAnimation,
    required this.glowAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FAF9) : DesignTokens.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF0B6B6A) : DesignTokens.neutral200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF0B6B6A).withValues(alpha: 0.08 * glowAnimation.value),
                blurRadius: 12 * glowAnimation.value,
                spreadRadius: 2 * glowAnimation.value,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 48,
              height: 48,
              decoration: BoxDecoration(                color: isSelected
                    ? const Color(0xFF0B6B6A).withValues(alpha: 0.15)
                    : const Color(0xFFE8F5F3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 24,
                color: const Color(0xFF0B6B6A),
              ),
            ),
            const SizedBox(width: 16),

            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color(0xFF0B6B6A)
                          : const Color(0xFF1A1A2E),
                      fontFamily: 'NotoSans',
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF6B7280),
                      fontFamily: 'NotoSans',
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            
            ScaleTransition(
              scale: scaleAnimation,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1.0 : 0.0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0B6B6A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}