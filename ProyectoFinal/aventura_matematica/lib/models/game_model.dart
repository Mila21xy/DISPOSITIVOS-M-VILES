class GameModel {
  final String id;
  final String userId;
  final String level;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final int totalTime;
  final DateTime playedAt;
  final double averageTime;

  GameModel({
    required this.id,
    required this.userId,
    required this.level,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.totalTime,
    required this.playedAt,
    required this.averageTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'level': level,
      'score': score,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'totalTime': totalTime,
      'playedAt': playedAt.millisecondsSinceEpoch,
      'averageTime': averageTime,
    };
  }

  factory GameModel.fromMap(Map<String, dynamic> map) {
    return GameModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      level: map['level'] ?? '',
      score: map['score'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      totalTime: map['totalTime'] ?? 0,
      playedAt: DateTime.fromMillisecondsSinceEpoch(map['playedAt'] ?? 0),
      averageTime: map['averageTime']?.toDouble() ?? 0.0,
    );
  }

  double get percentage => (correctAnswers / totalQuestions) * 100;

  String get levelDisplayName {
    switch (level) {
      case 'easy':
        return 'FÁCIL';
      case 'medium':
        return 'MEDIO';
      case 'hard':
        return 'DIFÍCIL';
      case 'freestyle':
        return 'LIBRE';
      default:
        return level.toUpperCase();
    }
  }
}

class Question {
  final String operation;
  final int correctAnswer;
  final List<int> options;
  final String operationType;

  Question({
    required this.operation,
    required this.correctAnswer,
    required this.options,
    required this.operationType,
  });

  Map<String, dynamic> toMap() {
    return {
      'operation': operation,
      'correctAnswer': correctAnswer,
      'options': options,
      'operationType': operationType,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      operation: map['operation'] ?? '',
      correctAnswer: map['correctAnswer'] ?? 0,
      options: List<int>.from(map['options'] ?? []),
      operationType: map['operationType'] ?? '',
    );
  }
}