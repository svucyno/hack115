import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';
import '../widgets/vitals_gauge.dart';
import '../widgets/live_trends_chart.dart';
import '../widgets/recommendation_card.dart';
import 'emergency_screen.dart';
import 'summary_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final health = context.watch<HealthProvider>();
    final vitals = health.vitals;
    final prediction = health.prediction;

    if (health.isEmergency) {
      return const EmergencyScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF020408),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, prediction?.category ?? "Normal"),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vitals Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                    children: [
                      VitalsGauge(
                        value: vitals.heartRate,
                        min: 40,
                        max: 180,
                        label: "Heart Rate",
                        unit: "BPM",
                        color: vitals.heartRate > 120 ? const Color(0xFFFF003C) : vitals.heartRate > 100 ? const Color(0xFFFFEA00) : const Color(0xFF39FF14),
                        glowColor: vitals.heartRate > 120 ? const Color(0xFFFF003C) : vitals.heartRate > 100 ? const Color(0xFFFFEA00) : const Color(0xFF39FF14),
                      ),
                      VitalsGauge(
                        value: vitals.spo2,
                        min: 80,
                        max: 100,
                        label: "SpO2",
                        unit: "%",
                        color: vitals.spo2 < 90 ? const Color(0xFFFF003C) : vitals.spo2 < 95 ? const Color(0xFFFFEA00) : const Color(0xFF00C8FF),
                        glowColor: const Color(0xFF00C8FF),
                      ),
                      VitalsGauge(
                        value: vitals.temperatureC,
                        min: 35,
                        max: 41,
                        label: "Body Temp",
                        unit: "°C",
                        color: vitals.temperatureC > 38.5 ? const Color(0xFFFF003C) : vitals.temperatureC > 37.5 ? const Color(0xFFFFEA00) : const Color(0xFF4DC9F6),
                        glowColor: const Color(0xFF4DC9F6),
                      ),
                      VitalsGauge(
                        value: prediction?.riskScore.toDouble() ?? 0.0,
                        min: 0,
                        max: 100,
                        label: "AI Risk Score",
                        unit: "/ 100",
                        color: _getRiskColor(prediction?.category),
                        glowColor: _getRiskColor(prediction?.category),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Live Trends Chart
                  _buildSectionHeader("📊 Live Trends"),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: LiveTrendsChart(
                      hrHistory: health.hrHistory,
                      riskHistory: health.riskHistory,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Recommendations
                  _buildSectionHeader("🩺 AI Health Recommendations"),
                  const SizedBox(height: 16),
                  if (health.recommendations.isEmpty)
                    const Center(child: Text("Calculating...", style: TextStyle(color: Colors.white38)))
                  else
                    ...health.recommendations.map((rec) => RecommendationCard(recommendation: rec)).toList(),

                  const SizedBox(height: 32),

                  // Control Sliders
                  _buildSectionHeader("⚙️ Personalization"),
                  const SizedBox(height: 16),
                  _buildSliderCard(
                    context, 
                    "Medical History", 
                    vitals.medicalHistory.toDouble(), 
                    10, 
                    (v) => health.updateMedicalHistory(v.toInt())
                  ),
                  const SizedBox(height: 12),
                  _buildSliderCard(
                    context, 
                    "Lifestyle Score", 
                    vitals.lifestyleScore.toDouble(), 
                    10, 
                    (v) => health.updateLifestyleScore(v.toInt())
                  ),

                  const SizedBox(height: 48),
                  
                  // Simulation Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => health.simulateEmergency(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF003C).withOpacity(0.2),
                            foregroundColor: const Color(0xFFFF003C),
                            side: const BorderSide(color: Color(0xFFFF003C)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("⚡ Simulate Emergency", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => health.resumeNormal(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: BorderSide(color: Colors.white.withOpacity(0.2)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("↻ Resume Normal"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, String riskCat) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF020408),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Row(
          children: [
            const Text(
              "Lifeguard AI",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontFamily: 'Outfit',
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.bar_chart_rounded, color: Colors.white70),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SummaryScreen())),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getRiskColor(riskCat).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getRiskColor(riskCat).withOpacity(0.5)),
              ),
              child: Text(
                riskCat.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: _getRiskColor(riskCat),
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Colors.white38,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildSliderCard(BuildContext context, String label, double value, double max, Function(double) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
              Text("${value.toInt()} / ${max.toInt()}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: value,
            min: 0,
            max: max,
            activeColor: const Color(0xFF00C8FF),
            inactiveColor: Colors.white.withOpacity(0.1),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(String? cat) {
    if (cat == "High Risk") return const Color(0xFFFF003C);
    if (cat == "Warning") return const Color(0xFFFFEA00);
    return const Color(0xFF39FF14);
  }
}
