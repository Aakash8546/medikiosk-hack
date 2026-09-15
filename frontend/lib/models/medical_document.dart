class MedicalDocument {
  final String? id;
  final String? fileName;
  final String? title;
  final String? fileType;
  final String? category;
  final int? fileSize;
  final String? uploadUrl;
  final String? fileUrl;
  final String? thumbnailUrl;
  final String? ocrStatus; 
  final String? extractedText;
  final DateTime? uploadedAt;
  final String? uploadDate;

  const MedicalDocument({
    this.id,
    this.fileName,
    this.title,
    this.fileType,
    this.category,
    this.fileSize,
    this.uploadUrl,
    this.fileUrl,
    this.thumbnailUrl,
    this.ocrStatus,
    this.extractedText,
    this.uploadedAt,
    this.uploadDate,
  });

  String get displayTitle {
    if (title != null && title!.trim().isNotEmpty) return title!.trim();
    if (fileName != null && fileName!.trim().isNotEmpty) return fileName!.trim();
    return 'Medical Document';
  }

  String get displayCategory {
    final cat = (category ?? fileType ?? '').trim().toUpperCase();
    switch (cat) {
      case 'PRESCRIPTION':
        return 'Prescription';
      case 'LAB':
      case 'LAB_REPORT':
        return 'Lab Report';
      case 'IMAGING':
        return 'Imaging';
      case 'DISCHARGE_SUMMARY':
      case 'HISTORY':
        return 'History';
      default:
        return cat.isNotEmpty ? cat : 'Document';
    }
  }

  bool get isOcrComplete {
    final status = (ocrStatus ?? '').toLowerCase();
    return status.contains('completed') || status.contains('extracted') || status.contains('success');
  }

  String? get displayImageUrl => fileUrl ?? thumbnailUrl ?? uploadUrl;

  factory MedicalDocument.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['uploadedAt'] != null) {
      parsedDate = DateTime.tryParse(json['uploadedAt'].toString());
    }

    final dateStr = json['uploadDate']?.toString() ??
        (parsedDate != null ? '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}' : '');

    return MedicalDocument(
      id: (json['id'] ?? json['documentId'])?.toString(),
      fileName: json['fileName']?.toString(),
      title: json['title']?.toString() ?? json['fileName']?.toString(),
      fileType: json['fileType']?.toString() ?? json['category']?.toString(),
      category: json['category']?.toString() ?? json['fileType']?.toString(),
      fileSize: (json['fileSize'] as num?)?.toInt(),
      uploadUrl: json['uploadUrl']?.toString(),
      fileUrl: json['fileUrl']?.toString() ?? json['uploadUrl']?.toString(),
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      ocrStatus: json['ocrStatus']?.toString() ?? 'pending',
      extractedText: json['extractedText']?.toString() ?? '',
      uploadedAt: parsedDate,
      uploadDate: dateStr,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'title': title,
        'fileType': fileType,
        'category': category,
        'fileSize': fileSize,
        'uploadUrl': uploadUrl,
        'fileUrl': fileUrl,
        'thumbnailUrl': thumbnailUrl,
        'ocrStatus': ocrStatus,
        'extractedText': extractedText,
        'uploadedAt': uploadedAt?.toIso8601String(),
        'uploadDate': uploadDate,
      };
}