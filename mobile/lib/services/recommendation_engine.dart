import '../models/health_models.dart';

class RecommendationEngine {
  static List<Recommendation> generate(Vitals vitals, Prediction? prediction) {
    final List<Recommendation> recs = [];
    final double hr = vitals.heartRate;
    final double spo2 = vitals.spo2;
    final double temp = vitals.temperatureC;
    final int medHist = vitals.medicalHistory;
    final int lifestyle = vitals.lifestyleScore;
    final int riskScore = prediction?.riskScore ?? 0;
    final String riskCat = prediction?.category ?? "Normal";

    // 1. EMERGENCY EARLY WARNINGS
    bool critHr = hr > 130 || hr < 55;
    bool critSpo2 = spo2 < 90;
    bool critTemp = temp > 38.5 || temp < 35.5;
    int critCount = [critHr, critSpo2, critTemp].where((b) => b).length;

    if (critCount >= 2 || riskCat == "High Risk") {
      recs.add(Recommendation(
        id: "emergency-multi",
        category: "emergency",
        priority: RecommendationPriority.critical,
        title: "Multiple Abnormal Vitals — Emergency Warning",
        message: "Multiple vitals are abnormal—contact your doctor immediately. This alert is triggered by synchronized critical parameters.",
        actions: ["Contact your doctor immediately", "Alert family or near ones", "Avoid any physical movement"],
        popup: true,
      ));
    }

    // 2. HYDRATION MANAGEMENT
    if (temp > 37.8 || (hr > 110 && spo2 < 96)) {
      recs.add(Recommendation(
        id: "hydration-alert",
        category: "hydration",
        priority: temp > 38.5 ? RecommendationPriority.high : RecommendationPriority.medium,
        title: "Dehydration Risk Detected",
        message: "You seem a bit dehydrated—drink a glass of water now. High body temperature and elevated heart rate are primary indicators.",
        actions: ["Drink a glass of water now", "Move to a cool environment", "Avoid electrolytes/caffeine"],
        popup: temp > 38.5,
      ));
    }

    // 3. REST & ACTIVITY GUIDANCE
    if (hr > 110) {
      recs.add(Recommendation(
        id: "rest-guidance",
        category: "rest",
        priority: hr > 130 ? RecommendationPriority.high : RecommendationPriority.medium,
        title: "Elevated Heart Rate — Rest Mandatory",
        message: "Your heart rate is elevated—take a 10-minute rest. Continuous high HR can lead to strain and fatigue.",
        actions: ["Sit or lie down for 10 minutes", "Practice deep breathing", "Stop current activity immediately"],
        popup: hr > 130,
      ));
    }

    // 4. LOW ACTIVITY
    if (lifestyle <= 3 && hr < 85 && riskScore < 25) {
      recs.add(Recommendation(
        id: "activity-low",
        category: "activity",
        priority: RecommendationPriority.low,
        title: "Inactivity Detected — Stretch or Walk",
        message: "You have been inactive for a while. A short walk or some light stretching will improve your circulation.",
        actions: ["Take a 5-minute walk", "Perform light neck and arm stretches", "Stand up and move"],
      ));
    }

    // 5. MEDICATION REMINDERS
    if (medHist >= 5 && (riskScore >= 25 || hr > 110)) {
      recs.add(Recommendation(
        id: "medication-reminder",
        category: "medication",
        priority: RecommendationPriority.high,
        title: "Routine Medication Due?",
        message: "Time to take your blood pressure or routine medicine. Your current vitals are slightly high or showing stress.",
        actions: ["Verify medication schedule", "Take prescribed dose", "Ensure you have enough water"],
        popup: true,
      ));
    }

    // 6. SLEEP RECOMMENDATIONS
    if (lifestyle < 4 && medHist > 3 && riskScore > 15) {
      recs.add(Recommendation(
        id: "sleep-recommendation",
        category: "sleep",
        priority: RecommendationPriority.medium,
        title: "Insufficient Recovery Detected",
        message: "You had markers of fatigue—consider a short nap or earlier bedtime tonight to allow your body to recover.",
        actions: ["Plan for early bedtime", "Take a 20-minute power nap", "Limit screen use 1hr before bed"],
      ));
    }

    // 7. DIET & NUTRITION ALERTS
    if (spo2 < 95) {
      recs.add(Recommendation(
        id: "nutrition-diet",
        category: "nutrition",
        priority: spo2 < 94 ? RecommendationPriority.high : RecommendationPriority.medium,
        title: "Blood Oxygen Sub-optimal — Consider Nutrition",
        message: "Your blood oxygen is slightly low—consider a nutritious snack, light meal, or moving to a better-ventilated area.",
        actions: ["Eat a healthy, iron-rich snack", "Move to an open space with fresh air", "Take deep, controlled breaths"],
        popup: spo2 < 90,
      ));
    }

    // 8. STRESS & MENTAL HEALTH CHECK
    if (hr > 100 && lifestyle < 6) {
      recs.add(Recommendation(
        id: "stress-mental-health",
        category: "stress",
        priority: RecommendationPriority.medium,
        title: "Stress Indicators Detected",
        message: "Stress indicators detected—try a 5-minute breathing exercise to help lower your heart rate and center yourself.",
        actions: ["Try 4-7-8 breathing technique", "Listen to calming music", "Close your eyes for 2 minutes"],
      ));
    }

    // 9. PREVENTIVE HEALTH ALERTS
    if (riskScore >= 25 && riskScore < 50 && recs.isEmpty) {
      recs.add(Recommendation(
        id: "preventive-alert",
        category: "preventive",
        priority: RecommendationPriority.medium,
        title: "Mild Risk — Be Proactive",
        message: "Your AI score shows mild dehydration and fatigue—hydrate and take rest before symptoms appear.",
        actions: ["Increase water intake", "Avoid physical strain", "Monitor vitals for next 30 mins"],
      ));
    }

    // 10. ALL CLEAR
    if (recs.isEmpty && riskScore < 15) {
      recs.add(Recommendation(
        id: "status-excellent",
        category: "preventive",
        priority: RecommendationPriority.low,
        title: "Health Status: Excellent 👍",
        message: "All vitals are within optimal ranges. Maintain your current routine and stay hydrated.",
        actions: ["Stay consistent with your routine", "Keep hydrating"],
      ));
    }

    // Sort by priority (critical first)
    recs.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    return recs;
  }
}
