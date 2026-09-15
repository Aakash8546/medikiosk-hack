import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/app/localization/app_localizations.dart';









Future<bool> confirmLeaveAssessment(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (_) => _LeaveAssessmentDialog(l10n: l10n),
  );
  return result ?? false;
}

class _LeaveAssessmentDialog extends StatelessWidget {
  final AppLocalizations l10n;

  const _LeaveAssessmentDialog({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFD97706),
                size: 30,
              ),
            ),
            const SizedBox(height: 16),

            
            Text(
              l10n.leaveAssessmentTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            
            Text(
              l10n.leaveAssessmentDescription,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            
            Row(
              children: [
                
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(
                        color: Color(0xFF374151),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.leave,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}










class AssessmentBackButton extends StatelessWidget {
  final String route;
  final Widget child;
  final VoidCallback? onPressed;

  const AssessmentBackButton({
    super.key,
    required this.route,
    required this.child,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (onPressed != null) {
          onPressed!();
          return;
        }
        final shouldLeave = await confirmLeaveAssessment(context);
        if (shouldLeave && context.mounted) {
          context.go(route);
        }
      },
      child: child,
    );
  }
}




class AssessmentBackHandler extends StatefulWidget {
  final String route;
  final Widget child;

  const AssessmentBackHandler({
    super.key,
    required this.route,
    required this.child,
  });

  @override
  State<AssessmentBackHandler> createState() => _AssessmentBackHandlerState();
}

class _AssessmentBackHandlerState extends State<AssessmentBackHandler> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLeave = await confirmLeaveAssessment(context);
        if (shouldLeave && context.mounted) {
          context.go(widget.route);
        }
      },
      child: widget.child,
    );
  }
}