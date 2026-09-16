import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/timeline_event.dart';

class TimelineWidget extends StatelessWidget {
  final List<TimelineEvent> events;
  const TimelineWidget({super.key, required this.events});

  static const _icons = {
    'visit': Icons.local_hospital_rounded,
    'lab': Icons.science_rounded,
    'prescription': Icons.medication_rounded,
    'procedure': Icons.medical_services_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.primary100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _icons[event.type] ?? Icons.circle,
                    size: 16,
                    color: AppColors.primary700,
                  ),
                ),
                if (index < events.length - 1)
                  Container(width: 2, height: 40, color: AppColors.neutral200),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral950,
                      ),
                    ),
                    if (event.description != null)
                      Text(
                        event.description!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.neutral500,
                        ),
                      ),
                    Text(
                      '${event.date.day}/${event.date.month}/${event.date.year}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.neutral400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}