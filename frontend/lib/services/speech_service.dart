import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../core/network/dio_client.dart';
import '../core/network/api_endpoints.dart';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    _isInitialized = await _speech.initialize(
      onError: (error) => print('[Speech] Error: $error'),
      onStatus: (status) => print('[Speech] Status: $status'),
    );
    return _isInitialized;
  }

  Future<void> startListening({
    required Function(String text) onResult,
    required Function(String locale) onLocale,
  }) async {
    if (!_isInitialized) await initialize();
    await _speech.listen(
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          onResult(result.recognizedWords);
        }
        if (result.finalResult) {
          onLocale('hi_IN');
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: 'hi_IN', 
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  bool get isListening => _speech.isListening;

  
  Future<String> transcribeAudio(String audioPath) async {
    final dio = MediKioskDio.instance;
    
    final response = await dio.post(
      ApiEndpoints.transcribe,
      data: {'audioPath': audioPath},
    );
    return response.data['text'] as String;
  }
}