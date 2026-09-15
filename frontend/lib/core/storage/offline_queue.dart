class OfflineQueue {
  final List<Map<String, dynamic>> _queue = [];

  void add({
    required String method,
    required String endpoint,
    required Map<String, dynamic> body,
  }) {
    _queue.add({
      'method': method,
      'endpoint': endpoint,
      'body': body,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  List<Map<String, dynamic>> get pending => List.unmodifiable(_queue);

  void clear() => _queue.clear();

  void removeAt(int index) => _queue.removeAt(index);
}