import 'package:intl/intl.dart';
import 'court_schedule.dart';

class Game {
  final String id;
  final String? title;
  final String courtName;
  final double courtRate;
  final double shuttleCockPrice;
  final bool divideCostEqually;
  final List<CourtSchedule> schedules;
  final DateTime createdAt;
  final int numberOfPlayers; // TODO: Will be replaced with actual player list
  
  Game({
    required this.id,
    this.title,
    required this.courtName,
    required this.courtRate,
    required this.shuttleCockPrice,
    required this.divideCostEqually,
    required this.schedules,
    required this.createdAt,
    this.numberOfPlayers = 4, // Default to 4 players
  });

  // Calculate total cost including court rate and shuttlecock price
  double get totalCost {
    double total = 0;
    
    // Calculate court rate for each schedule
    for (var schedule in schedules) {
      final hours = schedule.endTime.difference(schedule.startTime).inMinutes / 60.0;
      total += courtRate * hours;
    }
    
    // Add shuttlecock price
    total += shuttleCockPrice;
    
    return total;
  }

  // Get formatted display title
  String get displayTitle {
    if (title != null && title!.isNotEmpty) {
      return title!;
    }
    // If no title, use the earliest schedule date
    if (schedules.isNotEmpty) {
      final earliestSchedule = schedules.reduce(
        (a, b) => a.startTime.isBefore(b.startTime) ? a : b
      );
      return DateFormat('MMM d, y').format(earliestSchedule.startTime);
    }
    return 'Untitled Game';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'courtName': courtName,
      'courtRate': courtRate,
      'shuttleCockPrice': shuttleCockPrice,
      'divideCostEqually': divideCostEqually,
      'schedules': schedules.map((s) => s.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'numberOfPlayers': numberOfPlayers,
    };
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      title: json['title'],
      courtName: json['courtName'],
      courtRate: json['courtRate'],
      shuttleCockPrice: json['shuttleCockPrice'],
      divideCostEqually: json['divideCostEqually'],
      schedules: (json['schedules'] as List)
          .map((s) => CourtSchedule.fromJson(s))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      numberOfPlayers: json['numberOfPlayers'],
    );
  }
}