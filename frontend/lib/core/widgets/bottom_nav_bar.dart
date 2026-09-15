import 'package:flutter/material.dart';
import '../../app/design_tokens.dart';
import '../../app/localization/app_localizations.dart';

enum NavTab { home, token, scan, profile, more }

class BottomNavBar extends StatelessWidget {
  final NavTab activeTab;
  final ValueChanged<NavTab> onTabChanged;

  const BottomNavBar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: DesignTokens.white,
        border: Border(
          top: BorderSide(color: DesignTokens.neutral200, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingMD,
            vertical: DesignTokens.spacingXS,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: l10n.navHome,
                isActive: activeTab == NavTab.home,
                onTap: () => onTabChanged(NavTab.home),
              ),
              _NavItem(
                icon: Icons.token_rounded,
                label: l10n.navToken,
                isActive: activeTab == NavTab.token,
                onTap: () => onTabChanged(NavTab.token),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: l10n.navProfile,
                isActive: activeTab == NavTab.profile,
                onTap: () => onTabChanged(NavTab.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? DesignTokens.primary500 : DesignTokens.neutral500,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? DesignTokens.primary500 : DesignTokens.neutral500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}