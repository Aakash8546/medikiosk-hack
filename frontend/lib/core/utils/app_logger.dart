import 'package:flutter/foundation.dart';







void logApi(String message) {
  if (kDebugMode) {
    debugPrint('[API] $message');
  }
}

void logDebug(String tag, String message) {
  if (kDebugMode) {
    debugPrint('[$tag] $message');
  }
}



String maskId(String? identifier) {
  if (identifier == null || identifier.trim().isEmpty) return 'unknown';
  final digits = identifier.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length <= 4) return '****';
  return '****${digits.substring(digits.length - 4)}';
}



String describeKeys(Map<String, dynamic> payload) =>
    '{${payload.keys.join(', ')}}';