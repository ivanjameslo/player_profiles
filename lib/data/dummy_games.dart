import '../models/game.dart';
import '../models/court_schedule.dart';

class DummyGames {
  static List<Game> get games {
    final now = DateTime.now();
    return [
      Game(
        id: 'game_001',
        title: 'Weekend Tournament',
        courtName: 'ABC Badminton Center',
        courtRate: 500,
        shuttleCockPrice: 50,
        divideCostEqually: true,
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
        numberOfPlayers: 8,
      ),
      Game(
        id: 'game_002',
        courtName: 'XYZ Sports Complex',
        courtRate: 400,
        shuttleCockPrice: 45,
        divideCostEqually: true,
        schedules: [
          CourtSchedule(
            courtNumber: 'Court 3',
            startTime: DateTime(now.year, now.month, now.day + 1, 18, 0),
            endTime: DateTime(now.year, now.month, now.day + 1, 21, 0),
          ),
        ],
        createdAt: now.subtract(const Duration(days: 1)),
        numberOfPlayers: 4,
      ),
      Game(
        id: 'game_003',
        title: 'Practice Match',
        courtName: 'City Sports Center',
        courtRate: 350,
        shuttleCockPrice: 40,
        divideCostEqually: false,
        schedules: [
          CourtSchedule(
            courtNumber: 'Court A',
            startTime: DateTime(now.year, now.month, now.day + 2, 15, 0),
            endTime: DateTime(now.year, now.month, now.day + 2, 18, 0),
          ),
        ],
        createdAt: now,
        numberOfPlayers: 6,
      ),
    ];
  }
}