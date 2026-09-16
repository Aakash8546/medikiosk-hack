import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/opd_queue.dart';

class QueueNotifier extends StateNotifier<OpdQueue?> {
  QueueNotifier() : super(null);

  void setQueue(OpdQueue q) => state = q;
  void clear() => state = null;
}

final queueProvider =
    StateNotifierProvider<QueueNotifier, OpdQueue?>(
        (ref) => QueueNotifier());