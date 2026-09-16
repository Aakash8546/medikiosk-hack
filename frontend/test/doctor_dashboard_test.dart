import 'package:flutter_test/flutter_test.dart';
import 'package:medikiosk/models/doctor_dashboard_response.dart';

void main() {
  group('DoctorDashboardResponse Parsing & Sorting', () {
    test('parses JSON list response and sorts by Red Flag Priority', () {
      final jsonList = [
        {
          "sessionId": "session-normal",
          "tokenNumber": "MK-101",
          "patientName": "Normal Patient",
          "isRedFlag": false,
          "priority": "NORMAL",
          "sessionType": "GENERAL",
          "status": "WAITING"
        },
        {
          "sessionId": "session-critical",
          "tokenNumber": "MK-782",
          "patientName": "Aakash Srivastava",
          "isRedFlag": true,
          "priority": "CRITICAL",
          "sessionType": "AYUSH",
          "status": "REVIEW"
        },
        {
          "sessionId": "session-high",
          "tokenNumber": "MK-202",
          "patientName": "High Priority Patient",
          "isRedFlag": false,
          "priority": "HIGH",
          "sessionType": "AYUSH",
          "status": "WAITING"
        }
      ];

      final response = DoctorDashboardResponse.fromJson(jsonList);

      expect(response.patientQueue.length, 3);
      
      expect(response.patientQueue[0].sessionId, 'session-critical');
      expect(response.patientQueue[0].isRedFlag, isTrue);
      expect(response.patientQueue[0].priority, 'CRITICAL');
      expect(response.patientQueue[0].patientName, 'Aakash Srivastava');
      expect(response.patientQueue[0].tokenNumber, 'MK-782');
      expect(response.patientQueue[0].sessionType, 'AYUSH');
      expect(response.patientQueue[0].status, 'REVIEW');

      
      expect(response.patientQueue[1].sessionId, 'session-high');
      expect(response.patientQueue[1].priority, 'HIGH');

      
      expect(response.patientQueue[2].sessionId, 'session-normal');
      expect(response.patientQueue[2].priority, 'NORMAL');
    });

    test('parses JSON map response and sorts queue', () {
      final jsonMap = {
        "doctorName": "Arjun",
        "specialty": "General Medicine",
        "totalPatientsToday": 10,
        "activeNow": 3,
        "opdCountToday": 10,
        "completedCountToday": 7,
        "patientQueue": [
          {
            "sessionId": "sess-1",
            "patientName": "Patient 1",
            "isRedFlag": false,
            "priority": "NORMAL"
          },
          {
            "sessionId": "sess-2",
            "patientName": "Patient 2",
            "isRedFlag": true,
            "priority": "CRITICAL"
          }
        ]
      };

      final response = DoctorDashboardResponse.fromJson(jsonMap);

      expect(response.doctorName, 'Arjun');
      expect(response.specialty, 'General Medicine');
      expect(response.patientQueue.first.sessionId, 'sess-2');
      expect(response.patientQueue.first.isRedFlag, isTrue);
    });
  });
}