class Task {
  final String id;
  String title;
  String description;
  String status; // "To Do", "In Progress", "Completed"
  DateTime? dueDate;
  bool isDaily;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.status = 'To Do',
    this.dueDate,
    this.isDaily = false,
  });
}
