class Task {
  final String id;
  final String userId;
  String title;
  String description;
  String status; // "To Do", "In Progress", "Completed"
  DateTime? dueDate; 
  int priority;
  final List<Task> subtasks;
  List<String> categories;
  bool isRecurring;
  String recurrencePattern;
  List<String> userIds;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    this.status = 'To Do',
    this.dueDate,    
    this.priority = 0,
    List<Task> subtasks = const [],
    this.categories = const [],
    this.isRecurring = false,
    this.recurrencePattern = '',
    this.userIds = const [],
  }) : subtasks = subtasks
          .map((subtask) => Task(
                id: subtask.id,
                userId: userId,
                title: subtask.title,
                description: subtask.description,
                status: subtask.status,
                dueDate: subtask.dueDate,
                priority: subtask.priority,
                subtasks: subtask.subtasks,
                categories: subtask.categories,
                isRecurring: subtask.isRecurring,
                recurrencePattern: subtask.recurrencePattern,
                userIds: subtask.userIds,
              ))
          .toList();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'status': status,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'subtasks': subtasks.map((subtask) => subtask.toJson()).toList(),
      'categories': categories,
      'isRecurring': isRecurring,
      'recurrencePattern': recurrencePattern,
      'userIds': userIds,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'] ?? '',
      status: json['status'] ?? 'To Do',
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      priority: json['priority'] ?? 0,
      subtasks: json['subtasks'] != null
          ? (json['subtasks'] as List)
              .map((subtaskJson) => Task.fromJson(subtaskJson))
              .toList()
          : [],
      categories: List<String>.from(json['categories'] ?? []),
      isRecurring: json['isRecurring'] ?? false,
      recurrencePattern: json['recurrencePattern'] ?? '',
      userIds: List<String>.from(json['userIds'] ?? []),
    );
  }
}
