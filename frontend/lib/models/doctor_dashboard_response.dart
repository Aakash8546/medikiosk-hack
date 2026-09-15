import 'package:flutter/material.dart';

class DoctorDashboardResponse {
  final String doctorName;
  final String specialty;
  final int totalPatientsToday;
  final int activeNow;
  final int opdCountToday;
  final int completedCountToday;
  final List<DoctorPatientQueueItem> patientQueue;

  const DoctorDashboardResponse({
    this.doctorName = '',
    this.specialty = '',
    required this.totalPatientsToday,
    required this.activeNow,
    required this.opdCountToday,
    required this.completedCountToday,
    required this.patientQueue,
  });

  factory DoctorDashboardResponse.fromJson(dynamic json) {
    if (json is List) {
      final queue = json
          .map((e) => DoctorPatientQueueItem.fromJson(e as Map<String, dynamic>))
          .toList();
      final sortedQueue = _sortQueue(queue);
      return DoctorDashboardResponse(
        totalPatientsToday: sortedQueue.length,
        activeNow: sortedQueue.where((p) => p.status.toUpperCase() != 'COMPLETED').length,
        opdCountToday: sortedQueue.length,
        completedCountToday: sortedQueue.where((p) => p.status.toUpperCase() == 'COMPLETED').length,
        patientQueue: sortedQueue,
      );
    } else if (json is Map<String, dynamic>) {
      final rawQueue = (json['patientQueue'] as List?)
              ?.map((e) => DoctorPatientQueueItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      final sortedQueue = _sortQueue(rawQueue);
      return DoctorDashboardResponse(
        doctorName: (json['doctorName'] as String?) ?? '',
        specialty: (json['specialty'] as String?) ?? '',
        totalPatientsToday: (json['totalPatientsToday'] as num?)?.toInt() ?? sortedQueue.length,
        activeNow: (json['activeNow'] as num?)?.toInt() ?? sortedQueue.where((p) => p.status.toUpperCase() != 'COMPLETED').length,
        opdCountToday: (json['opdCountToday'] as num?)?.toInt() ?? sortedQueue.length,
        completedCountToday: (json['completedCountToday'] as num?)?.toInt() ?? sortedQueue.where((p) => p.status.toUpperCase() == 'COMPLETED').length,
        patientQueue: sortedQueue,
      );
    }
    return const DoctorDashboardResponse(
      totalPatientsToday: 0,
      activeNow: 0,
      opdCountToday: 0,
      completedCountToday: 0,
      patientQueue: [],
    );
  }

  static List<DoctorPatientQueueItem> _sortQueue(List<DoctorPatientQueueItem> queue) {
    final list = List<DoctorPatientQueueItem>.from(queue);
    list.sort((a, b) {
      int rank(DoctorPatientQueueItem item) {
        if (item.isRedFlag || item.priority.toUpperCase() == 'CRITICAL') return 0;
        if (item.priority.toUpperCase() == 'HIGH') return 1;
        if (item.priority.toUpperCase() == 'MEDIUM') return 2;
        return 3;
      }

      final rankA = rank(a);
      final rankB = rank(b);
      return rankA.compareTo(rankB);
    });
    return list;
  }
}

class DoctorPatientQueueItem {
  final String sessionId;
  final String patientId;
  final String tokenNumber;
  final String patientName;
  final int age;
  final String gender;
  final String abhaId;
  final String sessionType;
  final String priority;
  final bool isRedFlag;
  final String primarySymptom;
  final String prakritiBadge;
  final String status;
  final String startedAt;

  const DoctorPatientQueueItem({
    required this.sessionId,
    required this.patientId,
    required this.tokenNumber,
    required this.patientName,
    required this.age,
    required this.gender,
    required this.abhaId,
    required this.sessionType,
    required this.priority,
    required this.isRedFlag,
    required this.primarySymptom,
    required this.prakritiBadge,
    required this.status,
    required this.startedAt,
  });

  factory DoctorPatientQueueItem.fromJson(Map<String, dynamic> json) {
    final sessId = json['sessionId'] as String? ?? '';
    final patId = json['patientId'] as String? ?? '';
    return DoctorPatientQueueItem(
      sessionId: sessId,
      patientId: patId.isNotEmpty ? patId : sessId,
      tokenNumber: json['tokenNumber'] as String? ?? '',
      patientName: json['patientName'] as String? ?? 'Unknown Patient',
      age: (json['age'] as num?)?.toInt() ?? 0,
      gender: json['gender'] as String? ?? '',
      abhaId: json['abhaId'] as String? ?? '',
      sessionType: json['sessionType'] as String? ?? 'General',
      priority: json['priority'] as String? ?? 'NORMAL',
      isRedFlag: json['isRedFlag'] as bool? ?? false,
      primarySymptom: json['primarySymptom'] as String? ?? '',
      prakritiBadge: json['prakritiBadge'] as String? ?? '',
      status: json['status'] as String? ?? 'WAITING',
      startedAt: json['startedAt'] as String? ?? '',
    );
  }

  Color get borderColor {
    if (isRedFlag || priority.toUpperCase() == 'CRITICAL') {
      return const Color(0xFFDC2626);
    }
    if (priority.toUpperCase() == 'HIGH') {
      return const Color(0xFFE85D3A);
    }
    if (sessionType.toUpperCase() == 'AYUSH') {
      return const Color(0xFF0F9FA8);
    }
    return const Color(0xFF3B82F6);
  }
}