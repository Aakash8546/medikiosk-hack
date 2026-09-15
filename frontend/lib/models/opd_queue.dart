class OpdQueue {
  final String? token;
  final String? department;
  final int? position;
  final int? estimatedWaitMinutes;
  final String? status; 
  final DateTime? createdAt;

  const OpdQueue({
    this.token,
    this.department,
    this.position,
    this.estimatedWaitMinutes,
    this.status,
    this.createdAt,
  });

  factory OpdQueue.fromJson(Map<String, dynamic> json) => OpdQueue(
        token: json['token'] as String?,
        department: json['department'] as String?,
        position: json['position'] as int?,
        estimatedWaitMinutes: json['estimatedWaitMinutes'] as int?,
        status: json['status'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
      );
}