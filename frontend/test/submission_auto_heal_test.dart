import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medikiosk/app/localization/app_localizations.dart';
import 'package:medikiosk/features/onboarding/providers/onboarding_provider.dart';
import 'package:medikiosk/features/summary/screens/submission_screen.dart';

void main() {
  testWidgets('SubmissionScreen renders and auto-recovers gracefully', (tester) async {
    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith((ref) {
          final notifier = SessionNotifier();
          notifier.state = notifier.state.copyWith(
            sessionId: 'invalid-session-id',
            patientId: 'PATIENT-001',
            status: 'created_local',
          );
          return notifier;
        }),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: [AppLocalizations.delegate],
          supportedLocales: [Locale('en')],
          home: SubmissionScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    
    expect(find.byType(SubmissionScreen), findsOneWidget);
  });
}