import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medikiosk/app/localization/app_localizations.dart';
import 'package:medikiosk/features/documents/providers/document_provider.dart';
import 'package:medikiosk/features/documents/screens/extracted_data_screen.dart';
import 'package:medikiosk/models/ocr_document_page.dart';




void main() {
  
  
  Widget wrap(ProviderContainer container) => UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          locale: Locale('en'),
          supportedLocales: [Locale('en')],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: OcrReviewScreen(),
        ),
      );

  testWidgets('renders the extracted values, not the old placeholder rows',
      (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(documentProvider.notifier).setResult(
      OcrUploadResult.fromJson(const {
        'persisted': true,
        'saved_page_count': 1,
        'timeline': [
          {
            'source_filename': 'prescription.jpg',
            'document_type': 'prescription',
            'document_date': '02/04/2024',
            'diagnoses': ['Lower respiratory tract infection'],
            'medications': [
              {'name': 'Amoxicillin', 'dosage': '500mg', 'frequency': '1-1-1'},
            ],
            'lab_values': [
              {
                'test_name': 'Hemoglobin',
                'value': '13.5',
                'unit': 'g/dL',
                'is_abnormal': false,
              },
            ],
            'procedures': [],
            'raw_text': 'Rx Amoxicillin 500mg',
          }
        ],
      }),
    );

    await tester.pumpWidget(wrap(container));
    await tester.pumpAndSettle();

    expect(find.textContaining('Amoxicillin'), findsOneWidget);
    expect(find.textContaining('Hemoglobin'), findsOneWidget);
    expect(find.text('Lower respiratory tract infection'), findsOneWidget);
    expect(find.text('Prescription'), findsOneWidget);

    
    expect(find.textContaining('Paracetamol'), findsNothing);
    expect(find.textContaining('Metfornin'), findsNothing);
  });

  testWidgets('says a page read as blank rather than showing nothing',
      (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(documentProvider.notifier).setResult(
      OcrUploadResult.fromJson(const {
        'timeline': [
          {
            'source_filename': 'blurry.jpg',
            'document_type': 'prescription',
            'diagnoses': [],
            'medications': [],
            'lab_values': [],
            'procedures': [],
            'raw_text': '',
          }
        ],
      }),
    );

    await tester.pumpWidget(wrap(container));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nothing could be read'), findsOneWidget);
  });

  testWidgets('shows the upload error instead of an empty success screen',
      (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(documentProvider.notifier)
        .setError('Document reading service is busy.');

    await tester.pumpWidget(wrap(container));
    await tester.pumpAndSettle();

    expect(find.text('Document reading service is busy.'), findsOneWidget);
    
    expect(find.text('Continue'), findsOneWidget);
  });
}