import 'package:medikiosk/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/features/ayush/providers/ayush_provider.dart';
import 'package:medikiosk/app/localization/app_localizations.dart';



class AssessmentQuestion {
  final String title;
  final String subtitle;
  final List<AssessmentOption> options;
  const AssessmentQuestion({
    required this.title,
    required this.subtitle,
    required this.options,
  });
}

class AssessmentOption {
  final String label;
  final String description;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  const AssessmentOption({
    required this.label,
    required this.description,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });
}

class AssessmentStep {
  final String title;
  final String subtitle;
  final List<AssessmentQuestion> questions;
  const AssessmentStep({
    required this.title,
    required this.subtitle,
    required this.questions,
  });
}



const List<AssessmentStep> _assessmentSteps = [
  
  AssessmentStep(
    title: 'Prakriti Assessment',
    subtitle: 'Step 1 of 8',
    questions: [
      AssessmentQuestion(
        title: '1. Body Frame',
        subtitle: 'Which body frame best describes you?',
        options: [
          AssessmentOption(
            label: 'Thin',
            description: 'Slim build, narrow shoulders, light body frame',
            icon: Icons.person_outline_rounded,
            iconBgColor: Color(0xFFE8EAF6),
            iconColor: Color(0xFF5C6BC0),
          ),
          AssessmentOption(
            label: 'Medium',
            description: 'Moderate build, well proportioned body frame',
            icon: Icons.person_rounded,
            iconBgColor: Color(0xFFE8F5E9),
            iconColor: Color(0xFF4CAF50),
          ),
          AssessmentOption(
            label: 'Large',
            description: 'Heavy build, broad shoulders, stocky structure',
            icon: Icons.accessibility_new_rounded,
            iconBgColor: Color(0xFFFFF3E0),
            iconColor: Color(0xFFFF9800),
          ),
        ],
      ),
      AssessmentQuestion(
        title: '2. Skin Type',
        subtitle: 'Select the option that matches your skin.',
        options: [
          AssessmentOption(
            label: 'Dry',
            description: 'Rough, dry, tendency to crack',
            icon: Icons.water_drop_outlined,
            iconBgColor: Color(0xFFE3F2FD),
            iconColor: Color(0xFF42A5F5),
          ),
          AssessmentOption(
            label: 'Normal',
            description: 'Soft, smooth, moist, clear',
            icon: Icons.water_drop_rounded,
            iconBgColor: Color(0xFFE8F5E9),
            iconColor: Color(0xFF66BB6A),
          ),
          AssessmentOption(
            label: 'Oily',
            description: 'Oily, thick, prone to acne or rashes',
            icon: Icons.opacity_rounded,
            iconBgColor: Color(0xFFFFF3E0),
            iconColor: Color(0xFFFF9800),
          ),
        ],
      ),
      AssessmentQuestion(
        title: '3. Appetite',
        subtitle: 'How would you describe your appetite?',
        options: [
          AssessmentOption(
            label: 'Moderate',
            description: 'Regular hunger, enjoys food',
            icon: Icons.restaurant_rounded,
            iconBgColor: Color(0xFFE8F5E9),
            iconColor: Color(0xFF388E3C),
          ),
          AssessmentOption(
            label: 'Low',
            description: 'Low hunger, eats small portions',
            icon: Icons.restaurant_outlined,
            iconBgColor: Color(0xFFE3F2FD),
            iconColor: Color(0xFF42A5F5),
          ),
          AssessmentOption(
            label: 'High',
            description: 'Strong hunger, large portions, frequent cravings',
            icon: Icons.lunch_dining_rounded,
            iconBgColor: Color(0xFFFFF3E0),
            iconColor: Color(0xFFFF9800),
          ),
        ],
      ),
    ],
  ),
  
  AssessmentStep(
    title: 'Prakriti Assessment',
    subtitle: 'Step 2 of 8',
    questions: [
      AssessmentQuestion(
        title: '4. Digestion',
        subtitle: 'How is your digestion typically?',
        options: [
          AssessmentOption(
            label: 'Irregular',
            description: 'Sometimes fast, sometimes slow, bloating common',
            icon: Icons.speed_rounded,
            iconBgColor: Color(0xFFE8EAF6),
            iconColor: Color(0xFF5C6BC0),
          ),
          AssessmentOption(
            label: 'Strong',
            description: 'Quick digestion, good metabolism, rarely bloated',
            icon: Icons.bolt_rounded,
            iconBgColor: Color(0xFFE8F5E9),
            iconColor: Color(0xFF4CAF50),
          ),
          AssessmentOption(
            label: 'Slow',
            description: 'Heavy feeling after meals, slow metabolism',
            icon: Icons.hourglass_bottom_rounded,
            iconBgColor: Color(0xFFFFF3E0),
            iconColor: Color(0xFFFF9800),
          ),
        ],
      ),
      AssessmentQuestion(
        title: '5. Thirst Level',
        subtitle: 'How much water do you typically drink?',
        options: [
          AssessmentOption(
            label: 'Variable',
            description: 'Thirst comes and goes, sometimes forget to drink',
            icon: Icons.water_rounded,
            iconBgColor: Color(0xFFE8EAF6),
            iconColor: Color(0xFF5C6BC0),
          ),
          AssessmentOption(
            label: 'High',
            description: 'Often thirsty, prefers cold water',
            icon: Icons.local_drink_rounded,
            iconBgColor: Color(0xFFE3F2FD),
            iconColor: Color(0xFF42A5F5),
          ),
          AssessmentOption(
            label: 'Low',
            description: 'Rarely thirsty, prefers warm water',
            icon: Icons.emoji_food_beverage_rounded,
            iconBgColor: Color(0xFFE8F5E9),
            iconColor: Color(0xFF4CAF50),
          ),
        ],
      ),
      AssessmentQuestion(
        title: '6. Body Temperature',
        subtitle: 'How do you feel about temperature?',
        options: [
          AssessmentOption(
            label: 'Cold Hands',
            description: 'Often cold, dislike cold weather',
            icon: Icons.ac_unit_rounded,
            iconBgColor: Color(0xFFE3F2FD),
            iconColor: Color(0xFF42A5F5),
          ),
          AssessmentOption(
            label: 'Warm Body',
            description: 'Feel warm, prefer cool environments',
            icon: Icons.thermostat_rounded,
            iconBgColor: Color(0xFFFFF3E0),
            iconColor: Color(0xFFFF9800),
          ),
          AssessmentOption(
            label: 'Balanced',
            description: 'Comfortable in most temperatures',
            icon: Icons.device_thermostat_rounded,
            iconBgColor: Color(0xFFE8F5E9),
            iconColor: Color(0xFF4CAF50),
          ),
        ],
      ),
    ],
  ),
  
  AssessmentStep(
    title: 'Prakriti Assessment',
    subtitle: 'Step 3 of 8',
    questions: [
      AssessmentQuestion(
        title: '7. Sleep Pattern',
        subtitle: 'How would you describe your sleep?',
        options: [
          AssessmentOption(
            label: 'Light',
            description: 'Light sleeper, easily disturbed, wakes often',
            icon: Icons.bedtime_outlined,
            iconBgColor: Color(0xFFE8EAF6),
            iconColor: Color(0xFF5C6BC0),
          ),
          AssessmentOption(
            label: 'Moderate',
            description: 'Regular sleep, 6-8 hours, fall asleep easily',
            icon: Icons.bedtime_rounded,
            iconBgColor: Color(0xFFE8F5E9),
            iconColor: Color(0xFF4CAF50),
          ),
          AssessmentOption(
            label: 'Deep',
            description: 'Heavy sleeper, hard to wake, sleeps long hours',
            icon: Icons.rounded_corner_rounded,
            iconBgColor: Color(0xFFE3F2FD),
            iconColor: Color(0xFF42A5F5),
          ),
        ],
      ),
      AssessmentQuestion(
        title: '8. Physical Activity',
        subtitle: 'What is your typical activity level?',
        options: [
          AssessmentOption(
            label: 'Active',
            description: 'Energetic, enjoys运动, gets restless without it',
            icon: Icons.directions_run_rounded,
            iconBgColor: Color(0xFFE8EAF6),
            iconColor: Color(0xFF5C6BC0),
          ),
          AssessmentOption(
            label: 'Moderate',
            description: 'Balanced activity, enjoys both rest and exercise',
            icon: Icons.fitness_center_rounded,
            iconBgColor: Color(0xFFE8F5E9),
            iconColor: Color(0xFF4CAF50),
          ),
          AssessmentOption(
            label: 'Low',
            description: 'Prefers rest, avoids strenuous activity',
            icon: Icons.weekend_rounded,
            iconBgColor: Color(0xFFE3F2FD),
            iconColor: Color(0xFF42A5F5),
          ),
        ],
      ),
      AssessmentQuestion(
        title: '9. Sweating',
        subtitle: 'How do you typically sweat?',
        options: [
          AssessmentOption(
            label: 'Minimal',
            description: 'Hardly sweats even in heat',
            icon: Icons.water_drop_outlined,
            iconBgColor: Color(0xFFE8EAF6),
            iconColor: Color(0xFF5C6BC0),
          ),
          AssessmentOption(
            label: 'Moderate',
            description: 'Sweats normally during exercise or heat',
            icon: Icons.sensors_rounded,
            iconBgColor: Color(0xFFFFF3E0),
            iconColor: Color(0xFFFF9800),
          ),
          AssessmentOption(
            label: 'Excessive',
            description: 'Sweats a lot, even with mild activity',
            icon: Icons.water_drop_rounded,
            iconBgColor: Color(0xFFE3F2FD),
            iconColor: Color(0xFF42A5F5),
          ),
        ],
      ),
    ],
  ),
  
  AssessmentStep(
    title: 'Prakriti Assessment',
    subtitle: 'Step 4 of 8',
    questions: [
      AssessmentQuestion(
        title: '10. Memory',
        subtitle: 'How is your memory typically?',
        options: [
          AssessmentOption(
            label: 'Quick Learn',
            description: 'Learns fast but may forget quickly',
            icon: Icons.bolt_rounded,
            iconBgColor: Color(0xFFE8EAF6),
            iconColor: Color(0xFF5C6BC0),
          ),
          AssessmentOption(
            label: 'Sharp',
            description: 'Good memory, remembers details well',
            icon: Icons.psychology_rounded,
            iconBgColor: Color(0xFFE8F5E9),
            iconColor: Color(0xFF4CAF50),
          ),
          AssessmentOption(
            label: 'Slow Steady',
            description: 'Learns slowly but retains well',
            icon: Icons.auto_stories_rounded,
            iconBgColor: Color(0xFFE3F2FD),
            iconColor: Color(0xFF42A5F5),
          ),
        ],
      ),
      AssessmentQuestion(
        title: '11. Stress Response',
        subtitle: 'How do you typically handle stress?',
        options: [
          AssessmentOption(
            label: 'Anxious',
            description: 'Worries easily, overthinks, restless under stress',
            icon: Icons.psychology_alt_rounded,
            iconBgColor: Color(0xFFE8EAF6),
            iconColor: Color(0xFF5C6BC0),
          ),
          AssessmentOption(
            label: 'Irritable',
            description: 'Gets angry, frustrated, takes action under stress',
            icon: Icons.mood_rounded,
            iconBgColor: Color(0xFFFFF3E0),
            iconColor: Color(0xFFFF9800),
          ),
          AssessmentOption(
            label: 'Calm',
            description: 'Stays composed, patient, slow to react',
            icon: Icons.sentiment_satisfied_alt_rounded,
            iconBgColor: Color(0xFFE8F5E9),
            iconColor: Color(0xFF4CAF50),
          ),
        ],
      ),
      AssessmentQuestion(
        title: '12. Social Nature',
        subtitle: 'How do you prefer socializing?',
        options: [
          AssessmentOption(
            label: 'Adaptable',
            description: 'Can be social or alone, adapts to situations',
            icon: Icons.swap_horiz_rounded,
            iconBgColor: Color(0xFFE8EAF6),
            iconColor: Color(0xFF5C6BC0),
          ),
          AssessmentOption(
            label: 'Outgoing',
            description: 'Enjoys being around people, leadership qualities',
            icon: Icons.groups_rounded,
            iconBgColor: Color(0xFFFFF3E0),
            iconColor: Color(0xFFFF9800),
          ),
          AssessmentOption(
            label: 'Reserved',
            description: 'Prefers small groups, enjoys solitude',
            icon: Icons.person_outline_rounded,
            iconBgColor: Color(0xFFE3F2FD),
            iconColor: Color(0xFF42A5F5),
          ),
        ],
      ),
    ],
  ),
  
  AssessmentStep(
    title: 'Prakriti Assessment',
    subtitle: 'Step 5 of 8',
    questions: [
      AssessmentQuestion(
        title: '13. Hair Quality',
        subtitle: 'How would you describe your hair?',
        options: [
          AssessmentOption(
            label: 'Dry & Frizzy',
            description: 'Rough texture, tends to be dry and tangled',
            icon: Icons.content_cut_rounded,
            iconBgColor: Color(0xFFE8EAF6),
            iconColor: Color(0xFF5C6BC0),
          ),
          AssessmentOption(
            label: 'Fine & Oily',
            description: 'Thin, gets oily quickly, good shine',
            icon: Icons.straighten_rounded,
            iconBgColor: Color(0xFFE8F5E9),
            iconColor: Color(0xFF4CAF50),
          ),
          AssessmentOption(
            label: 'Thick & Wavy',
            description: 'Dense, lustrous, holds style well',
            icon: Icons.waves_rounded,
            iconBgColor: Color(0xFFE3F2FD),
            iconColor: Color(0xFF42A5F5),
          ),
        ],
      ),
      AssessmentQuestion(
        title: '14. Eye Type',
        subtitle: 'Which best describes your eyes?',
        options: [
          AssessmentOption(
            label: 'Small & Dry',
            description: 'Small, active, darting movement',
            icon: Icons.remove_red_eye_outlined,
            iconBgColor: Color(0xFFE8EAF6),
            iconColor: Color(0xFF5C6BC0),
          ),
          AssessmentOption(
            label: 'Sharp & Bright',
            description: 'Medium sized, piercing, light-sensitive',
            icon: Icons.visibility_rounded,
            iconBgColor: Color(0xFFE8F5E9),
            iconColor: Color(0xFF4CAF50),
          ),
          AssessmentOption(
            label: 'Large & Calm',
            description: 'Big, calm gaze, long lashes',
            icon: Icons.visibility_rounded,
            iconBgColor: Color(0xFFE3F2FD),
            iconColor: Color(0xFF42A5F5),
          ),
        ],
      ),
      AssessmentQuestion(
        title: '15. Face Shape',
        subtitle: 'What is your face shape?',
        options: [
          AssessmentOption(
            label: 'Narrow',
            description: 'Long, angular features, prominent jawline',
            icon: Icons.face_rounded,
            iconBgColor: Color(0xFFE8EAF6),
            iconColor: Color(0xFF5C6BC0),
          ),
          AssessmentOption(
            label: 'Medium',
            description: 'Proportionate features, defined jaw',
            icon: Icons.face_6_rounded,
            iconBgColor: Color(0xFFFFF3E0),
            iconColor: Color(0xFFFF9800),
          ),
          AssessmentOption(
            label: 'Round',
            description: 'Full cheeks, soft jawline, broad forehead',
            icon: Icons.face_3_rounded,
            iconBgColor: Color(0xFFE3F2FD),
            iconColor: Color(0xFF42A5F5),
          ),
        ],
      ),
    ],
  ),
  
  AssessmentStep(
    title: 'Prakriti Assessment',
    subtitle: 'Step 6 of 8',
    questions: [
      AssessmentQuestion(
        title: '16. Speech Pattern',
        subtitle: 'How would you describe your way of speaking?',
        options: [
          AssessmentOption(
            label: 'Fast & Talkative',
            description: 'Speaks quickly, lots of words, enthusiastic',
            icon: Icons.record_voice_over_rounded,
            iconBgColor: Color(0xFFE8EAF6),
            iconColor: Color(0xFF5C6BC0),
          ),
          AssessmentOption(
            label: 'Clear & Direct',
            description: 'Speaks with conviction, persuasive tone',
            icon: Icons.mic_rounded,
            iconBgColor: Color(0xFFFFF3E0),
            iconColor: Color(0xFFFF9800),
          ),
          AssessmentOption(
            label: 'Soft & Steady',
            description: 'Speaks slowly, few words, pleasant voice',
            icon: Icons.volume_down_rounded,
            iconBgColor: Color(0xFFE8F5E9),
            iconColor: Color(0xFF4CAF50),
          ),
        ],
      ),
      AssessmentQuestion(
        title: '17. Food Preferences',
        subtitle: 'What kind of food do you prefer?',
        options: [
          AssessmentOption(
            label: 'Variety',
            description: 'Enjoys variety, snacks often, irregular eating',
            icon: Icons.fastfood_rounded,
            iconBgColor: Color(0xFFE8EAF6),
            iconColor: Color(0xFF5C6BC0),
          ),
          AssessmentOption(
            label: 'Spicy & Salty',
            description: 'Prefers spicy, salty, and bitter foods',
            icon: Icons.local_fire_department_rounded,
            iconBgColor: Color(0xFFFFF3E0),
            iconColor: Color(0xFFFF9800),
          ),
          AssessmentOption(
            label: 'Sweet & Mild',
            description: 'Prefers sweet, mild, and heavy foods',
            icon: Icons.cake_rounded,
            iconBgColor: Color(0xFFE8F5E9),
            iconColor: Color(0xFF4CAF50),
          ),
        ],
      ),
      AssessmentQuestion(
        title: '18. Weather Preference',
        subtitle: 'Which weather do you prefer?',
        options: [
          AssessmentOption(
            label: 'Warm',
            description: 'Prefer warm weather, dislike cold',
            icon: Icons.wb_sunny_rounded,
            iconBgColor: Color(0xFFFFF3E0),
            iconColor: Color(0xFFFF9800),
          ),
          AssessmentOption(
            label: 'Cool',
            description: 'Prefer cool weather, dislike heat',
            icon: Icons.ac_unit_rounded,
            iconBgColor: Color(0xFFE3F2FD),
            iconColor: Color(0xFF42A5F5),
          ),
          AssessmentOption(
            label: 'Any',
            description: 'Comfortable in most weather conditions',
            icon: Icons.cloud_rounded,
            iconBgColor: Color(0xFFE8F5E9),
            iconColor: Color(0xFF4CAF50),
          ),
        ],
      ),
    ],
  ),
  
  AssessmentStep(
    title: 'Prakriti Assessment',
    subtitle: 'Step 7 of 8',
    questions: [
      AssessmentQuestion(
        title: '19. Bowel Habits',
        subtitle: 'How are your bowel movements?',
        options: [
          AssessmentOption(
            label: 'Irregular',
            description: 'Tendency to constipation or gas',
            icon: Icons.health_and_safety_rounded,
            iconBgColor: Color(0xFFE8EAF6),
            iconColor: Color(0xFF5C6BC0),
          ),
          AssessmentOption(
            label: 'Regular',
            description: 'Normal consistency, 1-2 times daily',
            icon: Icons.check_circle_outline_rounded,
            iconBgColor: Color(0xFFE8F5E9),
            iconColor: Color(0xFF4CAF50),
          ),
          AssessmentOption(
            label: 'Loose',
            description: 'Tendency to loose stools or diarrhea',
            icon: Icons.warning_amber_rounded,
            iconBgColor: Color(0xFFFFF3E0),
            iconColor: Color(0xFFFF9800),
          ),
        ],
      ),
      AssessmentQuestion(
        title: '20. Pain Tolerance',
        subtitle: 'How do you handle pain?',
        options: [
          AssessmentOption(
            label: 'Low',
            description: 'Sensitive to pain, can\'t bear it long',
            icon: Icons.healing_rounded,
            iconBgColor: Color(0xFFE8EAF6),
            iconColor: Color(0xFF5C6BC0),
          ),
          AssessmentOption(
            label: 'Medium',
            description: 'Tolerates moderate pain well',
            icon: Icons.medical_services_rounded,
            iconBgColor: Color(0xFFE8F5E9),
            iconColor: Color(0xFF4CAF50),
          ),
          AssessmentOption(
            label: 'High',
            description: 'Can endure pain for long periods',
            icon: Icons.fitness_center_rounded,
            iconBgColor: Color(0xFFE3F2FD),
            iconColor: Color(0xFF42A5F5),
          ),
        ],
      ),
      AssessmentQuestion(
        title: '21. Body Weight',
        subtitle: 'How easy is it for you to maintain weight?',
        options: [
          AssessmentOption(
            label: 'Hard Gain',
            description: 'Difficult to gain weight, naturally slim',
            icon: Icons.trending_down_rounded,
            iconBgColor: Color(0xFFE8EAF6),
            iconColor: Color(0xFF5C6BC0),
          ),
          AssessmentOption(
            label: 'Stable',
            description: 'Maintains weight easily with balanced diet',
            icon: Icons.balance_rounded,
            iconBgColor: Color(0xFFE8F5E9),
            iconColor: Color(0xFF4CAF50),
          ),
          AssessmentOption(
            label: 'Easy Gain',
            description: 'Gains weight easily, hard to lose',
            icon: Icons.trending_up_rounded,
            iconBgColor: Color(0xFFFFF3E0),
            iconColor: Color(0xFFFF9800),
          ),
        ],
      ),
    ],
  ),
  
  AssessmentStep(
    title: 'Prakriti Assessment',
    subtitle: 'Step 8 of 8',
    questions: [
      AssessmentQuestion(
        title: '22. Energy Level',
        subtitle: 'How are your energy levels throughout the day?',
        options: [
          AssessmentOption(
            label: 'Variable',
            description: 'Bursts of energy, then tired, restless',
            icon: Icons.electric_bolt_rounded,
            iconBgColor: Color(0xFFE8EAF6),
            iconColor: Color(0xFF5C6BC0),
          ),
          AssessmentOption(
            label: 'High',
            description: 'Consistently energetic, ambitious, driven',
            icon: Icons.battery_full_rounded,
            iconBgColor: Color(0xFFFFF3E0),
            iconColor: Color(0xFFFF9800),
          ),
          AssessmentOption(
            label: 'Steady',
            description: 'Calm energy, consistent throughout day',
            icon: Icons.battery_std_rounded,
            iconBgColor: Color(0xFFE8F5E9),
            iconColor: Color(0xFF4CAF50),
          ),
        ],
      ),
      AssessmentQuestion(
        title: '23. Climate Sensitivity',
        subtitle: 'Which climate bothers you the most?',
        options: [
          AssessmentOption(
            label: 'Cold & Windy',
            description: 'Dislike cold, dry, and windy weather',
            icon: Icons.air_rounded,
            iconBgColor: Color(0xFFE3F2FD),
            iconColor: Color(0xFF42A5F5),
          ),
          AssessmentOption(
            label: 'Hot & Humid',
            description: 'Dislike hot and humid weather, prefer cool',
            icon: Icons.wb_sunny_rounded,
            iconBgColor: Color(0xFFFFF3E0),
            iconColor: Color(0xFFFF9800),
          ),
          AssessmentOption(
            label: 'All Climate',
            description: 'Adaptable to most climate conditions',
            icon: Icons.cloud_rounded,
            iconBgColor: Color(0xFFE8F5E9),
            iconColor: Color(0xFF4CAF50),
          ),
        ],
      ),
      AssessmentQuestion(
        title: '24. Overall Constitution',
        subtitle: 'Which type do you identify with most?',
        options: [
          AssessmentOption(
            label: 'Vata',
            description: 'Air & space — creative, quick-thinking, light',
            icon: Icons.air_rounded,
            iconBgColor: Color(0xFFE8EAF6),
            iconColor: Color(0xFF5C6BC0),
          ),
          AssessmentOption(
            label: 'Pitta',
            description: 'Fire & water — focused, determined, warm',
            icon: Icons.local_fire_department_rounded,
            iconBgColor: Color(0xFFFFF3E0),
            iconColor: Color(0xFFFF9800),
          ),
          AssessmentOption(
            label: 'Kapha',
            description: 'Earth & water — calm, steady, grounded',
            icon: Icons.water_drop_rounded,
            iconBgColor: Color(0xFFE8F5E9),
            iconColor: Color(0xFF4CAF50),
          ),
        ],
      ),
    ],
  ),
];



const List<IconData> _optionIcons = [
  
  Icons.person_outline_rounded, Icons.person_rounded, Icons.accessibility_new_rounded,
  Icons.water_drop_outlined, Icons.water_drop_rounded, Icons.opacity_rounded,
  Icons.restaurant_rounded, Icons.restaurant_outlined, Icons.lunch_dining_rounded,
  
  Icons.speed_rounded, Icons.bolt_rounded, Icons.hourglass_bottom_rounded,
  Icons.water_rounded, Icons.local_drink_rounded, Icons.emoji_food_beverage_rounded,
  Icons.ac_unit_rounded, Icons.thermostat_rounded, Icons.device_thermostat_rounded,
  
  Icons.bedtime_outlined, Icons.bedtime_rounded, Icons.rounded_corner_rounded,
  Icons.directions_run_rounded, Icons.fitness_center_rounded, Icons.weekend_rounded,
  Icons.water_drop_outlined, Icons.sensors_rounded, Icons.water_drop_rounded,
  
  Icons.bolt_rounded, Icons.psychology_rounded, Icons.auto_stories_rounded,
  Icons.psychology_alt_rounded, Icons.mood_rounded, Icons.sentiment_satisfied_alt_rounded,
  Icons.swap_horiz_rounded, Icons.groups_rounded, Icons.person_outline_rounded,
  
  Icons.content_cut_rounded, Icons.straighten_rounded, Icons.waves_rounded,
  Icons.remove_red_eye_outlined, Icons.visibility_rounded, Icons.visibility_rounded,
  Icons.face_rounded, Icons.face_6_rounded, Icons.face_3_rounded,
  
  Icons.record_voice_over_rounded, Icons.mic_rounded, Icons.volume_down_rounded,
  Icons.fastfood_rounded, Icons.local_fire_department_rounded, Icons.cake_rounded,
  Icons.wb_sunny_rounded, Icons.ac_unit_rounded, Icons.cloud_rounded,
  
  Icons.health_and_safety_rounded, Icons.check_circle_outline_rounded, Icons.warning_amber_rounded,
  Icons.healing_rounded, Icons.medical_services_rounded, Icons.fitness_center_rounded,
  Icons.trending_down_rounded, Icons.balance_rounded, Icons.trending_up_rounded,
  
  Icons.electric_bolt_rounded, Icons.battery_full_rounded, Icons.battery_std_rounded,
  Icons.air_rounded, Icons.wb_sunny_rounded, Icons.cloud_rounded,
  Icons.air_rounded, Icons.local_fire_department_rounded, Icons.water_drop_rounded,
];

const List<Color> _iconBgColors = [
  Color(0xFFE8EAF6), Color(0xFFE8F5E9), Color(0xFFFFF3E0),
  Color(0xFFE3F2FD), Color(0xFFE8F5E9), Color(0xFFFFF3E0),
  Color(0xFFE8F5E9), Color(0xFFE3F2FD), Color(0xFFFFF3E0),
  Color(0xFFE8EAF6), Color(0xFFE8F5E9), Color(0xFFFFF3E0),
  Color(0xFFE8EAF6), Color(0xFFE3F2FD), Color(0xFFE8F5E9),
  Color(0xFFE3F2FD), Color(0xFFFFF3E0), Color(0xFFE8F5E9),
  Color(0xFFE8EAF6), Color(0xFFE8F5E9), Color(0xFFE3F2FD),
  Color(0xFFE8EAF6), Color(0xFFE8F5E9), Color(0xFFE3F2FD),
  Color(0xFFE8EAF6), Color(0xFFFFF3E0), Color(0xFFE3F2FD),
  Color(0xFFE8EAF6), Color(0xFFE8F5E9), Color(0xFFE3F2FD),
  Color(0xFFE8EAF6), Color(0xFFFFF3E0), Color(0xFFE8F5E9),
  Color(0xFFE8EAF6), Color(0xFFE8F5E9), Color(0xFFE3F2FD),
  Color(0xFFE8EAF6), Color(0xFFE8F5E9), Color(0xFFE3F2FD),
  Color(0xFFE8EAF6), Color(0xFFFFF3E0), Color(0xFFE3F2FD),
  Color(0xFFE8EAF6), Color(0xFFE8F5E9), Color(0xFFE3F2FD),
  Color(0xFFE8EAF6), Color(0xFFFFF3E0), Color(0xFFE8F5E9),
  Color(0xFFE8EAF6), Color(0xFFE8F5E9), Color(0xFFE3F2FD),
  Color(0xFFE8EAF6), Color(0xFFFFF3E0), Color(0xFFE8F5E9),
  Color(0xFFFFF3E0), Color(0xFFE3F2FD), Color(0xFFE8F5E9),
  Color(0xFFE8EAF6), Color(0xFFE8F5E9), Color(0xFFE3F2FD),
  Color(0xFFE8EAF6), Color(0xFFE8F5E9), Color(0xFFFFF3E0),
  Color(0xFFE8EAF6), Color(0xFFE8F5E9), Color(0xFFE3F2FD),
  Color(0xFFE8EAF6), Color(0xFFE8F5E9), Color(0xFFFFF3E0),
  Color(0xFFE8EAF6), Color(0xFFFFF3E0), Color(0xFFE8F5E9),
  Color(0xFFE3F2FD), Color(0xFFFFF3E0), Color(0xFFE8F5E9),
  Color(0xFFE8EAF6), Color(0xFFFFF3E0), Color(0xFFE8F5E9),
];

const List<Color> _iconColors = [
  Color(0xFF5C6BC0), Color(0xFF4CAF50), Color(0xFFFF9800),
  Color(0xFF42A5F5), Color(0xFF66BB6A), Color(0xFFFF9800),
  Color(0xFF388E3C), Color(0xFF42A5F5), Color(0xFFFF9800),
  Color(0xFF5C6BC0), Color(0xFF4CAF50), Color(0xFFFF9800),
  Color(0xFF5C6BC0), Color(0xFF42A5F5), Color(0xFF4CAF50),
  Color(0xFF42A5F5), Color(0xFFFF9800), Color(0xFF4CAF50),
  Color(0xFF5C6BC0), Color(0xFF4CAF50), Color(0xFF42A5F5),
  Color(0xFF5C6BC0), Color(0xFF4CAF50), Color(0xFF42A5F5),
  Color(0xFF5C6BC0), Color(0xFFFF9800), Color(0xFF42A5F5),
  Color(0xFF5C6BC0), Color(0xFF4CAF50), Color(0xFF42A5F5),
  Color(0xFF5C6BC0), Color(0xFFFF9800), Color(0xFF4CAF50),
  Color(0xFF5C6BC0), Color(0xFF4CAF50), Color(0xFF42A5F5),
  Color(0xFF5C6BC0), Color(0xFF4CAF50), Color(0xFF42A5F5),
  Color(0xFF5C6BC0), Color(0xFFFF9800), Color(0xFF42A5F5),
  Color(0xFF5C6BC0), Color(0xFF4CAF50), Color(0xFF42A5F5),
  Color(0xFF5C6BC0), Color(0xFFFF9800), Color(0xFF4CAF50),
  Color(0xFF5C6BC0), Color(0xFFFF9800), Color(0xFF4CAF50),
  Color(0xFFFF9800), Color(0xFF42A5F5), Color(0xFF4CAF50),
  Color(0xFF5C6BC0), Color(0xFF4CAF50), Color(0xFFFF9800),
  Color(0xFF5C6BC0), Color(0xFF4CAF50), Color(0xFF42A5F5),
  Color(0xFF5C6BC0), Color(0xFF4CAF50), Color(0xFFFF9800),
  Color(0xFF5C6BC0), Color(0xFFFF9800), Color(0xFF4CAF50),
  Color(0xFF42A5F5), Color(0xFFFF9800), Color(0xFF4CAF50),
  Color(0xFF5C6BC0), Color(0xFFFF9800), Color(0xFF4CAF50),
];


List<AssessmentStep> _buildLocalizedSteps(AppLocalizations loc) {
  final stepsData = loc.getLocalizedPrakritiSteps();
  int iconIdx = 0;
  return stepsData.map((stepData) {
    final questions = (stepData['questions'] as List<Map<String, Object>>);
    return AssessmentStep(
      title: stepData['title'] as String,
      subtitle: stepData['subtitle'] as String,
      questions: questions.map((qData) {
        final options = (qData['options'] as List<Map<String, String>>);
        return AssessmentQuestion(
          title: qData['title'] as String,
          subtitle: qData['subtitle'] as String,
          options: options.map((oData) {
            final idx = iconIdx++;
            return AssessmentOption(
              label: oData['label']!,
              description: oData['description']!,
              icon: _optionIcons[idx],
              iconBgColor: _iconBgColors[idx],
              iconColor: _iconColors[idx],
            );
          }).toList(),
        );
      }).toList(),
    );
  }).toList();
}



class AyurvedicAssessmentScreen extends ConsumerStatefulWidget {
  const AyurvedicAssessmentScreen({super.key});

  @override
  ConsumerState<AyurvedicAssessmentScreen> createState() =>
      _AyurvedicAssessmentScreenState();
}

class _AyurvedicAssessmentScreenState
    extends ConsumerState<AyurvedicAssessmentScreen> {
  int _currentStep = 0;
  
  final Map<int, Map<int, int>> _answers = {};

  List<AssessmentStep> _localizedSteps(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return _buildLocalizedSteps(loc);
  }

  AssessmentStep _step(BuildContext context) => _localizedSteps(context)[_currentStep];
  bool get _isLastStep => _currentStep == 7;

  bool _allQuestionsAnswered(BuildContext context) {
    final stepAnswers = _answers[_currentStep] ?? {};
    return _step(context).questions.asMap().keys.every(
      (qIdx) => stepAnswers.containsKey(qIdx),
    );
  }

  void _onOptionSelected(int questionIndex, int optionIndex) {
    setState(() {
      _answers.putIfAbsent(_currentStep, () => {});
      _answers[_currentStep]![questionIndex] = optionIndex;
    });
    
    ref.read(prakritiAnswersProvider.notifier).setAnswer(
      _currentStep, questionIndex, optionIndex,
    );
  }

  void _nextStep(BuildContext context) {
    if (!_allQuestionsAnswered(context)) return;
    if (_isLastStep) {
      
      context.go('/vikriti');
    } else {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      context.go('/what-is-ayush');
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            
            _buildHeader(),
            
            _buildStepProgress(),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    
                    _buildInfoCard(context),
                    const SizedBox(height: 24),
                    
                    ...List.generate(_step(context).questions.length, (qIdx) {
                      final question = _step(context).questions[qIdx];
                      return _buildQuestionSection(qIdx, question);
                    }),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1A2E),
              size: 20,
            ),
            onPressed: _prevStep,
          ),
          const Spacer(),
          Column(
            children: [
              Text(
                AppLocalizations.of(context).prakritiHeaderTitle,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                  fontFamily: 'NotoSans',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _step(context).subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  fontFamily: 'NotoSans',
                ),
              ),
            ],
          ),
          const Spacer(),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF0B6B6A), width: 1.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.volume_up_rounded,
                  color: Color(0xFF0B6B6A),
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  'Listen',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B6B6A),
                    fontFamily: 'NotoSans',
                  ),
                ),
              ],
            ),
          ),
      ],
      ),
    );
  }

  

  Widget _buildStepProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(8, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          return Expanded(
            child: Row(
              children: [
                
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isActive ? 20 : 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF0B6B6A)
                        : isCompleted
                            ? const Color(0xFF0B6B6A).withValues(alpha: 0.5)
                            : const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: isActive
                      ? const Center(
                          child: Icon(
                            Icons.circle,
                            size: 6,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                
                if (index < 7)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted
                          ? const Color(0xFF0B6B6A).withValues(alpha: 0.5)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  

  Widget _buildInfoCard(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FAF9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFB2DFDB),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF0B6B6A).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.eco_rounded,
              color: Color(0xFF0B6B6A),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.whatIsPrakritiTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B6B6A),
                    fontFamily: 'NotoSans',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.whatIsPrakritiDesc,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    fontFamily: 'NotoSans',
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF9CA3AF),
            size: 24,
          ),
        ],
      ),
    );
  }

  

  Widget _buildQuestionSection(int questionIndex, AssessmentQuestion question) {
    final stepAnswers = _answers[_currentStep] ?? {};
    final selectedOption = stepAnswers[questionIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        Text(
          question.title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
            fontFamily: 'NotoSans',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          question.subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            fontFamily: 'NotoSans',
          ),
        ),
        const SizedBox(height: 14),

        
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(question.options.length, (optIdx) {
            final option = question.options[optIdx];
            final isSelected = selectedOption == optIdx;
            return Expanded(
              child: GestureDetector(
                onTap: () => _onOptionSelected(questionIndex, optIdx),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  margin: EdgeInsets.only(
                    right: optIdx < question.options.length - 1 ? 10 : 0,
                  ),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFF0FAF9)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0B6B6A)
                          : const Color(0xFFE5E7EB),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: const Color(0xFF0B6B6A).withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Column(
                    children: [
                      
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 48,
                            height: 56,
                            decoration: BoxDecoration(
                              color: option.iconBgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              option.icon,
                              size: 24,
                              color: option.iconColor,
                            ),
                          ),
                          
                          if (isSelected)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: ScaleTransition(
                                scale: AlwaysStoppedAnimation(1.0),
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF0B6B6A),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      
                      Text(
                        option.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? const Color(0xFF0B6B6A)
                              : const Color(0xFF1A1A2E),
                          fontFamily: 'NotoSans',
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      Text(
                        option.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF6B7280),
                          fontFamily: 'NotoSans',
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          
          Row(
            children: [
              
              
              
              
              
              
              
              
              
              
              
              
              
              
              
              
              
              
              
              
              
              
              
              
              
              
              
              
              
              
              
              
              const SizedBox(width: 12),
              
              Expanded(
                child: Builder(
                  builder: (ctx) {
                    final loc = AppLocalizations.of(ctx);
                    final answered = _allQuestionsAnswered(ctx);
                    return ElevatedButton.icon(
                      onPressed: answered ? () => _nextStep(ctx) : null,
                      icon: Icon(
                        _isLastStep
                            ? Icons.check_rounded
                            : Icons.arrow_forward_ios_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: Text(                         _isLastStep ? loc.prakritiFinish : loc.next,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'NotoSans',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: answered
                            ? const Color(0xFF0B6B6A)
                            : const Color(0xFF9CA3AF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FAF9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Builder(
              builder: (ctx) => Row(
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 16,
                    color: Color(0xFF0B6B6A),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(ctx).prakritiPrivacyNotice,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                        fontFamily: 'NotoSans',
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}