import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class EditableSoapField extends StatefulWidget {
  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;

  const EditableSoapField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<EditableSoapField> createState() => _EditableSoapFieldState();
}

class _EditableSoapFieldState extends State<EditableSoapField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary900,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _controller,
          maxLines: null,
          onChanged: widget.onChanged,
          style: const TextStyle(fontSize: 15, color: AppColors.neutral950),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.all(12),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}