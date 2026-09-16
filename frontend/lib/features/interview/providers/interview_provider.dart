import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/interview_response.dart';
import '../../../services/api_service.dart';
import '../../../services/audio_interview_service.dart';

class InterviewMessage {
  final String text;
  final bool isUser;
  final String? transcribedCaption;

  const InterviewMessage({
    required this.text,
    required this.isUser,
    this.transcribedCaption,
  });
}

class InterviewState {
  final String? sessionId;
  final String language; 
  final String status; 
  final String questionText;
  final String? questionAudioBase64;
  final List<String> quickReplies;
  final List<InterviewMessage> messages;
  final bool isLoading;
  final bool isRecording;
  final String? errorMessage;
  final String? toastMessage;
  final String? emergencyMessage;
  final List<String> redFlags;
  final String? finalSummary;
  final Map<String, dynamic>? structuredHistory;

  const InterviewState({
    this.sessionId,
    this.language = 'en',
    this.status = 'in_progress',
    this.questionText = '',
    this.questionAudioBase64,
    this.quickReplies = const [],
    this.messages = const [],
    this.isLoading = false,
    this.isRecording = false,
    this.errorMessage,
    this.toastMessage,
    this.emergencyMessage,
    this.redFlags = const [],
    this.finalSummary,
    this.structuredHistory,
  });

  InterviewState copyWith({
    String? sessionId,
    String? language,
    String? status,
    String? questionText,
    String? questionAudioBase64,
    List<String>? quickReplies,
    List<InterviewMessage>? messages,
    bool? isLoading,
    bool? isRecording,
    String? errorMessage,
    String? toastMessage,
    String? emergencyMessage,
    List<String>? redFlags,
    String? finalSummary,
    Map<String, dynamic>? structuredHistory,
  }) {
    return InterviewState(
      sessionId: sessionId ?? this.sessionId,
      language: language ?? this.language,
      status: status ?? this.status,
      questionText: questionText ?? this.questionText,
      questionAudioBase64: questionAudioBase64 ?? this.questionAudioBase64,
      quickReplies: quickReplies ?? this.quickReplies,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isRecording: isRecording ?? this.isRecording,
      errorMessage: errorMessage ?? this.errorMessage,
      toastMessage: toastMessage,
      emergencyMessage: emergencyMessage ?? this.emergencyMessage,
      redFlags: redFlags ?? this.redFlags,
      finalSummary: finalSummary ?? this.finalSummary,
      structuredHistory: structuredHistory ?? this.structuredHistory,
    );
  }
}

class InterviewNotifier extends StateNotifier<InterviewState> {
  final ApiService _apiService;
  final AudioInterviewService _audioService;

  InterviewNotifier(this._apiService, this._audioService)
      : super(const InterviewState());

  AudioInterviewService get audioService => _audioService;

  void clearToast() {
    state = state.copyWith(toastMessage: null);
  }

  
  Future<void> startInterview({String language = 'en'}) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      language: language,
    );

    try {
      final res = await _apiService.startInterview(language: language);
      _handleResponse(res);
    } catch (e) {
      print('[InterviewNotifier] startInterview error: $e');
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to start interview. Please check server connection.',
      );
    }
  }

  
  Future<void> sendTextAnswer(String text) async {
    if (text.trim().isEmpty || state.sessionId == null) return;

    final userMsg = InterviewMessage(text: text.trim(), isUser: true);
    state = state.copyWith(
      isLoading: true,
      messages: [...state.messages, userMsg],
      errorMessage: null,
    );

    try {
      final res = await _apiService.submitInterviewReply(
        sessionId: state.sessionId!,
        textAnswer: text.trim(),
      );
      _handleResponse(res);
    } catch (e) {
      print('[InterviewNotifier] sendTextAnswer error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to submit answer. Please try again.',
      );
    }
  }

  
  Future<void> startRecording() async {
    await _audioService.stopAudio();
    final path = await _audioService.startRecording();
    if (path != null) {
      state = state.copyWith(isRecording: true);
    } else {
      state = state.copyWith(
        toastMessage: 'Microphone permission denied.',
      );
    }
  }

  
  Future<void> stopAndSendRecording() async {
    if (!state.isRecording) return;
    state = state.copyWith(isRecording: false, isLoading: true);

    final recordedPath = await _audioService.stopRecording();
    if (recordedPath == null || state.sessionId == null) {
      state = state.copyWith(
        isLoading: false,
        toastMessage: 'Audio recording was too short or empty. Please hold the button to speak or try typing.',
      );
      return;
    }

    try {
      final res = await _apiService.submitInterviewReply(
        sessionId: state.sessionId!,
        audioFilePath: recordedPath,
      );
      _handleResponse(res);
    } on DioException catch (e) {
      print('[InterviewNotifier] Voice upload DioException: ${e.response?.statusCode}');
      if (e.response?.statusCode == 503 ||
          (e.response?.data != null &&
              e.response!.data.toString().contains('503'))) {
        state = state.copyWith(
          isLoading: false,
          toastMessage:
              'Voice transcription temporarily unavailable. Please type your answer instead.',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          toastMessage:
              'Voice transcription temporarily unavailable. Please type your answer.',
        );
      }
    } catch (e) {
      print('[InterviewNotifier] sendVoiceAnswer error: $e');
      state = state.copyWith(
        isLoading: false,
        toastMessage:
            'Voice transcription temporarily unavailable. Please type your answer.',
      );
    }
  }

  void _handleResponse(InterviewResponse res) {
    final String currentStatus = res.status;
    final String? newSessionId = res.sessionId ?? state.sessionId;

    if (currentStatus == 'emergency_stop') {
      state = state.copyWith(
        sessionId: newSessionId,
        status: 'emergency_stop',
        isLoading: false,
        emergencyMessage: res.message ??
            'Red-flag detected! Please see clinical staff immediately.',
        redFlags: res.redFlags,
      );
      return;
    }

    
    if (currentStatus == 'error') {
      state = state.copyWith(
        sessionId: newSessionId,
        isLoading: false,
        toastMessage: res.message ?? 'Something went wrong. Please try again.',
      );
      return;
    }

    if (currentStatus == 'completed') {
      state = state.copyWith(
        sessionId: newSessionId,
        status: 'completed',
        isLoading: false,
        finalSummary: res.finalSummary,
        structuredHistory: res.structuredHistory,
      );
      return;
    }

    
    final List<InterviewMessage> updatedMessages = [...state.messages];

    
    String? caption;
    if (res.transcribedAnswer != null && res.transcribedAnswer!.isNotEmpty) {
      caption = res.transcribedAnswer;
      updatedMessages.add(
        InterviewMessage(
          text: res.transcribedAnswer!,
          isUser: true,
          transcribedCaption: 'You said: "${res.transcribedAnswer}"',
        ),
      );
    }

    
    if (res.questionText != null && res.questionText!.isNotEmpty) {
      updatedMessages.add(
        InterviewMessage(
          text: res.questionText!,
          isUser: false,
        ),
      );
    }

    state = state.copyWith(
      sessionId: newSessionId,
      status: 'in_progress',
      questionText: res.questionText ?? '',
      questionAudioBase64: res.questionAudioBase64,
      quickReplies: res.quickReplies,
      messages: updatedMessages,
      isLoading: false,
    );

    
    if (res.questionAudioBase64 != null &&
        res.questionAudioBase64!.isNotEmpty) {
      _audioService.playBase64Audio(res.questionAudioBase64!);
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}

final audioInterviewServiceProvider = Provider<AudioInterviewService>((ref) {
  final service = AudioInterviewService();
  ref.onDispose(() => service.dispose());
  return service;
});

final interviewApiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final interviewNotifierProvider =
    StateNotifierProvider<InterviewNotifier, InterviewState>((ref) {
  final apiService = ref.watch(interviewApiServiceProvider);
  final audioService = ref.watch(audioInterviewServiceProvider);
  return InterviewNotifier(apiService, audioService);
});

final interviewProvider = interviewNotifierProvider;
