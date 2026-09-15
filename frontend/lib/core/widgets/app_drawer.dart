import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:medikiosk/app/design_tokens.dart';
import 'package:medikiosk/features/onboarding/providers/onboarding_provider.dart';

class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
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
    final patientName = session.patientName?.isNotEmpty == true
        ? session.patientName!
        : 'Patient';

    return Drawer(
      backgroundColor: DesignTokens.white,
      width: MediaQuery.of(context).size.width * 0.82,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SidebarX(
                controller: _controller,
                showToggleButton: false,
                theme: SidebarXTheme(
                  margin: EdgeInsets.zero,
                  decoration: const BoxDecoration(
                    color: DesignTokens.white,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: DesignTokens.neutral800,
                  ),
                  selectedTextStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.primary600,
                  ),
                  itemMargin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  selectedItemMargin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  itemPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  selectedItemPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  itemTextPadding: const EdgeInsets.only(left: 14),
                  selectedItemTextPadding: const EdgeInsets.only(left: 14),
                  itemDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  selectedItemDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: DesignTokens.primary50,
                    border: Border.all(
                      color: DesignTokens.primary900,
                    ),
                  ),
                  iconTheme: const IconThemeData(
                    color: DesignTokens.neutral700,
                    size: 22,
                  ),
                  selectedIconTheme: const IconThemeData(
                    color: DesignTokens.primary600,
                    size: 22,
                  ),
                ),
                extendedTheme: SidebarXTheme(
                  width: MediaQuery.of(context).size.width * 0.82,
                  decoration: const BoxDecoration(
                    color: DesignTokens.white,
                  ),
                ),
                headerBuilder: (context, extended) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(
                      DesignTokens.spacingXL,
                      56,
                      DesignTokens.spacingXL,
                      DesignTokens.spacingXL,
                    ),
                    decoration: const BoxDecoration(
                      color: DesignTokens.primary600,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
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
                          onTap: () {
                            Navigator.pop(context);
                            context.go('/profile');
                          },
                          child: Text(
                            'View Profile',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                items: [
                  SidebarXItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/dashboard');
                    },
                  ),
                  SidebarXItem(
                    icon: Icons.receipt_long_rounded,
                    label: 'My Records',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/token');
                    },
                  ),
                  SidebarXItem(
                    icon: Icons.calendar_month_rounded,
                    label: 'Appointments',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/appointment');
                    },
                  ),
                  SidebarXItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & Support',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/help');
                    },
                  ),
                  SidebarXItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  SidebarXItem(
                    icon: Icons.logout_rounded,
                    label: 'Logout',
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(sessionProvider.notifier).clearSession();
                      context.go('/');
                    },
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