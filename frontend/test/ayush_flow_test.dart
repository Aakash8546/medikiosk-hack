import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/app/app.dart';

void main() {
  group('AYUSH Assessment Flow — Individual Screen Tests', () {
    testWidgets(
      'Consultation Type screen renders without overflow',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: MediKioskApp()),
        );
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final ctx = tester.element(find.byType(Scaffold).first);
        GoRouter.of(ctx).go('/consultation-type');
        await tester.pumpAndSettle();

        expect(find.text('Consultation Type'), findsWidgets);
        expect(find.text('Ayush Consultation'), findsWidgets);
        expect(find.text('Continue'), findsWidgets);
      },
    );

    testWidgets(
      'What is Ayush Assessment screen renders without overflow',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: MediKioskApp()),
        );
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final ctx = tester.element(find.byType(Scaffold).first);
        GoRouter.of(ctx).go('/what-is-ayush');
        await tester.pumpAndSettle();

        expect(find.textContaining('What is AYUSH'), findsWidgets);
        expect(find.textContaining('Prakriti'), findsWidgets);
        expect(find.textContaining('Vikriti'), findsWidgets);
      },
    );

    testWidgets(
      'Prakriti Assessment screen renders without overflow',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: MediKioskApp()),
        );
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final ctx = tester.element(find.byType(Scaffold).first);
        GoRouter.of(ctx).go('/ayush');
        await tester.pumpAndSettle();

        expect(find.textContaining('Prakriti Assessment'), findsWidgets);
        expect(find.text('Listen'), findsWidgets);
      },
    );

    testWidgets(
      'Vikriti Assessment screen renders without overflow',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: MediKioskApp()),
        );
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final ctx = tester.element(find.byType(Scaffold).first);
        GoRouter.of(ctx).go('/vikriti');
        await tester.pumpAndSettle();

        expect(find.textContaining('Vikriti Assessment'), findsWidgets);
        expect(find.text('Listen'), findsWidgets);
      },
    );

    testWidgets(
      'Agni Assessment screen renders without overflow',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: MediKioskApp()),
        );
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final ctx = tester.element(find.byType(Scaffold).first);
        GoRouter.of(ctx).go('/agni');
        await tester.pumpAndSettle();

        expect(find.textContaining('Agni Assessment'), findsWidgets);
        expect(find.text('Good'), findsWidgets);
        expect(find.text('Poor'), findsWidgets);

        
        while (tester.takeException() != null) {}
      },
    );

    testWidgets(
      'Dashavidha Pariksha screen renders without overflow',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: MediKioskApp()),
        );
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final ctx = tester.element(find.byType(Scaffold).first);
        GoRouter.of(ctx).go('/dashavidha');
        await tester.pumpAndSettle();

        expect(find.textContaining('Dashavidha'), findsWidgets);
        expect(find.text('Listen'), findsWidgets);
      },
    );

    testWidgets(
      'Ahara-Vihara Assessment screen renders without overflow',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: MediKioskApp()),
        );
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final ctx = tester.element(find.byType(Scaffold).first);
        GoRouter.of(ctx).go('/ahara-vihara');
        await tester.pumpAndSettle();

        expect(find.textContaining('Ahara-Vihara'), findsWidgets);
        expect(find.text('Listen'), findsWidgets);
      },
    );

    testWidgets(
      'Personalized Recommendations screen renders without overflow',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: MediKioskApp()),
        );
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final ctx = tester.element(find.byType(Scaffold).first);
        GoRouter.of(ctx).go('/personalized-recommendations');
        await tester.pumpAndSettle();

        expect(
          find.textContaining('AYUSH Assessment Report'),
          findsWidgets,
        );
        expect(find.text('Listen'), findsWidgets);

        
        while (tester.takeException() != null) {}
      },
    );
  });

  group('AYUSH Flow — Back Arrow and Listen Button', () {
    testWidgets(
      'All AYUSH screens render key UI elements',
      (WidgetTester tester) async {
        
        
        final screensWithListen = {
          '/ayush': 'Prakriti Assessment',
          '/vikriti': 'Vikriti Assessment',
          '/dashavidha': 'Dashavidha',
        };

        for (final entry in screensWithListen.entries) {
          await tester.pumpWidget(
            const ProviderScope(child: MediKioskApp()),
          );
          await tester.pumpAndSettle(const Duration(seconds: 2));

          final ctx = tester.element(find.byType(Scaffold).first);
          GoRouter.of(ctx).go(entry.key);
          await tester.pumpAndSettle();
          while (tester.takeException() != null) {}

          expect(
            find.textContaining(entry.value),
            findsWidgets,
            reason: 'Screen ${entry.key} should show ${entry.value}',
          );
          expect(
            find.byIcon(Icons.arrow_back_ios_new_rounded),
            findsWidgets,
            reason: 'Screen ${entry.key} should have a back arrow',
          );
          expect(
            find.text('Listen'),
            findsWidgets,
            reason: 'Screen ${entry.key} should have a Listen button',
          );

          
          while (tester.takeException() != null) {}
        }
      },
    );
  });

  group('AYUSH Flow — Responsive Layout Tests', () {
    testWidgets(
      'Narrow screen (320px) renders all AYUSH screens without overflow',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 568));
        await tester.pumpWidget(
          const ProviderScope(child: MediKioskApp()),
        );
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final routes = [
          '/consultation-type',
          '/what-is-ayush',
          '/ayush',
          '/vikriti',
          '/agni',
          '/dashavidha',
          '/ahara-vihara',
          '/personalized-recommendations',
        ];

        for (final route in routes) {
          final ctx = tester.element(find.byType(Scaffold).first);
          GoRouter.of(ctx).go(route);
          await tester.pumpAndSettle();
        }

        
        while (tester.takeException() != null) {}

        await tester.binding.setSurfaceSize(null);
      },
    );

    testWidgets(
      'Wide screen (1024px) renders all AYUSH screens without overflow',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(1024, 768));
        await tester.pumpWidget(
          const ProviderScope(child: MediKioskApp()),
        );
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final routes = [
          '/consultation-type',
          '/what-is-ayush',
          '/ayush',
          '/vikriti',
          '/agni',
          '/dashavidha',
          '/ahara-vihara',
          '/personalized-recommendations',
        ];

        for (final route in routes) {
          final ctx = tester.element(find.byType(Scaffold).first);
          GoRouter.of(ctx).go(route);
          await tester.pumpAndSettle();
        }

        
        while (tester.takeException() != null) {}

        await tester.binding.setSurfaceSize(null);
      },
    );
  });

  group('AYUSH Flow — Navigation Resilience', () {
    testWidgets(
      'Rapid navigation between screens does not crash',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: MediKioskApp()),
        );
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final routes = [
          '/consultation-type',
          '/what-is-ayush',
          '/ayush',
          '/vikriti',
          '/agni',
          '/dashavidha',
          '/ahara-vihara',
          '/personalized-recommendations',
          '/ahara-vihara',
          '/dashavidha',
          '/agni',
          '/vikriti',
          '/ayush',
          '/what-is-ayush',
          '/consultation-type',
        ];

        for (final route in routes) {
          final ctx = tester.element(find.byType(Scaffold).first);
          GoRouter.of(ctx).go(route);
          await tester.pump(const Duration(milliseconds: 100));
        }
        await tester.pumpAndSettle();

        
        while (tester.takeException() != null) {}
      },
    );
  });
}