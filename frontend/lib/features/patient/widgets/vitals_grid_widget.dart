import 'package:flutter/material.dart';






class VitalsGridWidget extends StatelessWidget {
  
  
  final Map<String, String> vitals;

  const VitalsGridWidget({super.key, this.vitals = const {}});

  
  String _v(String key) {
    final raw = vitals[key];
    if (raw == null || raw.trim().isEmpty || raw == 'Not Checked') return '—';
    return raw;
  }

  bool _measured(String key) => _v(key) != '—';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            children: [
              Expanded(
                child: _VitalCard(
                  label: 'Heart Rate:',
                  value: _v('Heart Rate'),
                  unit: '',
                  icon: Icons.favorite,
                  iconColor: const Color(0xFFEF4444),
                  badge: null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _VitalCard(
                  label: 'BP:',
                  value: _v('Blood Pressure'),
                  unit: '',
                  icon: null,
                  iconColor: null,
                  
                  
                  badge: _measured('Blood Pressure')
                      ? null
                      : const _StatusBadge(
                          text: 'Not taken',
                          bgColor: Color(0xFFF3F4F6),
                          textColor: Color(0xFF6B7280),
                          icon: Icons.remove_circle_outline,
                          iconColor: Color(0xFF9CA3AF),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _VitalCard(
                  label: 'SpO2:',
                  value: _v('SpO2'),
                  unit: '',
                  icon: null,
                  iconColor: null,
                  badge: const _DotBadge(color: Color(0xFF22C55E)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          Row(
            children: [
              Expanded(
                child: _VitalCard(
                  label: 'Temp:',
                  value: _v('Temperature'),
                  unit: '°F',
                  icon: null,
                  iconColor: null,
                  badge: null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _VitalCard(
                  label: 'BMI:',
                  value: _v('BMI'),
                  unit: '',
                  icon: null,
                  iconColor: null,
                  badge: const _StatusBadge(
                    text: 'Overweight',
                    bgColor: Color(0xFFFEF3C7),
                    textColor: Color(0xFF92400E),
                    icon: null,
                    iconColor: null,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _VitalCard(
                  label: 'Resp Rate:',
                  value: _v('Respiratory Rate'),
                  unit: '/min',
                  icon: null,
                  iconColor: null,
                  badge: null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VitalCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData? icon;
  final Color? iconColor;
  final Widget? badge;

  const _VitalCard({
    required this.label,
    required this.value,
    required this.unit,
    this.icon,
    this.iconColor,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280)),
              ),
              if (icon != null) ...[
                const SizedBox(width: 4),
                Icon(icon, size: 14, color: iconColor),
              ],
              if (badge != null) ...[
                const SizedBox(width: 4),
                badge!,
              ],
            ],
          ),
          const SizedBox(height: 4),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2332)),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 2),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    unit,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;
  final IconData? icon;
  final Color? iconColor;

  const _StatusBadge({
    required this.text,
    required this.bgColor,
    required this.textColor,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: iconColor),
            const SizedBox(width: 2),
          ],
          Text(
            text,
            style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: textColor),
          ),
        ],
      ),
    );
  }
}

class _DotBadge extends StatelessWidget {
  final Color color;
  const _DotBadge({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}