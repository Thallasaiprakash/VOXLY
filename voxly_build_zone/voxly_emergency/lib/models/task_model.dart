import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String taskId;
  final String uid;
  final String title;
  final String dayOfWeek; // "mon" | "tue" ... "sun"
  final String weekId;    // "2026-W14"
  final String? time;     // "14:30"
  final String category;  // "work" | "personal" | "health" | "calls" | "other"
  final String priority;  // "normal" | "high" | "critical"
  final bool isCompleted;
  final DateTime? completedAt;
  final String repeat;    // "none" | "daily" | "weekly"
  final DateTime createdAt;

  Task({
    required this.taskId,
    required this.uid,
    required this.title,
    required this.dayOfWeek,
    required this.weekId,
    this.time,
    this.category = 'other',
    this.priority = 'normal',
    this.isCompleted = false,
    this.completedAt,
    this.repeat = 'none',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'uid': uid,
      'title': title,
      'dayOfWeek': dayOfWeek,
      'weekId': weekId,
      'time': time,
      'category': category,
      'priority': priority,
      'isCompleted': isCompleted,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'repeat': repeat,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      taskId: map['taskId'] ?? '',
      uid: map['uid'] ?? '',
      title: map['title'] ?? '',
      dayOfWeek: map['dayOfWeek'] ?? '',
      weekId: map['weekId'] ?? '',
      time: map['time'],
      category: map['category'] ?? 'other',
      priority: map['priority'] ?? 'normal',
      isCompleted: map['isCompleted'] ?? false,
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      repeat: map['repeat'] ?? 'none',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Task copyWith({
    String? taskId,
    String? uid,
    String? title,
    String? dayOfWeek,
    String? weekId,
    String? time,
    String? category,
    String? priority,
    bool? isCompleted,
    DateTime? completedAt,
    String? repeat,
    DateTime? createdAt,
  }) {
    return Task(
      taskId: taskId ?? this.taskId,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      weekId: weekId ?? this.weekId,
      time: time ?? this.time,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      repeat: repeat ?? this.repeat,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
