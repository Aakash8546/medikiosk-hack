import 'package:flutter/material.dart';

class CurrentMedicationsCard extends StatelessWidget {
  const CurrentMedicationsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final medications = [
      'Tab Aspirin 75mg — Once daily',
      'Tab Pantoprazole 40mg — Before breakfast',
      'Cap Triphala — Twice daily (Ayurvedic)',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: medications.map((med) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    '•',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2332)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    med,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                        height: 1.4),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}