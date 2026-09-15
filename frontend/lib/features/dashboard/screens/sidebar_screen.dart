import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:medikiosk/app/design_tokens.dart';
import 'package:medikiosk/features/onboarding/providers/onboarding_provider.dart';

class SidebarScreen extends ConsumerStatefulWidget {
  const SidebarScreen({super.key});

  @override
  ConsumerState<SidebarScreen> createState() => _SidebarScreenState();
}

class _SidebarScreenState extends ConsumerState<SidebarScreen> {
  late final SidebarXController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SidebarXController(selectedIndex: 0, extended: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final patientName = session.patientName ?? 'Patient';

    return Scaffold(
      backgroundColor: DesignTokens.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  SidebarX(
                    controller: _controller,
                    showToggleButton: false,
                    theme: SidebarXTheme(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: DesignTokens.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: DesignTokens.neutral800,
                      ),
                      selectedTextStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.primary600,
                      ),
                      itemMargin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      selectedItemMargin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      itemPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      selectedItemPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      itemTextPadding: const EdgeInsets.only(left: 12),
                      selectedItemTextPadding: const EdgeInsets.only(left: 12),
                      itemDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      selectedItemDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: DesignTokens.primary50,
                        border: Border.all(
                          color: DesignTokens.primary600,
                        ),
                      ),
                      iconTheme: const IconThemeData(
                        color: DesignTokens.neutral700,
                        size: 20,
                      ),
                      selectedIconTheme: const IconThemeData(
                        color: DesignTokens.primary600,
                        size: 20,
                      ),
                    ),
                    extendedTheme: SidebarXTheme(
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                        color: DesignTokens.white,
                      ),
                    ),
                    footerDivider: const Divider(color: DesignTokens.neutral200, height: 1),
                    headerBuilder: (context, extended) {
                      return Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(
                          DesignTokens.spacingXL,
                          extended ? 36 : 16,
                          DesignTokens.spacingXL,
                          extended ? DesignTokens.spacingXL : 16,
                        ),
                        decoration: const BoxDecoration(
                          color: DesignTokens.primary600,
                        ),
                        child: Column(
                          crossAxisAlignment: extended
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: extended ? 56 : 40,
                              height: extended ? 56 : 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                size: extended ? 28 : 20,
                                color: Colors.white,
                              ),
                            ),
                            if (extended) ...[
                              const SizedBox(height: DesignTokens.spacingMD),
                              Text(
                                patientName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () => context.go('/profile'),
                                child: Text(
                                  'View Profile',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                    items: [
                      SidebarXItem(
                        icon: Icons.home_rounded,
                        label: 'Home',
                        onTap: () => context.go('/dashboard'),
                      ),
                      SidebarXItem(
                        icon: Icons.receipt_long_rounded,
                        label: 'My Records',
                        onTap: () => context.go('/token'),
                      ),
                      SidebarXItem(
                        icon: Icons.calendar_month_rounded,
                        label: 'Appointments',
                        onTap: () => context.go('/appointment'),
                      ),
                      SidebarXItem(
                        icon: Icons.help_outline_rounded,
                        label: 'Help & Support',
                        onTap: () => context.go('/help'),
                      ),
                      SidebarXItem(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        onTap: () {},
                      ),
                      SidebarXItem(
                        icon: Icons.logout_rounded,
                        label: 'Logout',
                        onTap: () {
                          ref.read(sessionProvider.notifier).clearSession();
                          context.go('/');
                        },
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
}