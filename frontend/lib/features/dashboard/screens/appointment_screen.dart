import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/app/design_tokens.dart';
import 'package:medikiosk/app/theme.dart';
import 'package:medikiosk/core/widgets/kiosk_app_bar.dart';
import 'package:medikiosk/core/widgets/large_button.dart';





class AppointmentScreen extends ConsumerStatefulWidget {
  const AppointmentScreen({super.key});

  @override
  ConsumerState<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends ConsumerState<AppointmentScreen> {
  String _selectedDept = 'General Medicine';
  int _selectedDate = 3; 
  String _selectedTime = '09:30 AM';

  static const _departments = [
    'General Medicine',
    'Cardiology',
    'Dermatology',
    'Orthopedics',
    'Pediatrics',
  ];

  static const _days = [
    ('Sun', '25'),
    ('Mon', '26'),
    ('Tue', '27'),
    ('Wed', '28'),
    ('Thu', '29'),
  ];

  static const _times = [
    '09:00 AM', '09:30 AM', '10:00 AM',
    '10:30 AM', '11:00 AM', '11:30 AM',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KioskAppBar(
        title: 'Book Appointment',
        onBack: () => context.go('/sidebar'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.spacingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Text(
              'Select Department',
              style: MediKioskTheme.bodyMedium.copyWith(
                color: DesignTokens.neutral800,
              ),
            ),
            const SizedBox(height: DesignTokens.spacingSM),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingMD,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: DesignTokens.neutral300),
                borderRadius:
                    BorderRadius.circular(DesignTokens.radiusInput),
              ),
              child: DropdownButton<String>(
                value: _selectedDept,
                isExpanded: true,
                underline: const SizedBox(),
                items: _departments.map((d) {
                  return DropdownMenuItem(value: d, child: Text(d));
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedDept = v);
                },
              ),
            ),
            const SizedBox(height: DesignTokens.spacingXL),

            
            Text(
              'Select Date',
              style: MediKioskTheme.bodyMedium.copyWith(
                color: DesignTokens.neutral800,
              ),
            ),
            const SizedBox(height: DesignTokens.spacingMD),
            Row(
              children: List.generate(_days.length, (index) {
                final (day, date) = _days[index];
                final isSelected = _selectedDate == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDate = index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacingXS,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: DesignTokens.spacingMD,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? DesignTokens.primary500
                            : DesignTokens.white,
                        borderRadius:
                            BorderRadius.circular(DesignTokens.radiusInput),
                        border: Border.all(
                          color: isSelected
                              ? DesignTokens.primary500
                              : DesignTokens.neutral200,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            day,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? DesignTokens.white
                                  : DesignTokens.neutral500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? DesignTokens.white
                                  : DesignTokens.neutral950,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: DesignTokens.spacingXL),

            
            Text(
              'Select Time',
              style: MediKioskTheme.bodyMedium.copyWith(
                color: DesignTokens.neutral800,
              ),
            ),
            const SizedBox(height: DesignTokens.spacingMD),
            Wrap(
              spacing: DesignTokens.spacingSM,
              runSpacing: DesignTokens.spacingSM,
              children: _times.map((time) {
                final isSelected = _selectedTime == time;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTime = time),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spacingMD,
                      vertical: DesignTokens.spacingSM,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? DesignTokens.primary500
                          : DesignTokens.white,
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusInput),
                      border: Border.all(
                        color: isSelected
                            ? DesignTokens.primary500
                            : DesignTokens.neutral300,
                      ),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? DesignTokens.white
                            : DesignTokens.neutral700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: DesignTokens.spacing2XL),

            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                onPressed: () => context.go('/token'),
                label: 'Confirm Appointment',
              ),
            ),
          ],
        ),
      ),
    );
  }
}