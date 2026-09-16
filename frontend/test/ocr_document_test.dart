import 'package:flutter_test/flutter_test.dart';
import 'package:medikiosk/features/documents/providers/document_provider.dart';
import 'package:medikiosk/models/ocr_document_page.dart';



const _uploadResponse = {
  'sessionId': '3681eb14-86f9-4b40-9a03-8679eeef3278',
  'document_count': 1,
  'page_count': 1,
  'saved_page_count': 1,
  'persisted': true,
  'timeline': [
    {
      'source_filename': 'rx.png',
      'document_type': 'discharge_summary',
      'document_date': '12/03/2024',
      'normalized_date': '2024-03-12',
      'diagnoses': ['Type 2 Diabetes Mellitus', 'Hypertension'],
      'medications': [
        {'name': 'Metformin', 'dosage': '500mg', 'frequency': '1-0-1', 'route': null},
        {'name': 'Telmisartan', 'dosage': '40mg', 'frequency': '1-0-0', 'route': null},
      ],
      'lab_values': [
        {
          'test_name': 'HbA1c',
          'value': '8.9%',
          'unit': null,
          'reference_range': '(ref 4-5.6)',
          'is_abnormal': true,
        },
        {
          'test_name': 'Fasting glucose',
          'value': '168',
          'unit': 'mg/dL',
          'reference_range': '(ref 70-100)',
          'is_abnormal': null,
        },
      ],
      'procedures': [],
      'raw_text': 'City Care Hospital\nDate: 12/03/2024',
      'page_number': 1,
      'ocr_confidence_note': null,
    }
  ],
};

void main() {
  group('OcrUploadResult parsing', () {
    test('reads pages, medications and lab values from a real response', () {
      final result = OcrUploadResult.fromJson(
          Map<String, dynamic>.from(_uploadResponse));

      expect(result.pages, hasLength(1));
      expect(result.persisted, isTrue);
      expect(result.savedPageCount, 1);

      final page = result.pages.single;
      expect(page.diagnoses, ['Type 2 Diabetes Mellitus', 'Hypertension']);
      expect(page.medications.map((m) => m.name),
          containsAll(['Metformin', 'Telmisartan']));
      expect(page.normalizedDate, DateTime(2024, 3, 12));
      expect(page.isEmpty, isFalse);
    });

    test('drops null-valued optional fields instead of rendering "null"', () {
      final page = OcrUploadResult.fromJson(
              Map<String, dynamic>.from(_uploadResponse))
          .pages
          .single;

      
      expect(page.medications.first.display, 'Metformin · 500mg · 1-0-1');
      
      expect(page.labValues.first.display, '8.9%');
      expect(page.labValues[1].display, '168 mg/dL');
    });

    test('flags only lab values the pipeline judged abnormal', () {
      final page = OcrUploadResult.fromJson(
              Map<String, dynamic>.from(_uploadResponse))
          .pages
          .single;

      expect(page.labValues.first.isAbnormal, isTrue);
      
      expect(page.labValues[1].isAbnormal, isNull);
    });

    test('survives an empty or malformed response without throwing', () {
      expect(OcrUploadResult.fromJson({}).isEmpty, isTrue);
      expect(OcrUploadResult.fromJson({'timeline': 'not-a-list'}).isEmpty, isTrue);

      final sparse = OcrDocumentPage.fromJson({'source_filename': 'scan.jpg'});
      expect(sparse.isEmpty, isTrue);
      expect(sparse.displayDate, 'Undated');
      expect(sparse.title, 'scan.jpg');
    });
  });

  group('DocumentNotifier', () {
    test('does not queue the same file twice', () {
      final n = DocumentNotifier()
        ..addPendingImages(['/a.png', '/b.png'])
        ..addPendingImage('/a.png');

      expect(n.state.pendingImagePaths, ['/a.png', '/b.png']);
    });

    test('removing a page keeps the rest in order', () {
      final n = DocumentNotifier()..addPendingImages(['/a.png', '/b.png', '/c.png']);
      n.removePendingImage(1);
      expect(n.state.pendingImagePaths, ['/a.png', '/c.png']);

      
      n.removePendingImage(9);
      n.removePendingImage(-1);
      expect(n.state.pendingImagePaths, ['/a.png', '/c.png']);
    });

    test('a successful upload clears any earlier error', () {
      final n = DocumentNotifier()..setError('OCR service busy');
      expect(n.state.errorMessage, isNotNull);

      n.setUploading(true);
      expect(n.state.errorMessage, isNull);
      expect(n.state.isUploading, isTrue);

      n.setResult(OcrUploadResult.fromJson(
          Map<String, dynamic>.from(_uploadResponse)));
      expect(n.state.isUploading, isFalse);
      expect(n.state.errorMessage, isNull);
      expect(n.state.hasExtraction, isTrue);
      expect(n.state.persistedToSession, isTrue);
    });

    test('a failed upload keeps the message and stops the spinner', () {
      final n = DocumentNotifier()
        ..setUploading(true)
        ..setError('Document reading service is busy.');

      expect(n.state.isUploading, isFalse);
      expect(n.state.errorMessage, 'Document reading service is busy.');
      expect(n.state.hasExtraction, isFalse);
    });
  });
}