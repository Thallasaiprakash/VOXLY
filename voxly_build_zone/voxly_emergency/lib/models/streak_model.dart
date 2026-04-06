class StreakModel {
  final int currentStreak;
  final int longestStreak;
  final String lastCompletedDate;
  final List<String> badges;

  StreakModel({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedDate = '',
    this.badges = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastCompletedDate': lastCompletedDate,
      'badges': badges,
    };
  }

  factory StreakModel.fromMap(Map<String, dynamic> map) {
    return StreakModel(
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      lastCompletedDate: map['lastCompletedDate'] ?? '',
      badges: List<String>.from(map['badges'] ?? []),
    );
  }

  StreakModel copyWith({
    int? currentStreak,
    int? longestStreak,
    String? lastCompletedDate,
    List<String>? badges,
  }) {
    return StreakModel(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      badges: badges ?? this.badges,
    );
  }
}
