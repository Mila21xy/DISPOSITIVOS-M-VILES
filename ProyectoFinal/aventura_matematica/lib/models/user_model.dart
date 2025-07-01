class UserModel {
  final String id;
  final String name;
  final String email;
  final int totalGamesPlayed;
  final int bestScore;
  final String favoriteLevel;
  final DateTime createdAt;
  final DateTime lastLogin;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.totalGamesPlayed = 0,
    this.bestScore = 0,
    this.favoriteLevel = 'easy',
    required this.createdAt,
    required this.lastLogin,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'totalGamesPlayed': totalGamesPlayed,
      'bestScore': bestScore,
      'favoriteLevel': favoriteLevel,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLogin': lastLogin.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      totalGamesPlayed: map['totalGamesPlayed'] ?? 0,
      bestScore: map['bestScore'] ?? 0,
      favoriteLevel: map['favoriteLevel'] ?? 'easy',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastLogin: DateTime.fromMillisecondsSinceEpoch(map['lastLogin'] ?? 0),
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    int? totalGamesPlayed,
    int? bestScore,
    String? favoriteLevel,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      bestScore: bestScore ?? this.bestScore,
      favoriteLevel: favoriteLevel ?? this.favoriteLevel,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}