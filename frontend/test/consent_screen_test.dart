import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/features/consent/providers/consent_provider.dart';
import 'package:medikiosk/features/consent/screens/consent_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:medikiosk/app/localization/app_localizations.dart';
import 'package:medikiosk/features/onboarding/providers/onboarding_provider.dart';
import 'package:medikiosk/services/api_service.dart';


class GatedApiService extends ApiService {
  final Completer<void> gate = Completer<void>();

  @override
  Future<Map<String, dynamic>> createConsent({
    required String sessionId,
    required String decision,
    required String consentType,
  }) async {
    await gate.future;
    return {'id': 'consent-1'};
  }
}


class ExplodingApiService extends ApiService {
  @override
  Future<Map<String, dynamic>> createConsent({
    required String sessionId,
    required String decision,
    required String consentType,
  }) async {
    throw StateError('createConsent must not be called without a session');
  }
}



class NoNetworkSessionNotifier extends SessionNotifier {
  NoNetworkSessionNotifier({required String patientId}) {
    state = state.copyWith(patientId: patientId, language: 'en');
  }

  @override
  Future<bool> createSession({
    required String patientId,
    String sessionType = 'GENERAL',
    String language = 'en',
  }) async {
    return false; 
  }
}


enum SessionSetup {
  
  none,

  
  patientOnly,

  
  full,
}

Widget buildApp({
  ApiService? api,
  SessionSetup session = SessionSetup.full,
}) {
  final router = GoRouter(
    initialLocation: '/consent',
    routes: [
      GoRoute(path: '/consent', builder: (_, __) => const ConsentScreen()),
      GoRoute(
        path: '/consultation-type',
        builder: (_, __) =>
            const Scaffold(body: Center(child: Text('consultation-type'))),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      if (session != SessionSetup.none)
        sessionProvider.overrideWith((ref) {
          if (session == SessionSetup.patientOnly) {
            return NoNetworkSessionNotifier(patientId: 'p-1');
          }
          final notifier = SessionNotifier();
          notifier.state = notifier.state.copyWith(
            sessionId: 'sess-1',
            patientId: 'p-1',
            language: 'en',
          );
          return notifier;
        }),
      consentProvider.overrideWith(
        (ref) => ConsentNotifier(
          api ?? (session == SessionSetup.full
              ? GatedApiService()
              : ExplodingApiService()),
          ref.read(sessionProvider.notifier),
        ),
      ),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      supportedLocales: const [Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    ),
  );
}




Future<void> expectSpinnerOnlyOn(
  WidgetTester tester,
  GatedApiService api, {
  required String tapped,
  required String other,
  bool expectNavigation = true,
}) async {
  await tester.binding.setSurfaceSize(const Size(800, 1400));
  expect(find.byType(CircularProgressIndicator), findsNothing);

  await tester.ensureVisible(find.text(tapped));
  await tester.pump();
  await tester.tap(find.text(tapped));
  await tester.pump(const Duration(milliseconds: 100));

  
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
  final spinnerButton = tester.widget<ButtonStyleButton>(
    find.ancestor(
      of: find.byType(CircularProgressIndicator),
      matching: find.bySubtype<ButtonStyleButton>(),
    ),
  );
  expect(
    find.descendant(of: find.byWidget(spinnerButton), matching: find.text(tapped)),
    findsOneWidget,
  );

  
  final otherButton = tester.widget<ButtonStyleButton>(
    find.ancestor(
      of: find.text(other),
      matching: find.bySubtype<ButtonStyleButton>(),
    ),
  );
  expect(otherButton.onPressed, isNull);

  
  api.gate.complete();
  await tester.pumpAndSettle();

  expect(find.byType(CircularProgressIndicator), findsNothing);
  if (expectNavigation) {
    expect(find.text('consultation-type'), findsOneWidget);
  }
}

void main() {
  testWidgets('shows a session error banner when no patient is in session',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    await tester.pumpWidget(buildApp(session: SessionSetup.none));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('No patient found'),
      findsOneWidget,
    );
  });

  testWidgets(
      'decline-all shows the specific error when both submissions fail',
      (tester) async {
    await tester.pumpWidget(buildApp(session: SessionSetup.patientOnly));
    await tester.pumpAndSettle();

    expect(
      find.text('No active session. Please go back and try again.'),
      findsNothing,
    );

    await tester.ensureVisible(find.text('Decline All'));
    await tester.pump();
    await tester.tap(find.text('Decline All'));
    await tester.pumpAndSettle();

    
    
    expect(
      find.text('No active session. Please go back and try again.'),
      findsWidgets,
    );
    expect(find.text('Failed to record consent'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('tapping Accept All shows a spinner only on the Accept button',
      (tester) async {
    final api = GatedApiService();
    await tester.pumpWidget(buildApp(api: api));
    await tester.pumpAndSettle();

    await expectSpinnerOnlyOn(
      tester,
      api,
      tapped: 'Accept All & Continue',
      other: 'Decline All',
    );
  });

  testWidgets('tapping Decline All shows a spinner only on the Decline button',
      (tester) async {
    final api = GatedApiService();
    await tester.pumpWidget(buildApp(api: api));
    await tester.pumpAndSettle();

    await expectSpinnerOnlyOn(
      tester,
      api,
      tapped: 'Decline All',
      other: 'Accept All & Continue',
      expectNavigation: false,
    );
  });
}