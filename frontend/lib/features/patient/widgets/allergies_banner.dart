import 'package:flutter/material.dart';

class AllergiesBanner extends StatelessWidget {
  const AllergiesBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 20, color: Color(0xFFDC2626)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Allergies: Sulfa drugs, Penicillin',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF991B1B)),
            ),
          ),
        ],
      ),
    );
  }
}