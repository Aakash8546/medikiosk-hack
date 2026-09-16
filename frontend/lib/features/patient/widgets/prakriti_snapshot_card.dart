import 'package:flutter/material.dart';

class PrakritiSnapshotCard extends StatefulWidget {
  const PrakritiSnapshotCard({super.key});

  @override
  State<PrakritiSnapshotCard> createState() => _PrakritiSnapshotCardState();
}

class _PrakritiSnapshotCardState extends State<PrakritiSnapshotCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFE0F5F5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF0B6B6A).withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0B6B6A),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🌿',
                        style: TextStyle(fontSize: 10)),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Prakriti Snapshot',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2332)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            const Text(
              'Prakriti: PITTA_VATA | Agni: Madhyama | Lifestyle: Excellent',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151)),
            ),
            const SizedBox(height: 6),
            Text(
              _isExpanded ? 'Tap to collapse' : 'Tap to expand',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0B6B6A)),
            ),
            
            if (_isExpanded) ...[
              const SizedBox(height: 12),
              const Divider(color: Color(0xFF0B6B6A), thickness: 0.5),
              const SizedBox(height: 10),
              _buildDetailRow('Constitution', 'PITTA_VATA (50% Pitta, 41.7% Vata, 8.3% Kapha)'),
              const SizedBox(height: 6),
              _buildDetailRow('Agni', 'Madhyama (Moderate digestive fire)'),
              const SizedBox(height: 6),
              _buildDetailRow('Lifestyle', 'Excellent — Regular exercise, balanced diet'),
              const SizedBox(height: 6),
              _buildDetailRow('Vikriti', 'Vata + Pitta imbalance — bloating, acidity'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            '$label:',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280)),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151)),
          ),
        ),
      ],
    );
  }
}