import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class AudioInterviewService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _audioRecorder = AudioRecorder();

  AudioPlayer get player => _audioPlayer;

  
  Future<bool> checkAndRequestMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;
    final result = await Permission.microphone.request();
    return result.isGranted;
  }

  
  Future<void> playBase64Audio(String base64String) async {
    try {
      await _audioPlayer.stop();
      final cleanBase64 = base64String.contains(',')
          ? base64String.split(',').last
          : base64String;
      final Uint8List audioBytes = base64Decode(cleanBase64.replaceAll(RegExp(r'\s+'), ''));
      if (audioBytes.isNotEmpty) {
        await _audioPlayer.play(BytesSource(audioBytes));
      }
    } catch (e) {
      print('[AudioService] Error playing base64 audio: $e');
    }
  }

  
  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}
  }

  
  Future<String?> startRecording() async {
    final hasPermission = await checkAndRequestMicrophonePermission();
    if (!hasPermission) {
      print('[AudioService] Microphone permission not granted');
      return null;
    }

    try {
      if (await _audioRecorder.isRecording()) {
        await _audioRecorder.stop();
      }

      final dir = await getTemporaryDirectory();

      AudioEncoder chosenEncoder = AudioEncoder.wav;
      String extension = 'wav';

      if (!(await _audioRecorder.isEncoderSupported(AudioEncoder.wav))) {
        if (await _audioRecorder.isEncoderSupported(AudioEncoder.aacLc)) {
          chosenEncoder = AudioEncoder.aacLc;
          extension = 'm4a';
        } else if (await _audioRecorder.isEncoderSupported(AudioEncoder.opus)) {
          chosenEncoder = AudioEncoder.opus;
          extension = 'opus';
        }
      }

      final path = '${dir.path}/interview_record_${DateTime.now().millisecondsSinceEpoch}.$extension';

      await _audioRecorder.start(
        RecordConfig(
          encoder: chosenEncoder,
          sampleRate: 16000,
          numChannels: 1,
          bitRate: chosenEncoder == AudioEncoder.aacLc ? 64000 : 128000,
        ),
        path: path,
      );

      print('[AudioService] Started recording ($extension, 16kHz mono) -> $path');
      return path;
    } catch (e) {
      print('[AudioService] Failed to start recording: $e');
      return null;
    }
  }

  
  Future<String?> stopRecording() async {
    try {
      if (await _audioRecorder.isRecording()) {
        final path = await _audioRecorder.stop();
        if (path != null && path.isNotEmpty) {
          final file = File(path);
          if (await file.exists() && await file.length() > 0) {
            return path;
          } else {
            print('[AudioService] Recorded file is empty or 0-bytes: $path');
          }
        }
      }
    } catch (e) {
      print('[AudioService] Error stopping recording: $e');
    }
    return null;
  }

  void dispose() {
    _audioPlayer.dispose();
    _audioRecorder.dispose();
  }
}