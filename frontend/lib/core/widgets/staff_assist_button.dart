import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StaffAssistButton extends StatelessWidget {
  final VoidCallback onPressed;

  const StaffAssistButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _showPinDialog(context),
      icon: const Icon(Icons.support_agent_rounded, size: 20),
      label: const Text('Staff Assist'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.neutral500,
      ),
    );
  }

  void _showPinDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Staff PIN'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Enter staff PIN',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              
              onPressed();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}