import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../services/api_service.dart';

class Session {
  final String? sessionId;
  final String? kioskId;
  final String? language;
  final String? status;
  final String? mode;
  final String? identifierType;
  final String? patientId;
  final String? patientName;
  final bool? consentGranted;
  final String? token;
  final String? sessionType;
  final String? errorMessage;

  const Session({
    this.sessionId,
    this.kioskId,
    this.language,
    this.status,
    this.mode,
    this.identifierType,
    this.patientId,
    this.patientName,
    this.consentGranted,
    this.token,
    this.sessionType,
    this.errorMessage,
  });

  Session copyWith({
    String? sessionId,
    String? kioskId,
    String? language,
    String? status,
    String? mode,
    String? identifierType,
    String? patientId,
    String? patientName,
    bool? consentGranted,
    String? token,
    String? sessionType,
    String? errorMessage,
  }) =>
      Session(
        sessionId: sessionId ?? this.sessionId,
        kioskId: kioskId ?? this.kioskId,
        language: language ?? this.language,
        status: status ?? this.status,
        mode: mode ?? this.mode,
        identifierType: identifierType ?? this.identifierType,
        patientId: patientId ?? this.patientId,
        patientName: patientName ?? this.patientName,
        consentGranted: consentGranted ?? this.consentGranted,
        token: token ?? this.token,
        sessionType: sessionType ?? this.sessionType,
        errorMessage: errorMessage,
      );
}

class SessionNotifier extends StateNotifier<Session> {
  final ApiService _api = ApiService();

  SessionNotifier() : super(const Session());

  
  Future<bool> createSession({
    required String patientId,
    String sessionType = 'GENERAL',
    String language = 'en',
  }) async {
    try {
      print('[Session] Creating session for patient: $patientId, type: $sessionType, lang: $language');
      final response = await _api.createSession(
        patientId: patientId,
        sessionType: sessionType,
        language: language,
      );

      final sessionId = response['id']?.toString() ?? response['sessionId']?.toString();
      final sessionToken = response['token']?.toString() ??
          response['accessToken']?.toString();
      print('[Session] Session created with ID: $sessionId');

      if (sessionId == null || sessionId.isEmpty) {
        print('[Session] WARNING: Server returned null/empty session ID!');
        
      }

      state = state.copyWith(
        sessionId: sessionId,
        language: language,
        patientId: patientId,
        sessionType: sessionType,
        token: sessionToken,
        status: 'created',
      );
      return true;
    } catch (e) {
      print('[Session] Failed to create session: $e');
      
      final fallbackId = const Uuid().v4();
      print('[Session] Using fallback UUID: $fallbackId');
      state = state.copyWith(
        sessionId: fallbackId,
        language: language,
        patientId: patientId,
        sessionType: sessionType,
        status: 'created_local',
        errorMessage: 'Session created locally (server unavailable)',
      );
      return false;
    }
  }

  void setPatient({required String patientId, required String patientName}) {
    state = state.copyWith(
      patientId: patientId,
      patientName: patientName,
      status: 'identified',
    );
  }

  void updateLanguage(String lang) =>
      state = state.copyWith(language: lang, status: 'language_selected');

  void setMode(String mode) =>
      state = state.copyWith(mode: mode, status: 'mode_selected');

  void identifyPatient({
    required String type,
    required String id,
    required String identifierType,
    required String identifier,
  }) {
    state = state.copyWith(
      identifierType: type,
      patientId: id,
      patientName: 'Patient',
      status: 'identified',
    );
  }

  void grantConsent({required bool granted}) {
    state = state.copyWith(
      consentGranted: granted,
      status: granted ? 'consented' : 'consent_declined',
    );
  }

  void startInterview() => state = state.copyWith(status: 'in_progress');

  
  
  void markSubmitted(String? tokenNumber) {
    state = state.copyWith(
      token: tokenNumber ?? state.token,
      status: 'submitted',
    );
  }

  void clearSession() => state = const Session();
}

final sessionProvider =
    StateNotifierProvider<SessionNotifier, Session>((ref) => SessionNotifier());