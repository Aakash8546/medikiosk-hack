import 'package:flutter_riverpod/flutter_riverpod.dart';

enum VoiceState { idle, listening, processing, speaking }

class VoiceNotifier extends StateNotifier<VoiceState> {
  VoiceNotifier() : super(VoiceState.idle);

  void startListening() => state = VoiceState.listening;
  void stopListening() => state = VoiceState.processing;
  void startSpeaking() => state = VoiceState.speaking;
  void reset() => state = VoiceState.idle;
}

final voiceProvider =
    StateNotifierProvider<VoiceNotifier, VoiceState>(
        (ref) => VoiceNotifier());