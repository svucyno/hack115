class Vitals {
  double heartRate;
  double spo2;
  double temperatureC;
  int medicalHistory;
  int lifestyleScore;

  Vitals({
    this.heartRate = 72,
    this.spo2 = 98,
    this.temperatureC = 36.7,
    this.medicalHistory = 0,
    this.lifestyleScore = 8,
  });

  Map<String, dynamic> toJson() => {
    'heart_rate': heartRate,
    'spo2': spo2,
    'temperature_c': temperatureC,
    'medical_history': medicalHistory,
    'lifestyle_score': lifestyleScore,
  };

  Vitals copyWith({
    double? heartRate,
    double? spo2,
    double? temperatureC,
    int? medicalHistory,
    int? lifestyleScore,
  }) {
    return Vitals(
      heartRate: heartRate ?? this.heartRate,
      spo2: spo2 ?? this.spo2,
      temperatureC: temperatureC ?? this.temperatureC,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      lifestyleScore: lifestyleScore ?? this.lifestyleScore,
    );
  }
}

class Prediction {
  final int riskScore;
  final String category;
  final int classIndex;
  final Map<String, double> probabilities;

  Prediction({
    required this.riskScore,
    required this.category,
    required this.classIndex,
    required this.probabilities,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      riskScore: json['risk_score'] ?? 0,
      category: json['category'] ?? 'Normal',
      classIndex: json['class_index'] ?? 0,
      probabilities: Map<String, double>.from(json['probabilities'] ?? {}),
    );
  }
}

enum RecommendationPriority { low, medium, high, critical }

class Recommendation {
  final String id;
  final String category;
  final RecommendationPriority priority;
  final String title;
  final String message;
  final List<String> actions;
  final bool popup;

  Recommendation({
    required this.id,
    required this.category,
    required this.priority,
    required this.title,
    required this.message,
    required this.actions,
    this.popup = false,
  });
}
