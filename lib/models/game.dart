import 'package:intl/intl.dart';
import 'court_schedule.dart';
import 'profile_item.dart';

class Game {
  final String id;
  final String? title;
  final String courtName;
  final double courtRate;          // rate per hour
  final double shuttleCockPrice;   // total price (will be divided by players)
  final bool divideCostEqually;    // kept for future use
  final List<CourtSchedule> schedules;
  final DateTime createdAt;
  final List<ProfileItem> players;

  Game({
    required this.id,
    this.title,
    required this.courtName,
    required this.courtRate,
    required this.shuttleCockPrice,
    required this.divideCostEqually,
    required this.schedules,
    required this.createdAt,
    this.players = const [],
  });

  /// Count of selected players, defaults to 1 to avoid divide-by-zero when empty.
  int get playerCount => players.isNotEmpty ? players.length : 1;

  /// Sum of (courtRate * hours) for all valid schedules + (shuttleCockPrice / playerCount).
  /// Returns 0 for invalid values; never NaN/Infinity.
  /// --- Main cost computation ---
  double get totalCost {
    final hours = _totalHours();
    final rate = courtRate.isFinite && courtRate > 0 ? courtRate : 0.0;
    final shuttle = shuttleCockPrice.isFinite && shuttleCockPrice > 0 ? shuttleCockPrice : 0.0;
    final splitCount = playerCount > 0 ? playerCount : 1;

    final courtTotal = rate * (hours == 0 ? 1 : hours);
    final totalGameCost = courtTotal + shuttle;

    double cost;
    if (divideCostEqually) {
      // divide both court + shuttle among players
      cost = totalGameCost / splitCount;
    } else {
      // only shuttle is divided, court stays whole
      cost = courtTotal + (shuttle / splitCount);
    }

    return (cost.isFinite && !cost.isNaN) ? cost : 0.0;
  }

  /// --- Display Title ---
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

  /// --- Helper: total booked hours across all schedules ---
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
