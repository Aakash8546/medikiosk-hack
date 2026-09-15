class AyushAssessment {
  final String? prakriti; 
  final String? vikriti;
  final String? agni;
  final String? koshtha;
  final String? aharaVihara;
  final String? nidana;
  final String? consultationType; 

  const AyushAssessment({
    this.prakriti,
    this.vikriti,
    this.agni,
    this.koshtha,
    this.aharaVihara,
    this.nidana,
    this.consultationType,
  });

  factory AyushAssessment.fromJson(Map<String, dynamic> json) =>
      AyushAssessment(
        prakriti: json['prakriti'] as String?,
        vikriti: json['vikriti'] as String?,
        agni: json['agni'] as String?,
        koshtha: json['koshtha'] as String?,
        aharaVihara: json['aharaVihara'] as String?,
        nidana: json['nidana'] as String?,
        consultationType: json['consultationType'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'prakriti': prakriti,
        'vikriti': vikriti,
        'agni': agni,
        'koshtha': koshtha,
        'aharaVihara': aharaVihara,
        'nidana': nidana,
        'consultationType': consultationType,
      };
}