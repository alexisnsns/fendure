class TrainingActivity {
  final String name;
  final DateTime date;
  final String type;

  TrainingActivity({
    required this.name,
    required this.date,
    required this.type,
  });
}

class sportSession {
  final int id;
  final DateTime date;
  final double distance;
  final String discipline;
  final int duration;
  final int sensations;
  final String? userId;

  // Constructor to initialize the session
  sportSession({
    required this.id,
    required this.date,
    required this.distance,
    required this.discipline,
    required this.duration,
    required this.sensations,
    this.userId,
  });

  // Factory constructor to create a session from a map (database response)
  factory sportSession.fromMap(Map<String, dynamic> map) {
    return sportSession(
      id: map['id'],
      date: DateTime.parse(map['date']),
      distance: map['distance'].toDouble(),
      discipline: map['discipline'],
      duration: map['duration'],
      sensations: map['sensations'],
      userId: map['user_id'],
    );
  }
}
