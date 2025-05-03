import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/task_service.dart';
import '../widgets/column_board.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskService = Provider.of<TaskService>(context);

    final todoTasks =
        taskService.tasks.where((task) => task.status == 'To Do').toList();
    final inProgressTasks =
        taskService.tasks
            .where((task) => task.status == 'In Progress')
            .toList();
    final completedTasks =
        taskService.tasks.where((task) => task.status == 'Completed').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Planner'),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: ColumnBoard(title: 'To Do', tasks: todoTasks)),
            const SizedBox(width: 10),
            Expanded(
              child: ColumnBoard(title: 'In Progress', tasks: inProgressTasks),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ColumnBoard(title: 'Completed', tasks: completedTasks),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final taskService = Provider.of<TaskService>(context, listen: false);
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Add New Task'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Enter task title'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    taskService.addTask(controller.text.trim());
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }
}
