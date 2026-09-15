import 'package:intl/intl.dart';

class DateUtils {
  static String formatShort(DateTime date) =>
      DateFormat('dd MMM yyyy').format(date);

  static String formatTime(DateTime date) =>
      DateFormat('hh:mm a').format(date);

  static String formatRelative(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    if (diff.inDays < 7) return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    return formatShort(date);
  }

  static String formatWaitTime(int minutes) {
    if (minutes < 60) return '$minutes mins';
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    return remaining > 0 ? '${hours}h ${remaining}m' : '${hours}h';
  }
}