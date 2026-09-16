import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SourceTraceBadge extends StatelessWidget {
  final String source;
  const SourceTraceBadge({super.key, required this.source});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.info100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.link_rounded, size: 12, color: AppColors.info700),
          const SizedBox(width: 4),
          Text(
            source,
            style: const TextStyle(fontSize: 11, color: AppColors.info700),
          ),
        ],
      ),
    );
  }
}