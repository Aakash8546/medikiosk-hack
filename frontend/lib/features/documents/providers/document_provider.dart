import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/ocr_document_page.dart';



class DocumentState {
  
  final List<String> pendingImagePaths;

  
  final List<OcrDocumentPage> extractedPages;

  final bool isUploading;

  
  
  final String? errorMessage;

  
  
  final bool persistedToSession;

  const DocumentState({
    this.pendingImagePaths = const [],
    this.extractedPages = const [],
    this.isUploading = false,
    this.errorMessage,
    this.persistedToSession = false,
  });

  DocumentState copyWith({
    List<String>? pendingImagePaths,
    List<OcrDocumentPage>? extractedPages,
    bool? isUploading,
    String? errorMessage,
    bool? persistedToSession,
  }) =>
      DocumentState(
        pendingImagePaths: pendingImagePaths ?? this.pendingImagePaths,
        extractedPages: extractedPages ?? this.extractedPages,
        isUploading: isUploading ?? this.isUploading,
        
        errorMessage: errorMessage,
        persistedToSession: persistedToSession ?? this.persistedToSession,
      );

  bool get hasDocuments => pendingImagePaths.isNotEmpty;
  bool get hasExtraction => extractedPages.isNotEmpty;
}

class DocumentNotifier extends StateNotifier<DocumentState> {
  DocumentNotifier() : super(const DocumentState());

  List<String> get pendingImagePaths => state.pendingImagePaths;

  void addPendingImages(List<String> paths) {
    final merged = [...state.pendingImagePaths];
    for (final p in paths) {
      if (!merged.contains(p)) merged.add(p);
    }
    state = state.copyWith(pendingImagePaths: merged);
  }

  void addPendingImage(String path) => addPendingImages([path]);

  void removePendingImage(int index) {
    if (index < 0 || index >= state.pendingImagePaths.length) return;
    final next = [...state.pendingImagePaths]..removeAt(index);
    state = state.copyWith(pendingImagePaths: next);
  }

  void clearPendingImages() =>
      state = state.copyWith(pendingImagePaths: const []);

  void setUploading(bool uploading) =>
      state = state.copyWith(isUploading: uploading, errorMessage: null);

  void setResult(OcrUploadResult result) => state = state.copyWith(
        extractedPages: result.pages,
        isUploading: false,
        errorMessage: null,
        persistedToSession: result.persisted,
      );

  void setError(String message) =>
      state = state.copyWith(isUploading: false, errorMessage: message);

  void clear() => state = const DocumentState();
}

final documentProvider =
    StateNotifierProvider<DocumentNotifier, DocumentState>(
        (ref) => DocumentNotifier());