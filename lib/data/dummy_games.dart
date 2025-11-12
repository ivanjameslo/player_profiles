import '../data/dummy_profiles.dart';
import '../models/court_schedule.dart';
import '../models/game.dart';

class DummyGames {
  static List<Game> get games {
    final now = DateTime.now();
    final profiles = DummyProfiles.profiles;
    return [
      Game(
        id: 'game_001',
        title: 'Weekend Tournament',
        courtName: 'ABC Badminton Center',
        courtRate: 500,
        shuttleCockPrice: 50,
        divideCostEqually: true,
        shuttlecockChargedPlayerId: null,
        courtPaidPlayerId: null,
        schedules: [
          CourtSchedule(
            courtNumber: 'Court 1',
            startTime: DateTime(now.year, now.month, now.day, 9, 0),
            endTime: DateTime(now.year, now.month, now.day, 12, 0),
          ),
          CourtSchedule(
            courtNumber: 'Court 2',
            startTime: DateTime(now.year, now.month, now.day, 10, 0),
            endTime: DateTime(now.year, now.month, now.day, 12, 0),
          ),
        ],
        createdAt: now.subtract(const Duration(days: 2)),
        players: profiles.take(4).toList(),
      ),
      Game(
        id: 'game_002',
        courtName: 'XYZ Sports Complex',
        courtRate: 400,
        shuttleCockPrice: 45,
        divideCostEqually: true,
        shuttlecockChargedPlayerId: profiles[1].id,
        courtPaidPlayerId: null,
        schedules: [
          CourtSchedule(
            courtNumber: 'Court 3',
            startTime: DateTime(now.year, now.month, now.day + 1, 18, 0),
            endTime: DateTime(now.year, now.month, now.day + 1, 21, 0),
          ),
        ],
        createdAt: now.subtract(const Duration(days: 1)),
        players: profiles.sublist(1, 5),
      ),
      Game(
        id: 'game_003',
        title: 'Practice Match',
        courtName: 'City Sports Center',
        courtRate: 350,
        shuttleCockPrice: 40,
        divideCostEqually: false,
        shuttlecockChargedPlayerId: null,
        courtPaidPlayerId: profiles[2].id,
        schedules: [
          CourtSchedule(
            courtNumber: 'Court A',
            startTime: DateTime(now.year, now.month, now.day + 2, 15, 0),
            endTime: DateTime(now.year, now.month, now.day + 2, 18, 0),
          ),
        ],
        createdAt: now,
        players: profiles.sublist(2, 4),
      ),
    ];
  }
}
