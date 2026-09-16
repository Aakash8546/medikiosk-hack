import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/patient.dart';
import '../../../services/api_service.dart';


enum RegistrationStatus { idle, loading, success, error }

class RegistrationState {
  final RegistrationStatus status;
  final String? errorMessage;
  final Patient? patient;

  const RegistrationState({
    this.status = RegistrationStatus.idle,
    this.errorMessage,
    this.patient,
  });
}

class PatientNotifier extends StateNotifier<Patient?> {
  PatientNotifier() : super(null);

  void setPatient(Patient p) => state = p;
  void clear() => state = null;
}

final patientProvider =
    StateNotifierProvider<PatientNotifier, Patient?>(
        (ref) => PatientNotifier());


class RegistrationNotifier extends StateNotifier<RegistrationState> {
  final ApiService _api;
  final PatientNotifier _patientNotifier;

  RegistrationNotifier(this._api, this._patientNotifier)
      : super(const RegistrationState());

  Future<bool> register({
    required String abhaId,
    required String name,
    required String dateOfBirth,
    required String gender,
    required String phone,
    required String address,
    required bool isMinor,
    required String preferredLanguage,
    String? guardianName,
    String? guardianPhone,
  }) async {
    state = const RegistrationState(status: RegistrationStatus.loading);

    try {
      final patient = await _api.registerPatient(
        abhaId: abhaId,
        name: name,
        dateOfBirth: dateOfBirth,
        gender: gender,
        phone: phone,
        address: address,
        isMinor: isMinor,
        preferredLanguage: preferredLanguage,
        guardianName: guardianName,
        guardianPhone: guardianPhone,
      );

      
      _patientNotifier.setPatient(patient);

      state = RegistrationState(
        status: RegistrationStatus.success,
        patient: patient,
      );

      return true;
    } catch (e) {
      final message = _parseError(e);
      state = RegistrationState(
        status: RegistrationStatus.error,
        errorMessage: message,
      );
      return false;
    }
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
    print('[API ERROR] statusCode=$statusCode serverMsg=$serverMsg raw=$msg');

    if (msg.contains('socketexception') || msg.contains('connection refused') || msg.contains('connection failed')) {
      return 'Cannot reach server. Please check your internet connection.';
    }
    if (msg.contains('timeout') || msg.contains('connecttimeout') || msg.contains('receivetimeout')) {
      return 'Server is waking up (Render free tier). Please wait 30s and try again.';
    }
    if (statusCode == 409 || msg.contains('409') || msg.contains('already exists')) {
      return 'A patient with this ABHA ID already exists. Please use a different ID.';
    }
    if (statusCode == 422 || statusCode == 400 || msg.contains('422') || msg.contains('400') || msg.contains('validation')) {
      
      if (serverMsg.isNotEmpty && serverMsg.length < 200) {
        return serverMsg;
      }
      return 'Invalid data. Please check all fields and try again.';
    }
    if (msg.contains('500') || msg.contains('502') || msg.contains('503')) {
      return 'Server error. Please try again in a moment.';
    }
    if (msg.contains('cors')) {
      return 'Server configuration error. Contact support.';
    }
    
    if (serverMsg.isNotEmpty && serverMsg.length < 200) {
      return serverMsg;
    }
    return 'Registration failed. Please try again.';
  }

  void reset() {
    state = const RegistrationState();
  }
}

final registrationProvider =
    StateNotifierProvider<RegistrationNotifier, RegistrationState>((ref) {
  final api = ApiService();
  final patientNotifier = ref.read(patientProvider.notifier);
  return RegistrationNotifier(api, patientNotifier);
});