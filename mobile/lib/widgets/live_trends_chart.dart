import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LiveTrendsChart extends StatelessWidget {
  final List<double> hrHistory;
  final List<int> riskHistory;

  const LiveTrendsChart({
    super.key,
    required this.hrHistory,
    required this.riskHistory,
  });

  @override
  Widget build(BuildContext context) {
    if (hrHistory.isEmpty) {
      return const Center(child: Text("Waiting for data..."));
    }

    return AspectRatio(
      aspectRatio: 2.2,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 20,
            verticalInterval: 10,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white.withOpacity(0.04),
              strokeWidth: 1,
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: Colors.white.withOpacity(0.02),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 25,
                reservedSize: 32,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 9, color: Colors.white24),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 59,
          minY: 0,
          maxY: 150,
          lineBarsData: [
            // Risk Line (Neon Cyan Glow)
            LineChartBarData(
              spots: riskHistory.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.toDouble());
              }).toList(),
              isCurved: true,
              color: const Color(0xFF00F0FF),
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00F0FF).withOpacity(0.15),
                    const Color(0xFF00F0FF).withOpacity(0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Heart Rate Line (Muted White)
            LineChartBarData(
              spots: hrHistory.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value);
              }).toList(),
              isCurved: true,
              color: Colors.white.withOpacity(0.35),
              barWidth: 1.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 150),
        curve: Curves.linear,
      ),
    );
  }
}
