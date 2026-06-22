class LeaveConflictService {
  static Map<DateTime, int> countByDay(
      List<Map<String, dynamic>> leaves) {
    Map<DateTime, int> map = {};

    for (final l in leaves) {
      final start = DateTime.parse(l['start_date']);
      final end = DateTime.parse(l['end_date']);

      for (DateTime d = start;
          d.isBefore(end.add(const Duration(days: 1)));
          d = d.add(const Duration(days: 1))) {
        final key = DateTime(d.year, d.month, d.day);

        map[key] = (map[key] ?? 0) + 1;
      }
    }

    return map;
  }

  static String riskLevel(int count) {
    if (count >= 5) return "HIGH";
    if (count >= 3) return "MEDIUM";
    return "LOW";
  }
}