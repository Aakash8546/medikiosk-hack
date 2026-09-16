import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medikiosk/app/localization/app_localizations.dart';
import 'package:medikiosk/features/interview/providers/interview_provider.dart';
import 'package:medikiosk/features/summary/screens/ai_summary_screen.dart';
import 'package:medikiosk/services/api_service.dart';
import 'package:medikiosk/services/audio_interview_service.dart';

class FakeApiService extends ApiService {}
class FakeAudioService extends AudioInterviewService {}

void main() {
  testWidgets('ClinicalSummaryScreen renders custom vomiting patient history', (tester) async {
    final mockInterviewState = InterviewState(
      status: 'completed',
      finalSummary: 'Patient presents with severe vomiting since 3 days.',
      structuredHistory: const {
        'chief_complaint': 'vomiting',
        'history_of_present_illness': {
          'onset': '3 days ago',
          'character': 'frequent after meals',
          'location': 'upper abdomen',
          'severity': '7/10',
          'associated_symptoms': ['dizziness', 'nausea'],
        },
        'past_medical_history': [],
        'medications': [],
        'allergies': [],
        'family_history': [],
        'personal_history': 'Non-smoker',
        'review_of_systems': ['vomiting', 'dizziness'],
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          interviewProvider.overrideWith((ref) {
            final notifier = InterviewNotifier(FakeApiService(), FakeAudioService());
            notifier.state = mockInterviewState;
            return notifier;
          }),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
          ],
          home: ClinicalSummaryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    print('Checking rendered Chief Complaint (vomiting)...');
    expect(find.text('vomiting'), findsWidgets);

    print('Checking rendered HPI details (3 days ago)...');
    expect(find.textContaining('ONSET: 3 days ago'), findsWidgets);

    print('Checking rendered HPI details (frequent after meals)...');
    expect(find.textContaining('CHARACTER: frequent after meals'), findsWidgets);

    print('Checking rendered HPI details (upper abdomen)...');
    expect(find.textContaining('LOCATION: upper abdomen'), findsWidgets);

    print('Checking rendered Associated Symptoms (dizziness, nausea)...');
    expect(find.textContaining('dizziness, nausea'), findsWidgets);

    print('Checking Medications (None)...');
    expect(find.text('None'), findsWidgets);

    print('Checking Allergies (No known allergies)...');
    expect(find.text('No known allergies.'), findsWidgets);

    print('CUSTOM VOMITING CLINICAL SUMMARY VERIFIED 100% ACCURATE!');
  });
}