import 'package:flutter/material.dart';
import '../../app/design_tokens.dart';
import '../../app/theme.dart';


class KioskAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? leading;
  final List<Widget>? actions;

  const KioskAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.leading,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: DesignTokens.white,
      foregroundColor: DesignTokens.neutral950,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: leading ??
          (onBack != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  onPressed: onBack,
                )
              : null),
      title: Text(
        title,
        style: MediKioskTheme.bodyMedium.copyWith(
          color: DesignTokens.neutral950,
          fontSize: 18,
        ),
      ),
      actions: actions,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: DesignTokens.neutral200),
      ),
    );
  }
}