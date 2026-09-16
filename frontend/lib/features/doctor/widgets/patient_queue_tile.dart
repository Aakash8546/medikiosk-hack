import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PatientQueueTile extends StatelessWidget {
  final String patientName;
  final String token;
  final String chiefComplaint;
  final String status;
  final VoidCallback? onTap;

  const PatientQueueTile({
    super.key,
    required this.patientName,
    required this.token,
    required this.chiefComplaint,
    this.status = 'waiting',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.primary100,
          child: const Icon(
            Icons.person_rounded,
            color: AppColors.primary700,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Text(
              patientName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: status == 'completed'
                    ? AppColors.success100
                    : status == 'in_consultation'
                        ? AppColors.info100
                        : AppColors.neutral100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status.replaceAll('_', ' ').toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: status == 'completed'
                      ? AppColors.success700
                      : status == 'in_consultation'
                          ? AppColors.info700
                          : AppColors.neutral500,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Token: $token',
              style: const TextStyle(fontSize: 12, color: AppColors.neutral500),
            ),
            Text(
              chiefComplaint,
              style: const TextStyle(fontSize: 13, color: AppColors.neutral700),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}