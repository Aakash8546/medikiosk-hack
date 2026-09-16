import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  CameraController? get controller => _controller;

  Future<void> initialize() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;

    _controller = CameraController(
      _cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller!.initialize();
    _isInitialized = true;
  }

  Future<XFile?> captureImage() async {
    if (_controller == null || !_isInitialized) return null;
    return await _controller!.takePicture();
  }

  void flipCamera() async {
    if (_cameras.length < 2) return;
    final current = _controller?.description;
    final next = _cameras.firstWhere(
      (c) => c.lensDirection != current?.lensDirection,
      orElse: () => _cameras.first,
    );
    await _controller?.dispose();
    _controller = CameraController(next, ResolutionPreset.high, enableAudio: false);
    await _controller!.initialize();
  }

  Future<void> toggleFlash() async {
    if (_controller == null) return;
    final current = _controller!.value.flashMode;
    await _controller!.setFlashMode(
      current == FlashMode.off ? FlashMode.auto : FlashMode.off,
    );
  }

  void dispose() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }
}