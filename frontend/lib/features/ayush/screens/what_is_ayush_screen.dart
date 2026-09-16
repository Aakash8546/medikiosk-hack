import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/app/localization/app_localizations.dart';
import 'package:medikiosk/core/utils/responsive.dart';

class WhatIsAyushScreen extends ConsumerStatefulWidget {
  const WhatIsAyushScreen({super.key});

  @override
  ConsumerState<WhatIsAyushScreen> createState() => _WhatIsAyushScreenState();
}

class _WhatIsAyushScreenState extends ConsumerState<WhatIsAyushScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
        child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: r.maxContentWidth ?? double.infinity),
        child: Column(
          children: [
            
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF1A1A2E),
                      size: 20,
                    ),
                    onPressed: () => context.go('/consultation-type'),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 0.2),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, __) => LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF0B6B6A),
                    ),
                  ),
                ),
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
                          offset: Offset(0, 10 * (1 - opacity)),
                          child: child,
                        ),
                      ),
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                              l10n.whatIsAyushTitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: r.fontSize(24),
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A2E),
                                fontFamily: 'NotoSans',
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Text(
                              l10n.whatIsAyushSubtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: r.bodyFontSize,
                                color: const Color(0xFF6B7280),
                                fontFamily: 'NotoSans',
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: r.sectionSpacing * 2),

                    
                    ...List.generate(_categories(l10n).length, (index) {
                      return _buildCategoryCard(index, _categories(l10n)[index]);
                    }),
                    const SizedBox(height: 24),
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
                  onPressed: () => context.go('/ayush'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B6B6A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.next,
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

  

  Widget _buildCategoryCard(int index, _AyushCategory category) {
    
    final delay = index * 0.12;
    final startInterval = delay;
    final endInterval = (delay + 0.4).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final progress = _animController.value;
        final cardOpacity = ((progress - startInterval) / (endInterval - startInterval))
            .clamp(0.0, 1.0);
        final cardSlide = 16 * (1.0 - cardOpacity);

        return Opacity(
          opacity: cardOpacity,
          child: Transform.translate(
            offset: Offset(0, cardSlide),
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
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
                color: category.iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icon,
                size: 22,
                color: category.iconColor,
              ),
            ),
            const SizedBox(width: 16),

            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                      fontFamily: 'NotoSans',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.description,
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
          ],
        ),
      ),
    );
  }
}



class _AyushCategory {
  final String title;
  final String description;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  const _AyushCategory({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });
}

List<_AyushCategory> _categories(AppLocalizations l10n) => [
  _AyushCategory(
    title: l10n.prakritiTitle,
    description: l10n.prakritiCardDesc,
    icon: Icons.eco_rounded,
    iconBgColor: Color(0xFFE8F5E9),
    iconColor: Color(0xFF4CAF50),
  ),
  _AyushCategory(
    title: l10n.vikritiTitle,
    description: l10n.vikritiCardDesc,
    icon: Icons.person_rounded,
    iconBgColor: Color(0xFFE8F5E9),
    iconColor: Color(0xFF388E3C),
  ),
  _AyushCategory(
    title: l10n.agniTitle,
    description: l10n.agniCardDesc,
    icon: Icons.local_fire_department_rounded,
    iconBgColor: Color(0xFFFFF3E0),
    iconColor: Color(0xFFFF9800),
  ),
  _AyushCategory(
    title: l10n.koshthaTitle,
    description: l10n.koshthaCardDesc,
    icon: Icons.monitor_heart_rounded,
    iconBgColor: Color(0xFFFFF3E0),
    iconColor: Color(0xFFFF7043),
  ),
  _AyushCategory(
    title: l10n.aharaViharaTitle,
    description: l10n.aharaViharaCardDesc,
    icon: Icons.spa_rounded,
    iconBgColor: Color(0xFFE8F5E9),
    iconColor: Color(0xFF66BB6A),
  ),
];