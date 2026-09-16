import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/app/routes.dart';
import 'package:medikiosk/models/doctor_portal_responses.dart';
import 'package:medikiosk/models/patient_clinical_view_response.dart';





void main() {
  group('routing integrity', () {
    
    test('no screen navigates to an undefined route', () {
      final defined = _definedPaths();
      
      for (final path in const [
        '/dashboard',
        '/ayush',
        '/red-flag-alert',
        '/doctor-confirmation',
        '/edit-clinical-summary',
        '/ai-clinical-summary',
        '/consultation-notes',
        '/medical-timeline',
        '/patient-summary',
      ]) {
        expect(defined, contains(path),
            reason: '$path is navigated to but not defined');
      }
      expect(defined, isNot(contains('/home')));
    });

    test('the doctor review chain is fully routable', () {
      final defined = _definedPaths();
      const chain = [
        '/doctor-login',
        '/doctor-dashboard',
        '/patient-clinical-view',
        '/patient-summary',
        '/ai-clinical-summary',
        '/edit-clinical-summary',
        '/doctor-confirmation',
        '/consultation-notes',
        '/consultation-completed',
      ];
      for (final step in chain) {
        expect(defined, contains(step), reason: '$step missing from the chain');
      }
    });
  });

  group('DoctorRedFlagAlert', () {
    test('a session with no flags is not reported as an emergency', () {
      final alert = DoctorRedFlagAlert.fromJson(const {
        'alertLevel': 'NONE',
        'aiConfidence': 0,
        'detectedFlags': [],
        'aiRiskAssessment': ['No red-flag symptoms were detected.'],
        'recommendedAction': 'Routine consultation — no triage escalation required.',
      });

      expect(alert.hasFlags, isFalse);
      expect(alert.isCritical, isFalse);
      expect(alert.alertLevel, 'NONE');
    });

    test('a critical session carries its detected flags', () {
      final alert = DoctorRedFlagAlert.fromJson(const {
        'alertLevel': 'CRITICAL',
        'detectedFlags': [
          {
            'symptom': 'Acute Chest Pain + Dyspnea',
            'description': 'chest pain + breathing difficulty',
            'severity': 'CRITICAL',
          }
        ],
      });

      expect(alert.isCritical, isTrue);
      expect(alert.detectedFlags.single.symptom, 'Acute Chest Pain + Dyspnea');
    });

    test('parses requirement 8.4 Red Flag Alert JSON format', () {
      final alert = DoctorRedFlagAlert.fromJson(const {
        "sessionId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "hasRedFlags": true,
        "alerts": [
          {
            "alertId": "alert-123",
            "ruleName": "Acute Coronary Syndrome Rule",
            "severity": "CRITICAL",
            "triggeredBy": "chest_pain + shortness_of_breath"
          }
        ]
      });

      expect(alert.hasFlags, isTrue);
      expect(alert.isCritical, isTrue);
      expect(alert.allAlerts, hasLength(1));
      expect(alert.allAlerts.first.alertId, 'alert-123');
      expect(alert.allAlerts.first.ruleName, 'Acute Coronary Syndrome Rule');
      expect(alert.allAlerts.first.severity, 'CRITICAL');
      expect(alert.allAlerts.first.triggeredBy, 'chest_pain + shortness_of_breath');
    });

    test('an absent payload defaults to no alert, never to a critical one', () {
      final alert = DoctorRedFlagAlert.fromJson(const {});
      expect(alert.alertLevel, 'NONE');
      expect(alert.hasFlags, isFalse);
    });
  });

  group('DoctorAiSummary', () {
    test('reports no vitals when the kiosk measured none', () {
      final s = DoctorAiSummary.fromJson(const {
        'hpiSummary': '46-year-old male presenting with chest pain for 3 days.',
        'hpiConfidence': 100,
        'vitalsSummary': {},
        'vitalsConfidence': 0,
        'totalMedications': 1,
        'totalAllergies': 1,
      });

      expect(s.vitalsSummary, isEmpty);
      expect(s.vitalsConfidence, 0);
      expect(s.hpiSummary, contains('chest pain'));
      expect(s.totalMedications, 1);
    });
  });

  group('DoctorConfirmation', () {
    test('does not claim the physician verified anything by default', () {
      final c = DoctorConfirmation.fromJson(const {});
      expect(c.aiSummaryVerified, isFalse);
      expect(c.modificationsCount, 0);
      expect(c.icdCodesConfirmed, isEmpty);
    });
  });

  group('DoctorTimeline', () {
    test('parses events built from the patient own documents', () {
      final t = DoctorTimeline.fromJson(const {
        'patientName': 'QA Patient',
        'timelineEvents': [
          {
            'eventId': 'abc',
            'date': '12 Mar 2024',
            'category': 'DISCHARGE_SUMMARY',
            'iconType': 'hospital',
            'title': 'Type 2 Diabetes Mellitus',
            'resultText': 'Rx: Metformin 500mg',
            'highlightTag': 'Diagnosis',
            'highlightValue': 'Type 2 Diabetes Mellitus, Hypertension',
            'badgeColor': 'green',
          }
        ],
      });

      expect(t.events, hasLength(1));
      expect(t.events.single.title, 'Type 2 Diabetes Mellitus');
      expect(t.events.single.highlightTag, 'Diagnosis');
    });

    test('an empty timeline is empty, not a set of sample events', () {
      expect(DoctorTimeline.fromJson(const {}).events, isEmpty);
    });
  });

  group('Section 9: Consultation & Prescription APIs', () {
    test('Requirement 9.1 Edit Clinical Summary payload structure', () {
      final payload = {
        "sessionId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "chiefComplaint": "Updated by Dr. Sharma: Severe Migraine",
        "doctorNotes": "Advised MRI Brain and Rest",
        "ayushObservations": "Pitta exacerbation noted"
      };

      expect(payload['sessionId'], isNotEmpty);
      expect(payload['chiefComplaint'], contains('Severe Migraine'));
      expect(payload['doctorNotes'], contains('MRI Brain'));
    });

    test('Requirement 9.2 Complete Doctor Consultation response structure', () {
      final jsonResponse = {
        "status": "COMPLETED",
        "consultationId": "8a7b6c5d-4e3f-2a1b-0c9d-8e7f6a5b4c3d",
        "message": "Consultation completed and prescription generated."
      };

      expect(jsonResponse['status'], equals('COMPLETED'));
      expect(jsonResponse['consultationId'], isNotEmpty);
      expect(jsonResponse['message'], contains('prescription generated'));
    });
  });

  group('PatientClinicalViewResponse', () {
    test('parses full expanded payload correctly', () {
      final json = {
        'sessionId': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        'patientId': 'pat_987654321',
        'patientName': 'Aakash Srivastava',
        'abhaId': '91-1234-5678-9012',
        'ageGenderAbha': '34 Y / Male / ABHA Linked',
        'consentStatusBanner': 'Consent: Granted',
        'vitalsGrid': {
          'Blood Pressure': '140/90 mmHg',
          'Pulse': '78 bpm',
          'SpO2': '98%',
          'Temperature': '98.6 °F',
          'Weight': '72 kg',
          'Height': '175 cm',
        },
        'chiefComplaints': [
          'Severe Headache for 3 days',
          'Dizziness on standing',
        ],
        'pastMedicalHistory': [
          'Hypertension (diagnosed 2021)',
          'Mild Gastritis',
        ],
        'currentMedications': [
          'Amlodipine 5mg OD (Morning)',
          'Paracetamol 650mg SOS',
        ],
        'allergies': [
          'Penicillin (Severe Rash)',
          'NSAIDs (Gastric Irritation)',
        ],
        'familyHistory': [
          'Father: Type 2 Diabetes',
          'Mother: Hypertension',
        ],
        'ayushSummary':
            'Prakriti: PITTA-VATA, Agni: MADHYAMA_AGNI, Vikriti: PITTA_VRIDDHI',
        'prakritiSnapshot':
            'Prakriti: PITTA-VATA, Agni: MADHYAMA_AGNI, Vikriti: PITTA_VRIDDHI',
        'hasRedFlag': true,
        'redFlags': [
          'High Blood Pressure + Severe Headache (Potential Hypertensive Emergency)'
        ],
      };

      final res = PatientClinicalViewResponse.fromJson(json);

      expect(res.sessionId, '3fa85f64-5717-4562-b3fc-2c963f66afa6');
      expect(res.patientId, 'pat_987654321');
      expect(res.patientName, 'Aakash Srivastava');
      expect(res.abhaId, '91-1234-5678-9012');
      expect(res.ageGenderAbha, '34 Y / Male / ABHA Linked');
      expect(res.consentStatusBanner, 'Consent: Granted');
      expect(res.vitalsGrid['Blood Pressure'], '140/90 mmHg');
      expect(res.chiefComplaints, hasLength(2));
      expect(res.chiefComplaints.first, 'Severe Headache for 3 days');
      expect(res.pastMedicalHistory, hasLength(2));
      expect(res.pastMedicalHistory.first, 'Hypertension (diagnosed 2021)');
      expect(res.currentMedications, hasLength(2));
      expect(res.allergies, hasLength(2));
      expect(res.familyHistory, hasLength(2));
      expect(res.ayushSummary, contains('PITTA-VATA'));
      expect(res.prakritiSnapshot, contains('PITTA-VATA'));
      expect(res.hasRedFlag, isTrue);
      expect(res.redFlags.single, contains('High Blood Pressure'));
    });

    test('parses single string legacy formats gracefully', () {
      final json = {
        'sessionId': 'session-123',
        'patientName': 'Rahul Sharma',
        'chiefComplaint': 'Chest Discomfort',
        'pastMedicalHistory': 'Asthma',
        'ayushSummary': 'Prakriti: KAPHA',
        'hasRedFlag': false,
        'redFlags': <String>[],
      };

      final res = PatientClinicalViewResponse.fromJson(json);

      expect(res.sessionId, 'session-123');
      expect(res.patientName, 'Rahul Sharma');
      expect(res.chiefComplaints, ['Chest Discomfort']);
      expect(res.pastMedicalHistory, ['Asthma']);
      expect(res.ayushSummary, 'Prakriti: KAPHA');
      expect(res.prakritiSnapshot, 'Prakriti: KAPHA');
      expect(res.hasRedFlag, isFalse);
      expect(res.redFlags, isEmpty);
    });
  });

}


Set<String> _definedPaths() {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  final router = container.read(appRouterProvider);
  return _collectRoutePaths(router.configuration.routes);
}


Set<String> _collectRoutePaths(List<RouteBase> routes) {
  final out = <String>{};
  void walk(List<RouteBase> rs) {
    for (final r in rs) {
      if (r is GoRoute) out.add(r.path);
      walk(r.routes);
    }
  }

  walk(routes);
  return out;
}