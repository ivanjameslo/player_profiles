import 'package:flutter/foundation.dart';

import '../data/dummy_games.dart';
import '../models/court_schedule.dart';
import '../models/game.dart';

class GameConflict {
  GameConflict({
    required this.existingGame,
    required this.existingSchedule,
    required this.newSchedule,
  });

  final Game existingGame;
  final CourtSchedule existingSchedule;
  final CourtSchedule newSchedule;
}

class GameStore extends ChangeNotifier {
  GameStore._internal() {
    _games.addAll(DummyGames.games);
  }

  static final GameStore _instance = GameStore._internal();

  factory GameStore() => _instance;

  final List<Game> _games = [];

  List<Game> get games => List.unmodifiable(_games);

  void upsertGame(Game game) {
    final index = _games.indexWhere((g) => g.id == game.id);
    if (index == -1) {
      _games.add(game);
    } else {
      _games[index] = game;
    }
    notifyListeners();
  }

  void removeGame(String id) {
    final initialLength = _games.length;
    _games.removeWhere((g) => g.id == id);
    if (_games.length != initialLength) {
      notifyListeners();
    }
  }

  GameConflict? findConflict(Game candidate, {String? excludeGameId}) {
    for (final other in _games) {
      if (excludeGameId != null && other.id == excludeGameId) continue;

      for (final newSchedule in candidate.schedules) {
        for (final existingSchedule in other.schedules) {
          if (_isSameCourt(candidate.courtName, other.courtName) && // ✅ same court name (e.g., "Smashes")
              _isSameCourt(newSchedule.courtNumber, existingSchedule.courtNumber) && // ✅ same court number (e.g., "Court 1")
              _overlaps(newSchedule, existingSchedule)) {
            return GameConflict(
              existingGame: other,
              existingSchedule: existingSchedule,
              newSchedule: newSchedule,
            );
          }
        }
      }
    }
    return null;
  }

  bool _isSameCourt(String a, String b) =>
      a.trim().toLowerCase() == b.trim().toLowerCase();

  bool _overlaps(CourtSchedule a, CourtSchedule b) {
    final aStart = a.startTime;
    final aEnd = a.endTime;
    final bStart = b.startTime;
    final bEnd = b.endTime;
    return aStart.isBefore(bEnd) && aEnd.isAfter(bStart);
  }
}
