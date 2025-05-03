import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';

class TaskService with ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  void addTask(String title) {
    _tasks.add(Task(id: Uuid().v4(), title: title));
    notifyListeners();
  }

  void updateTaskStatus(String taskId, String newStatus) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index].status = newStatus;
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }
}
