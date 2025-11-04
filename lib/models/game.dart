import 'package:intl/intl.dart';
import 'court_schedule.dart';

class Game {
  final String id;
  final String? title;
  final String courtName;
  final double courtRate;          // rate per hour
  final double shuttleCockPrice;   // fixed add-on
  final bool divideCostEqually;    // kept for future use
  final List<CourtSchedule> schedules;
  final DateTime createdAt;

  Game({
    required this.id,
    this.title,
    required this.courtName,
    required this.courtRate,
    required this.shuttleCockPrice,
    required this.divideCostEqually,
    required this.schedules,
    required this.createdAt,
  });

  /// Sum of (courtRate * hours) for all valid schedules + shuttleCockPrice.
  /// Returns 0 for invalid values; never NaN/Infinity.
  double get totalCost {
    final hours = _totalHours();
    final rate   = courtRate.isFinite && courtRate > 0 ? courtRate : 0.0;
    final shuttle= shuttleCockPrice.isFinite && shuttleCockPrice > 0 ? shuttleCockPrice : 0.0;
    final cost = rate * hours + shuttle;
    return (cost.isFinite && !cost.isNaN) ? cost : 0.0;
  }

  /// Display title: explicit title if set; otherwise earliest schedule date; otherwise fallback.
  String get displayTitle {
    if (title != null && title!.trim().isNotEmpty) return title!.trim();
    if (schedules.isNotEmpty) {
      final earliest = schedules.reduce(
        (a, b) => a.startTime.isBefore(b.startTime) ? a : b,
      );
      return DateFormat('MMM d, y').format(earliest.startTime);
    }
    return 'Untitled Game';
  }

  // ------- Helpers -------

  /// Total booked hours across all schedules (ignores negative/zero durations).
  double _totalHours() {
    if (schedules.isEmpty) return 0.0;
    int totalMinutes = 0;
    for (final s in schedules) {
      final m = s.endTime.difference(s.startTime).inMinutes;
      if (m > 0) totalMinutes += m;
    }
    return totalMinutes > 0 ? totalMinutes / 60.0 : 0.0;
  }
}
