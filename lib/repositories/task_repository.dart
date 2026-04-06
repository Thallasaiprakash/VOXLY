import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import 'auth_repository.dart';

final taskRepositoryProvider = Provider((ref) => TaskRepository(FirebaseFirestore.instance));

final tasksStreamProvider = StreamProvider.family<List<Task>, ({String weekId, String dayOfWeek})>((ref, arg) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(taskRepositoryProvider).getTasksForDay(user.uid, arg.weekId, arg.dayOfWeek);
});

class TaskRepository {
  final FirebaseFirestore _firestore;
  TaskRepository(this._firestore);

  CollectionReference get _tasks => _firestore.collection('tasks');

  Stream<List<Task>> getTasksForDay(String uid, String weekId, String dayOfWeek) {
    return _tasks
        .where('uid', isEqualTo: uid)
        .where('weekId', isEqualTo: weekId)
        .where('dayOfWeek', isEqualTo: dayOfWeek)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<void> addTask(Task task) async {
    await _tasks.doc(task.taskId).set(task.toMap());
  }

  Future<void> updateTask(Task task) async {
    await _tasks.doc(task.taskId).update(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _tasks.doc(taskId).delete();
  }

  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    await _tasks.doc(taskId).update({
      'isCompleted': isCompleted,
      'completedAt': isCompleted ? FieldValue.serverTimestamp() : null,
    });
  }
}
