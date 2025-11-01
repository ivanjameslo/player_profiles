class CourtSchedule {
  final String courtNumber;
  final DateTime startTime;
  final DateTime endTime;

  CourtSchedule({
    required this.courtNumber,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'courtNumber': courtNumber,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };
  }

  factory CourtSchedule.fromJson(Map<String, dynamic> json) {
    return CourtSchedule(
      courtNumber: json['courtNumber'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
    );
  }
}