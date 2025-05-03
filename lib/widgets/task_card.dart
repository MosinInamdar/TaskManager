import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final taskService = Provider.of<TaskService>(context, listen: false);

    return Draggable<Task>(
      data: task,
      feedback: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300), // Prevent stretch
          child: Opacity(
            opacity: 0.85,
            child: _buildTaskCardContent(context, taskService),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.0, // Keep space, hide content
        child: _buildTaskCardContent(context, taskService),
      ),
      child: _buildTaskCardContent(context, taskService),
    );
  }

  Widget _buildTaskCardContent(BuildContext context, TaskService taskService) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(task.title),
        subtitle: task.description.isNotEmpty ? Text(task.description) : null,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'Delete') {
              taskService.deleteTask(task.id);
            } else {
              taskService.updateTaskStatus(task.id, value);
            }
          },
          itemBuilder:
              (context) => [
                if (task.status != 'To Do')
                  const PopupMenuItem(
                    value: 'To Do',
                    child: Text('Move to To Do'),
                  ),
                if (task.status != 'In Progress')
                  const PopupMenuItem(
                    value: 'In Progress',
                    child: Text('Move to In Progress'),
                  ),
                if (task.status != 'Completed')
                  const PopupMenuItem(
                    value: 'Completed',
                    child: Text('Move to Completed'),
                  ),
                const PopupMenuDivider(),
                const PopupMenuItem(value: 'Delete', child: Text('Delete')),
              ],
        ),
      ),
    );
  }
}
