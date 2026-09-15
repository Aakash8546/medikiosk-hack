import 'package:image_picker/image_picker.dart';













abstract final class DocumentCapture {
  static const double maxEdge = 1600;

  
  
  static const int quality = 85;

  
  static Future<XFile?> fromCamera(ImagePicker picker) => picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxEdge,
        maxHeight: maxEdge,
        imageQuality: quality,
      );

  
  static Future<List<XFile>> fromGallery(ImagePicker picker) =>
      picker.pickMultiImage(
        maxWidth: maxEdge,
        maxHeight: maxEdge,
        imageQuality: quality,
      );
}