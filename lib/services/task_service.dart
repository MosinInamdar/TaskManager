import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import 'package:path_provider/path_provider.dart';


class TaskService with ChangeNotifier {
  final List<Task> _tasks = [];
  String? currentUserId;

  UnmodifiableListView<Task> get tasks => currentUserId == null
      ? UnmodifiableListView([])
      : UnmodifiableListView(
          _tasks.where((task) => task.userId == currentUserId));

  void setUserId(String userId) {
    currentUserId = userId;
    loadData();
    notifyListeners();
  }

  Future<void> loadData() async {
    if (currentUserId == null) return;
    try {
      final file = await _getLocalFile(currentUserId!);
      if (!file.existsSync()) return;
      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = json.decode(jsonString);
      _tasks.clear();
      _tasks.addAll(jsonList.map((json) => Task.fromJson(json)));
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    }
  }

  Future<void> saveData() async {
    if (currentUserId == null) return;
    try {
      final file = await _getLocalFile(currentUserId!);
      final jsonString = json.encode(_tasks.map((task) => task.toJson()).toList());
      await file.writeAsString(jsonString);
    } catch (e) {
      debugPrint('Error saving tasks: $e');
    }
  }

  Future<File> _getLocalFile(String userId) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/tasks_$userId.txt');
  }

  void addTask({
    required String title,
    String description = '',
    String status = 'To Do',
    DateTime? dueDate,
    int priority = 0,
    List<Task> subtasks = const [],
    List<String> categories = const [],
    bool isRecurring = false,
    String recurrencePattern = '',
    List<String> userIds = const [],
  }) {
    if (currentUserId == null) return;

    final newTask = Task(
      id: const Uuid().v4(),
      title: title,
      description: description,
      status: status,
      dueDate: dueDate,
      priority: priority,
      subtasks: subtasks,
      categories: categories,
      isRecurring: isRecurring,
      recurrencePattern: recurrencePattern,
      userIds: userIds,
      userId: currentUserId!,
    );

    _tasks.add(newTask);
    saveData();
    notifyListeners();
  }

  void updateTask(Task task) {
    if (currentUserId == null) return;
    final index = _tasks.indexWhere((t) => t.id == task.id && t.userId == currentUserId);
    if (index != -1) {
      _tasks[index] = task;
      saveData();
      notifyListeners();
    }
  }

  void handleRecurrence(Task task) {
    if (currentUserId == null) return;

    if (task.isRecurring) {
      DateTime now = DateTime.now();
      DateTime nextDueDate;

      switch (task.recurrencePattern.toLowerCase()) {
        case 'daily':
          nextDueDate = now.add(const Duration(days: 1));
          break;
        case 'weekly':
          nextDueDate = now.add(const Duration(days: 7));
          break;
        case 'monthly':
          nextDueDate = DateTime(now.year, now.month + 1, now.day);
          break;
        default:
          return;
      }

      addTask(
        title: task.title,
        description: task.description,
        status: 'To Do',
        dueDate: nextDueDate,
        priority: task.priority,
        subtasks: List<Task>.from(task.subtasks),
        categories: List<String>.from(task.categories),
        isRecurring: task.isRecurring,
        recurrencePattern: task.recurrencePattern,
        userIds: List<String>.from(task.userIds),
      );
    }
  }

  List<Task> searchTasks(String query) {
    if (currentUserId == null) return [];

    return _tasks
        .where((task) => task.userId == currentUserId)
        .where((task) =>
            task.title.toLowerCase().contains(query.toLowerCase()) ||
            task.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void deleteTask(String id) {
    if (currentUserId == null) return;

    _tasks.removeWhere((task) => task.id == id && task.userId == currentUserId);
    saveData();
    notifyListeners();
  }
}
