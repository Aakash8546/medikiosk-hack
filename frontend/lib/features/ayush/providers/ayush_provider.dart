import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/ayush_assessment.dart';

class AyushNotifier extends StateNotifier<AyushAssessment> {
  AyushNotifier() : super(const AyushAssessment());

  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
  }

  void setPrakriti(String p) => state = AyushAssessment(
        prakriti: p,
        vikriti: state.vikriti,
        agni: state.agni,
        koshtha: state.koshtha,
        aharaVihara: state.aharaVihara,
        nidana: state.nidana,
        consultationType: state.consultationType,
      );

  void setVikriti(String v) => state = AyushAssessment(
        prakriti: state.prakriti,
        vikriti: v,
        agni: state.agni,
        koshtha: state.koshtha,
        aharaVihara: state.aharaVihara,
        nidana: state.nidana,
        consultationType: state.consultationType,
      );

  void setAgni(String a) => state = AyushAssessment(
        prakriti: state.prakriti,
        vikriti: state.vikriti,
        agni: a,
        koshtha: state.koshtha,
        aharaVihara: state.aharaVihara,
        nidana: state.nidana,
        consultationType: state.consultationType,
      );

  void setKoshtha(String k) => state = AyushAssessment(
        prakriti: state.prakriti,
        vikriti: state.vikriti,
        agni: state.agni,
        koshtha: k,
        aharaVihara: state.aharaVihara,
        nidana: state.nidana,
        consultationType: state.consultationType,
      );

  void setAharaVihara(String a) => state = AyushAssessment(
        prakriti: state.prakriti,
        vikriti: state.vikriti,
        agni: state.agni,
        koshtha: state.koshtha,
        aharaVihara: a,
        nidana: state.nidana,
        consultationType: state.consultationType,
      );

  void reset() => state = const AyushAssessment();
}

final ayushProvider =
    StateNotifierProvider<AyushNotifier, AyushAssessment>(
        (ref) => AyushNotifier());



class PrakritiAnswersNotifier extends StateNotifier<Map<int, Map<int, int>>> {
  PrakritiAnswersNotifier() : super({});

  void setAnswer(int step, int questionIndex, int optionIndex) {
    state = {
      ...state,
      step: {
        ...(state[step] ?? {}),
        questionIndex: optionIndex,
      },
    };
  }

  void reset() => state = {};
}

final prakritiAnswersProvider =
    StateNotifierProvider<PrakritiAnswersNotifier, Map<int, Map<int, int>>>(
        (ref) => PrakritiAnswersNotifier());

class AgniState {
  final String appetite;
  final String afterMeals;
  final String digestion;

  const AgniState({
    this.appetite = 'strong',
    this.afterMeals = 'some heaviness',
    this.digestion = 'slow',
  });

  AgniState copyWith({
    String? appetite,
    String? afterMeals,
    String? digestion,
  }) {
    return AgniState(
      appetite: appetite ?? this.appetite,
      afterMeals: afterMeals ?? this.afterMeals,
      digestion: digestion ?? this.digestion,
    );
  }

  Map<String, String> toJson() => {
        'appetite': appetite,
        'afterMeals': afterMeals,
        'digestion': digestion,
      };
}

class AgniAnswersNotifier extends StateNotifier<AgniState> {
  AgniAnswersNotifier() : super(const AgniState());

  void setAppetite(String value) => state = state.copyWith(appetite: value);
  void setAfterMeals(String value) => state = state.copyWith(afterMeals: value);
  void setDigestion(String value) => state = state.copyWith(digestion: value);

  void reset() => state = const AgniState();
}

final agniAnswersProvider =
    StateNotifierProvider<AgniAnswersNotifier, AgniState>(
        (ref) => AgniAnswersNotifier());
