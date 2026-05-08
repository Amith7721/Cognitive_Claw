// Task decay score calculation logic
class DecayCalculator {
  // Returns a score from 0.0 to 1.0
  // Higher = more urgent/stale
  static double calculate({required DateTime lastUpdated, DateTime? dueDate}) {
    final now = DateTime.now();
    final daysSince = now.difference(lastUpdated).inDays;

    // Base score from staleness (40% weight)
    double score = (daysSince / 25).clamp(0.0, 0.4);

    // Add deadline urgency (60% weight)
    if (dueDate != null) {
      final daysLeft = dueDate.difference(now).inDays;
      final urgency = 1 - (daysLeft / 30).clamp(0.0, 1.0);
      score += urgency * 0.6;
    }

    return score.clamp(0.0, 1.0);
  }
}
