import 'package:flutter/material.dart';
import '../models/health_models.dart';

class RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;

  const RecommendationCard({super.key, required this.recommendation});

  Color _getPriorityColor() {
    switch (recommendation.priority) {
      case RecommendationPriority.critical:
        return const Color(0xFFFF003C);
      case RecommendationPriority.high:
        return const Color(0xFFFFEA00);
      case RecommendationPriority.medium:
        return const Color(0xFF00C8FF);
      case RecommendationPriority.low:
        return const Color(0xFF00F0FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getPriorityColor();
    final isUrgent = recommendation.priority == RecommendationPriority.critical ||
        recommendation.priority == RecommendationPriority.high;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUrgent ? color.withOpacity(0.05) : Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgent ? color.withOpacity(0.3) : Colors.white.withOpacity(0.08),
          width: 1.2,
        ),
        boxShadow: isUrgent ? [
          BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ] : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  _getIcon(recommendation.category),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            title: Text(
              recommendation.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              recommendation.category.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color.withOpacity(0.85),
                letterSpacing: 1.2,
              ),
            ),
            trailing: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white.withOpacity(0.3),
              size: 20,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(64, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.5,
                      ),
                    ),
                    if (recommendation.actions.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        "SUGGESTED ACTIONS:",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white38,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...recommendation.actions.map((action) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(
                              action,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            )),
                          ],
                        ),
                      )).toList(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getIcon(String category) {
    switch (category) {
      case 'hydration': return '💧';
      case 'rest': return '🛌';
      case 'activity': return '🚶';
      case 'breathing': return '🧘';
      case 'stress': return '🧠';
      case 'nutrition': return '🍎';
      case 'doctor': return '👨‍⚕️';
      case 'emergency': return '🚨';
      case 'preventive': return '🛡️';
      case 'sleep': return '😴';
      case 'medication': return '💊';
      default: return 'ℹ️';
    }
  }
}
