import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/clinical_summary.dart';

class SummaryNotifier extends StateNotifier<ClinicalSummary?> {
  SummaryNotifier() : super(null);

  void setSummary(ClinicalSummary s) => state = s;
  void clear() => state = null;
}

final summaryProvider =
    StateNotifierProvider<SummaryNotifier, ClinicalSummary?>(
        (ref) => SummaryNotifier());