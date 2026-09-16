import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'connectivity_service.dart';
import '../core/network/dio_client.dart';

class OfflineSyncService {
  final ConnectivityService _connectivity;
  static const _key = 'offline_queue';

  OfflineSyncService(this._connectivity);

  Future<void> queueRequest({
    required String method,
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = await _getQueue();
    queue.add({
      'method': method,
      'endpoint': endpoint,
      'body': body,
      'createdAt': DateTime.now().toIso8601String(),
    });
    await prefs.setString(_key, jsonEncode(queue));
  }

  Future<void> syncPending() async {
    final connected = await _connectivity.checkConnection();
    if (!connected) return;

    final queue = await _getQueue();
    if (queue.isEmpty) return;

    final dio = MediKioskDio.instance;
    final remaining = <Map<String, dynamic>>[];

    for (final request in queue) {
      try {
        final method = request['method'] as String;
        final endpoint = request['endpoint'] as String;
        final body = request['body'] as Map<String, dynamic>;

        if (method == 'POST') {
          await dio.post(endpoint, data: body);
        } else if (method == 'PUT') {
          await dio.put(endpoint, data: body);
        } else if (method == 'DELETE') {
          await dio.delete(endpoint);
        }
      } catch (_) {
        remaining.add(request);
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(remaining));
  }

  Future<List<Map<String, dynamic>>> _getQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }
}