import 'package:intl/intl.dart';
import 'court_schedule.dart';
import 'profile_item.dart';

class Game {
  final String id;
  final String? title;
  final String courtName;
  final double courtRate;          // rate per hour
  final double shuttleCockPrice;   // total price (will be divided by players)
  final bool divideCostEqually;    
  final String? shuttlecockChargedPlayerId;
  final String? courtPaidPlayerId;
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
    this.shuttlecockChargedPlayerId,
    this.courtPaidPlayerId,
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
    final splitCount = playerCount > 0 ? playerCount : 1;
    if (divideCostEqually) {
      final courtShare = _courtTotal / splitCount;
      final shuttleShare = _hasChargedShuttlePlayer ? 0.0 : (_safeShuttle / splitCount);
      return _sanitize(courtShare + shuttleShare);
    }
    // When not dividing equally, surface the full game cost.
    return _sanitize(_courtTotal + _safeShuttle);
  }

  double get totalGameCost => _sanitize(_courtTotal + _safeShuttle);

  ProfileItem? get shuttlecockChargedPlayer {
    if (shuttlecockChargedPlayerId == null) return null;
    for (final player in players) {
      if (player.id == shuttlecockChargedPlayerId) {
        return player;
      }
    }
    return null;
  }

  ProfileItem? get courtPaidPlayer {
    if (courtPaidPlayerId == null) return null;
    for (final player in players) {
      if (player.id == courtPaidPlayerId) {
        return player;
      }
    }
    return null;
  }

  bool isChargedForShuttlecock(ProfileItem player) =>
      shuttlecockChargedPlayerId != null &&
      player.id == shuttlecockChargedPlayerId;

  bool isCourtCostPayer(ProfileItem player) =>
      courtPaidPlayerId != null && player.id == courtPaidPlayerId;

  double shuttleShareForPlayer(ProfileItem player) {
    final splitCount = playerCount > 0 ? playerCount : 1;
    if (_hasChargedShuttlePlayer) {
      return isChargedForShuttlecock(player) ? _safeShuttle : 0.0;
    }
    return _sanitize(_safeShuttle / splitCount);
  }

  double costForPlayer(ProfileItem player) {
    final splitCount = playerCount > 0 ? playerCount : 1;
    double total = 0.0;

    if (divideCostEqually) {
      total += _courtTotal / splitCount;
    } else if (isCourtCostPayer(player)) {
      total += _courtTotal;
    }

    if (_hasChargedShuttlePlayer) {
      if (isChargedForShuttlecock(player)) {
        total += _safeShuttle;
      }
    } else {
      total += _safeShuttle / splitCount;
    }

    return _sanitize(total);
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

  double get _courtTotal {
    final hours = _totalHours();
    final rate = courtRate.isFinite && courtRate > 0 ? courtRate : 0.0;
    final total = rate * (hours == 0 ? 1 : hours);
    return _sanitize(total);
  }

  double get _safeShuttle =>
      (shuttleCockPrice.isFinite && shuttleCockPrice > 0)
          ? shuttleCockPrice
          : 0.0;

  bool get _hasChargedShuttlePlayer =>
      shuttlecockChargedPlayerId != null && shuttlecockChargedPlayer != null;

  double _sanitize(double value) =>
      (!value.isFinite || value.isNaN) ? 0.0 : value;
}
