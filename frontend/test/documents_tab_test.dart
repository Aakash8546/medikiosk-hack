import 'package:flutter_test/flutter_test.dart';
import 'package:medikiosk/models/medical_document.dart';

void main() {
  group('MedicalDocument 8.3 API Deserialization', () {
    test('parses full document preview object correctly', () {
      final json = {
        'id': 'doc_001',
        'title': 'Chest X-Ray PA View',
        'category': 'IMAGING',
        'ocrStatus': 'completed',
        'fileUrl': 'https://res.cloudinary.com/demo/image/upload/xray.jpg',
        'thumbnailUrl': 'https://res.cloudinary.com/demo/image/upload/xray_thumb.jpg',
        'uploadDate': '12/03/2026',
        'extractedText': 'Impression: Clear lung fields, normal cardiothoracic ratio.',
      };

      final doc = MedicalDocument.fromJson(json);

      expect(doc.id, 'doc_001');
      expect(doc.displayTitle, 'Chest X-Ray PA View');
      expect(doc.displayCategory, 'Imaging');
      expect(doc.isOcrComplete, isTrue);
      expect(doc.displayImageUrl, 'https://res.cloudinary.com/demo/image/upload/xray.jpg');
      expect(doc.uploadDate, '12/03/2026');
      expect(doc.extractedText, contains('Clear lung fields'));
    });

    test('falls back to fileName when title is absent', () {
      final json = {
        'fileName': 'prescription_2026.pdf',
        'fileType': 'PRESCRIPTION',
        'ocrStatus': 'pending',
        'uploadUrl': 'https://storage.example.com/prescription.pdf',
      };

      final doc = MedicalDocument.fromJson(json);

      expect(doc.displayTitle, 'prescription_2026.pdf');
      expect(doc.displayCategory, 'Prescription');
      expect(doc.isOcrComplete, isFalse);
      expect(doc.displayImageUrl, 'https://storage.example.com/prescription.pdf');
    });

    test('normalizes category labels correctly', () {
      expect(
        MedicalDocument.fromJson({'category': 'LAB_REPORT'}).displayCategory,
        'Lab Report',
      );
      expect(
        MedicalDocument.fromJson({'category': 'DISCHARGE_SUMMARY'}).displayCategory,
        'History',
      );
      expect(
        MedicalDocument.fromJson({'category': 'PRESCRIPTION'}).displayCategory,
        'Prescription',
      );
    });

    test('handles list payload normalization', () {
      final rawList = [
        {
          'id': '1',
          'title': 'CBC Report',
          'category': 'LAB',
          'ocrStatus': 'extracted',
        },
        {
          'id': '2',
          'title': 'Ayush Record',
          'category': 'HISTORY',
          'ocrStatus': 'pending',
        }
      ];

      final docs = rawList
          .whereType<Map<String, dynamic>>()
          .map((m) => MedicalDocument.fromJson(m))
          .toList();

      expect(docs, hasLength(2));
      expect(docs[0].displayCategory, 'Lab Report');
      expect(docs[0].isOcrComplete, isTrue);
      expect(docs[1].displayCategory, 'History');
      expect(docs[1].isOcrComplete, isFalse);
    });
  });
}