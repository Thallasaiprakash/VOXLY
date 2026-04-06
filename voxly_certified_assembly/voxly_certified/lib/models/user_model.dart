import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final DateTime createdAt;
  final int streakCount;
  final int totalXP;
  final Map<String, dynamic> settings;
  final Map<String, dynamic> moodLog; // "2026-04-04": 3

  UserModel({
    required this.uid,
    required this.name,
    required this.createdAt,
    this.streakCount = 0,
    this.totalXP = 0,
    required this.settings,
    required this.moodLog,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
      'streakCount': streakCount,
      'totalXP': totalXP,
      'settings': settings,
      'moodLog': moodLog,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      streakCount: map['streakCount'] ?? 0,
      totalXP: map['totalXP'] ?? 0,
      settings: Map<String, dynamic>.from(map['settings'] ?? {}),
      moodLog: Map<String, dynamic>.from(map['moodLog'] ?? {}),
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    DateTime? createdAt,
    int? streakCount,
    int? totalXP,
    Map<String, dynamic>? settings,
    Map<String, dynamic>? moodLog,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      streakCount: streakCount ?? this.streakCount,
      totalXP: totalXP ?? this.totalXP,
      settings: settings ?? this.settings,
      moodLog: moodLog ?? this.moodLog,
    );
  }
}
