import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final health = context.watch<HealthProvider>();
    final hrHistory = health.hrHistory;
    final riskHistory = health.riskHistory;

    double avgHr = hrHistory.isNotEmpty ? hrHistory.reduce((a, b) => a + b) / hrHistory.length : 0;
    double maxHr = hrHistory.isNotEmpty ? hrHistory.reduce(max) : 0;
    int avgRisk = riskHistory.isNotEmpty ? (riskHistory.reduce((a, b) => a + b) / riskHistory.length).round() : 0;
    int maxRisk = riskHistory.isNotEmpty ? riskHistory.reduce(max) : 0;

    return Scaffold(
      backgroundColor: const Color(0xFF020408),
      appBar: AppBar(
        title: const Text("Daily Health Summary"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(avgRisk),
            const SizedBox(height: 32),
            
            Text("STATISTICAL OVERVIEW", style: _headerStyle),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard("AVG HEART RATE", "${avgHr.toStringAsFixed(0)} BPM"),
                _buildStatCard("PEAK HEART RATE", "${maxHr.toStringAsFixed(0)} BPM"),
                _buildStatCard("AVG AI RISK", "$avgRisk / 100"),
                _buildStatCard("PEAK AI RISK", "$maxRisk / 100"),
              ],
            ),

            const SizedBox(height: 32),
            Text("RECOMMENDATIONS FOR TOMORROW", style: _headerStyle),
            const SizedBox(height: 16),
            _buildActionItem("Increase hydration by 500ml"),
            _buildActionItem("Aim for 7.5+ hours of sleep"),
            _buildActionItem("Maintain lifestyle score > 7"),
            
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C8FF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("CLOSE SUMMARY", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(int avgRisk) {
    String status = "EXCELLENT";
    Color color = const Color(0xFF39FF14);
    if (avgRisk > 60) { status = "CRITICAL"; color = const Color(0xFFFF003C); }
    else if (avgRisk > 30) { status = "STABLE"; color = const Color(0xFFFFEA00); }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("OVERALL STATUS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Text(status, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color, fontFamily: 'Outfit')),
              ],
            ),
          ),
          Icon(Icons.verified_user_rounded, color: color, size: 48),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white38, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildActionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Color(0xFF00C8FF), size: 20),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 14, color: Colors.white70)),
        ],
      ),
    );
  }

  TextStyle get _headerStyle => const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white38, letterSpacing: 2);
}
