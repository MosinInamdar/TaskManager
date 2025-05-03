import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import 'task_card.dart';

class ColumnBoard extends StatelessWidget {
  final String title;
  final List<Task> tasks;

  const ColumnBoard({super.key, required this.title, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final taskService = Provider.of<TaskService>(context, listen: false);

    return DragTarget<Task>(
      onWillAccept: (task) => task != null && task.status != title,
      onAccept: (task) {
        taskService.updateTaskStatus(task.id, title);
      },
      builder:
          (context, candidateData, rejectedData) => Container(
            decoration: BoxDecoration(
              color:
                  candidateData.isNotEmpty
                      ? Colors.blue.shade50
                      : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    candidateData.isNotEmpty ? Colors.blue : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: ListView.builder(
                      key: ValueKey(
                        tasks.length,
                      ), // Forces rebuild on list change
                      itemCount: tasks.length,
                      itemBuilder:
                          (context, index) => TaskCard(task: tasks[index]),
                    ),
                  ),
                ),
                if (candidateData.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Drop to move task here',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
              ],
            ),
          ),
    );
  }
}
