import 'package:audioplayers/audioplayers.dart';
import '../core/network/dio_client.dart';
import '../core/network/api_endpoints.dart';

class TtsService {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Future<void> speak({
    required String text,
    required String language, 
  }) async {
    try {
      final dio = MediKioskDio.instance;
      final response = await dio.post(
        ApiEndpoints.synthesize,
        data: {'text': text, 'language': language},
      );
      final audioUrl = response.data['audioUrl'] as String;

      await _player.play(UrlSource(audioUrl));
      _isPlaying = true;

      _player.onPlayerComplete.listen((_) {
        _isPlaying = false;
      });
    } catch (e) {
      _isPlaying = false;
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
  }

  void dispose() {
    _player.dispose();
  }
}