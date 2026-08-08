class LeaderboardModel {
  final String userId;
  final String name;
  final int score;
  final String? profilePic;

  final int? createdAt;

  final int? rankKey;

  final int? rank;

  const LeaderboardModel({
    this.userId = '',
    required this.name,
    required this.score,
    this.profilePic,
    this.createdAt,
    this.rankKey,
    this.rank,
  });

  factory LeaderboardModel.fromMap(Map<String, dynamic> map,
      {String userId = ''}) {
    return LeaderboardModel(
      userId: userId.isNotEmpty ? userId : (map['userid'] ?? ''),
      name: map['username'] ?? '',
      score: _toInt(map['score']) ?? 0,
      profilePic: map['profilePic'],
      createdAt: _toInt(map['createdAt']),
      rankKey: _toInt(map['rankKey']),
    );
  }

  LeaderboardModel copyWith({int? rank}) {
    return LeaderboardModel(
      userId: userId,
      name: name,
      score: score,
      profilePic: profilePic,
      createdAt: createdAt,
      rankKey: rankKey,
      rank: rank ?? this.rank,
    );
  }
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  if (value is String)
    return int.tryParse(value) ?? num.tryParse(value)?.toInt();
  return null;
}
