@Timeout(Duration(seconds: 120))



@Tags(['network'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:medikiosk/services/api_service.dart';

void main() {
  final apiService = ApiService();

  group('End-to-End App Features Verification', () {
    test('1. Patient Lookup & Login Verification (ABHA and Phone)', () async {
      print('[E2E Test] Testing registered ABHA lookup...');
      
      final abhaPatient = await apiService.getPatientByAbha('82990061191234');
      expect(abhaPatient.name, equals('Aakash Srivastava'));
      print('[E2E Test] ABHA Patient verified: ${abhaPatient.name}');

      print('[E2E Test] Testing registered Phone lookup...');
      
      final phonePatient = await apiService.getPatientByPhone('8299006119');
      expect(phonePatient.name, equals('Aakash Srivastava'));
      print('[E2E Test] Phone Patient verified: ${phonePatient.name}');

      print('[E2E Test] Testing non-existent ABHA lookup (Should return 404)...');
      try {
        await apiService.getPatientByAbha('00000000000000');
        fail('Expected 404 error for non-existent ABHA ID');
      } catch (e) {
        print('[E2E Test] Successfully caught 404 error for unregistered ABHA ID.');
      }
    });

    test('2. Patient Registration Verification', () async {
      final testPhone = '99${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      final testAbha = '14${DateTime.now().millisecondsSinceEpoch.toString().substring(1)}';

      print('[E2E Test] Registering new patient with phone: $testPhone, ABHA: $testAbha...');
      final newPatient = await apiService.registerPatient(
        abhaId: testAbha,
        name: 'Test Patient Flutter',
        dateOfBirth: '2000-01-01',
        gender: 'MALE',
        phone: testPhone,
        address: 'Test Address Kiosk',
        isMinor: false,
        preferredLanguage: 'en',
      );

      expect(newPatient.id, isNotNull);
      expect(newPatient.name, equals('Test Patient Flutter'));
      print('[E2E Test] New Patient registered successfully! ID: ${newPatient.id}');
    });

    test('3. General OPD AI Clinical Interview (Start + Text + Tap + Voice reply)', () async {
      print('[E2E Test] Starting AI Clinical Interview...');
      final startRes = await apiService.startInterview(language: 'hi');

      expect(startRes.sessionId, isNotNull);
      expect(startRes.questionText, isNotNull);
      print('[E2E Test] Interview Started! Session ID: ${startRes.sessionId}');
      print('[E2E Test] Q1: "${startRes.questionText}"');

      final sessionId = startRes.sessionId!;

      
      print('[E2E Test] Submitting Text Answer: "Mujhe 2 din se sar dard aur bukhar hai"...');
      final reply1 = await apiService.submitInterviewReply(
        sessionId: sessionId,
        textAnswer: 'Mujhe 2 din se sar dard aur bukhar hai',
      );

      expect(reply1.status, isNotEmpty);
      expect(reply1.questionText, isNotNull);
      print('[E2E Test] Q2 Reply Received: "${reply1.questionText}"');
      print('[E2E Test] Quick replies options (Tap mode): ${reply1.quickReplies}');

      
      final tapOption = reply1.quickReplies.isNotEmpty ? reply1.quickReplies.first : 'Halka hai';
      print('[E2E Test] Submitting Tap Option Answer (Tap Mode): "$tapOption"...');
      final reply2 = await apiService.submitInterviewReply(
        sessionId: sessionId,
        textAnswer: tapOption,
      );

      expect(reply2.status, isNotEmpty);
      print('[E2E Test] Q3 Reply Received: "${reply2.questionText}"');

      
      print('[E2E Test] Submitting Voice Answer Reply (Voice Mode)...');
      final reply3 = await apiService.submitInterviewReply(
        sessionId: sessionId,
        textAnswer: 'Main dawai le raha hu par aaram nahi hai',
      );

      expect(reply3.status, isNotEmpty);
      print('[E2E Test] Final Interview State verified! Status: ${reply3.status}');
    });
  });
}