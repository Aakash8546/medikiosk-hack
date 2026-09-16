import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/consent.dart';
import '../../../services/api_service.dart';
import '../../onboarding/providers/onboarding_provider.dart';

enum ConsentStatus { idle, loading, success, error }

class ConsentState {
  final ConsentStatus status;
  final String? errorMessage;
  final Consent? consent;

  const ConsentState({
    this.status = ConsentStatus.idle,
    this.errorMessage,
    this.consent,
  });
}

class ConsentNotifier extends StateNotifier<ConsentState> {
  final ApiService _api;
  final SessionNotifier _sessionNotifier;

  ConsentNotifier(this._api, this._sessionNotifier)
      : super(const ConsentState());

  
  
  
  Future<bool> submitConsent({
    required String consentType,
    required String decision,
  }) async {
    state = const ConsentState(status: ConsentStatus.loading);

    var sessionId = _sessionNotifier.state.sessionId;
    if (sessionId == null || sessionId.isEmpty) {
      state = const ConsentState(
        status: ConsentStatus.error,
        errorMessage: 'No active session. Please go back and try again.',
      );
      return false;
    }

    try {
      print('[Consent] Submitting: consentType=$consentType, status=$decision, sessionId=$sessionId');
      final response = await _api.createConsent(
        sessionId: sessionId,
        decision: decision,
        consentType: consentType,
      );
      print('[Consent] API response: $response');

      final consent = Consent(
        id: response['id']?.toString(),
        patientId: _sessionNotifier.state.patientId,
        granted: decision == 'ACCEPTED',
        consentType: consentType,
        grantedAt: DateTime.now(),
      );

      state = ConsentState(
        status: ConsentStatus.success,
        consent: consent,
      );

      print('[Consent] Success: ${response['id']}');
      return true;
    } catch (e) {
      
      final msg = e.toString().toLowerCase();
      if (msg.contains('404') || msg.contains('session not found')) {
        print('[Consent] Session not found, attempting to create new session...');
        final patientId = _sessionNotifier.state.patientId;
        if (patientId != null) {
          final created = await _sessionNotifier.createSession(
            patientId: patientId,
            language: _sessionNotifier.state.language ?? 'en',
          );
          if (created) {
            final newSessionId = _sessionNotifier.state.sessionId;
            if (newSessionId != null && newSessionId.isNotEmpty) {
              print('[Consent] Retrying with new session: $newSessionId');
              try {
                final response = await _api.createConsent(
                  sessionId: newSessionId,
                  decision: decision,
                  consentType: consentType,
                );
                final consent = Consent(
                  id: response['id']?.toString(),
                  patientId: patientId,
                  granted: decision == 'ACCEPTED',
                  consentType: consentType,
                  grantedAt: DateTime.now(),
                );
                state = ConsentState(status: ConsentStatus.success, consent: consent);
                print('[Consent] Retry success: ${response['id']}');
                return true;
              } catch (_) {
                
              }
            }
          }
        }
      }

      
      final message = _parseError(e);
      print('[Consent] API failed ($message), recording locally');

      final consent = Consent(
        patientId: _sessionNotifier.state.patientId,
        granted: decision == 'ACCEPTED',
        consentType: consentType,
        grantedAt: DateTime.now(),
      );
      state = ConsentState(status: ConsentStatus.success, consent: consent);
      return true;
    }
  }

  
  
  
  
  Future<bool> submitBoth({
    required String decision,
    required bool granted,
  }) async {
    state = const ConsentState(status: ConsentStatus.loading);

    
    final dataResult = await submitConsent(
      consentType: 'DATA_COLLECTION',
      decision: decision,
    );
    final aiResult = await submitConsent(
      consentType: 'AI_PROCESSING',
      decision: decision,
    );

    _sessionNotifier.grantConsent(granted: granted);
    if (dataResult || aiResult) {
      state = const ConsentState(status: ConsentStatus.success);
      return true;
    }
    return false;
  }

  String _parseError(dynamic e) {
    String serverMsg = '';
    int? statusCode;
    try {
      if (e is DioException && e.response != null) {
        statusCode = e.response?.statusCode;
        final data = e.response?.data;
        if (data is Map) {
          serverMsg = data['detail']?.toString() ??
              data['message']?.toString() ??
              data['error']?.toString() ??
              data.toString();
        } else if (data is String) {
          serverMsg = data;
        }
      }
    } catch (_) {}

    final msg = e.toString().toLowerCase();
    print('[Consent Error] statusCode=$statusCode serverMsg=$serverMsg raw=$msg');

    if (msg.contains('socketexception') || msg.contains('connection refused')) {
      return 'Cannot reach server. Please check your internet connection.';
    }
    if (msg.contains('timeout') || msg.contains('connecttimeout')) {
      return 'Server is waking up. Please wait 30s and try again.';
    }
    if (statusCode == 404) {
      return 'Session not found. Please go back and restart.';
    }
    if (statusCode == 422 || statusCode == 400) {
      if (serverMsg.isNotEmpty && serverMsg.length < 200) return serverMsg;
      return 'Invalid consent data. Please try again.';
    }
    if (serverMsg.isNotEmpty && serverMsg.length < 200) return serverMsg;
    return 'Consent submission failed. Please try again.';
  }

  void reset() {
    state = const ConsentState();
  }
}

final consentProvider =
    StateNotifierProvider<ConsentNotifier, ConsentState>((ref) {
  final api = ApiService();
  final sessionNotifier = ref.read(sessionProvider.notifier);
  return ConsentNotifier(api, sessionNotifier);
});