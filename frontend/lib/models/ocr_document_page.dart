





class OcrDocumentPage {
  final String? documentId;
  final String sourceFilename;
  final String documentType;

  
  final String documentDate;

  
  final DateTime? normalizedDate;

  final int pageNumber;
  final List<String> diagnoses;
  final List<OcrMedication> medications;
  final List<OcrLabValue> labValues;
  final List<String> procedures;
  final String rawText;
  final String? confidenceNote;

  
  final String? imageUrl;

  const OcrDocumentPage({
    this.documentId,
    this.sourceFilename = '',
    this.documentType = 'document',
    this.documentDate = '',
    this.normalizedDate,
    this.pageNumber = 1,
    this.diagnoses = const [],
    this.medications = const [],
    this.labValues = const [],
    this.procedures = const [],
    this.rawText = '',
    this.confidenceNote,
    this.imageUrl,
  });

  factory OcrDocumentPage.fromJson(Map<String, dynamic> json) {
    return OcrDocumentPage(
      documentId: json['document_id']?.toString(),
      sourceFilename: json['source_filename']?.toString() ?? '',
      documentType: json['document_type']?.toString() ?? 'document',
      documentDate: json['document_date']?.toString() ?? '',
      normalizedDate: DateTime.tryParse(json['normalized_date']?.toString() ?? ''),
      pageNumber: (json['page_number'] as num?)?.toInt() ?? 1,
      diagnoses: _stringList(json['diagnoses']),
      medications: _objectList(json['medications'])
          .map(OcrMedication.fromJson)
          .toList(),
      labValues: _objectList(json['lab_values'])
          .map(OcrLabValue.fromJson)
          .toList(),
      procedures: _stringList(json['procedures']),
      rawText: json['raw_text']?.toString() ?? '',
      confidenceNote: json['ocr_confidence_note']?.toString(),
      imageUrl: json['image_url']?.toString() ??
          json['file_url']?.toString() ??
          json['thumbnail_url']?.toString() ??
          json['file_path']?.toString() ??
          json['filePath']?.toString() ??
          json['url']?.toString() ??
          json['path']?.toString() ??
          json['imageUrl']?.toString() ??
          json['fileUrl']?.toString() ??
          json['thumbnailUrl']?.toString(),
    );
  }

  
  String? get effectiveImageUrl {
    if (imageUrl != null &&
        imageUrl!.trim().isNotEmpty &&
        imageUrl!.trim().toLowerCase() != 'null') {
      return imageUrl!.trim();
    }
    if (sourceFilename.isNotEmpty) {
      final s = sourceFilename.trim();
      if (s.toLowerCase() != 'null' &&
          (s.startsWith('/') ||
              s.startsWith('file:
              s.startsWith('http://') ||
              s.startsWith('https://'))) {
        return s;
      }
    }
    return null;
  }

  
  String get title {
    if (diagnoses.isNotEmpty) return diagnoses.first;
    if (sourceFilename.isNotEmpty) return sourceFilename;
    return documentTypeLabel;
  }

  String get documentTypeLabel {
    switch (documentType.toLowerCase()) {
      case 'prescription':
        return 'Prescription';
      case 'lab_report':
        return 'Lab Report';
      case 'discharge_summary':
        return 'Discharge Summary';
      case 'imaging':
        return 'Imaging';
      default:
        return 'Medical Document';
    }
  }

  String get displayDate {
    if (documentDate.isNotEmpty) return documentDate;
    if (normalizedDate != null) {
      return '${normalizedDate!.day.toString().padLeft(2, '0')}/'
          '${normalizedDate!.month.toString().padLeft(2, '0')}/'
          '${normalizedDate!.year}';
    }
    return 'Undated';
  }

  
  bool get isEmpty =>
      diagnoses.isEmpty &&
      medications.isEmpty &&
      labValues.isEmpty &&
      procedures.isEmpty;

  static List<String> _stringList(dynamic v) {
    if (v is! List) return const [];
    return v.where((e) => e != null).map((e) => e.toString()).toList();
  }

  static List<Map<String, dynamic>> _objectList(dynamic v) {
    if (v is! List) return const [];
    return v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }
}

class OcrMedication {
  final String name;
  final String? dosage;
  final String? frequency;
  final String? route;

  const OcrMedication({
    required this.name,
    this.dosage,
    this.frequency,
    this.route,
  });

  factory OcrMedication.fromJson(Map<String, dynamic> json) => OcrMedication(
        name: json['name']?.toString() ?? 'Unnamed medicine',
        dosage: _clean(json['dosage']),
        frequency: _clean(json['frequency']),
        route: _clean(json['route']),
      );

  String get display =>
      [name, dosage, frequency, route].whereType<String>().join(' · ');
}

class OcrLabValue {
  final String testName;
  final String value;
  final String? unit;
  final String? referenceRange;

  
  final bool? isAbnormal;

  const OcrLabValue({
    required this.testName,
    required this.value,
    this.unit,
    this.referenceRange,
    this.isAbnormal,
  });

  factory OcrLabValue.fromJson(Map<String, dynamic> json) => OcrLabValue(
        testName: json['test_name']?.toString() ?? 'Unnamed test',
        value: json['value']?.toString() ?? '—',
        unit: _clean(json['unit']),
        referenceRange: _clean(json['reference_range']),
        isAbnormal: json['is_abnormal'] as bool?,
      );

  String get display => unit == null ? value : '$value $unit';
}

String? _clean(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  if (s.isEmpty || s.toLowerCase() == 'null') return null;
  return s;
}



class OcrUploadResult {
  final List<OcrDocumentPage> pages;
  final int documentCount;
  final int savedPageCount;
  final bool persisted;

  const OcrUploadResult({
    this.pages = const [],
    this.documentCount = 0,
    this.savedPageCount = 0,
    this.persisted = false,
  });

  factory OcrUploadResult.fromJson(Map<String, dynamic> json) {
    final timeline = json['timeline'];
    return OcrUploadResult(
      pages: timeline is List
          ? timeline
              .whereType<Map>()
              .map((e) => OcrDocumentPage.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      documentCount: (json['document_count'] as num?)?.toInt() ?? 0,
      savedPageCount: (json['saved_page_count'] as num?)?.toInt() ?? 0,
      persisted: json['persisted'] as bool? ?? false,
    );
  }

  bool get isEmpty => pages.isEmpty;
}