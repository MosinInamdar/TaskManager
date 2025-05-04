import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../screens/task_detail_screen.dart';
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(
                task: task,
              ),
            ),
          );
        },
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title),
            if (task.dueDate != null)
              Text(
                DateFormat('dd/MM/yyyy').format(task.dueDate!),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Text(task.description),
            if(task.priority > 0)
              Row(
                children: [
                  for (int i = 0; i < task.priority; i++)
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                ],
              ),
            if (task.categories.isNotEmpty)
              Wrap(
                spacing: 4,
                children: task.categories
                    .map((category) => Chip(label: Text(category)))
                    .toList(),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'Delete':
                taskService.deleteTask(task.id);
                break;
              case 'To Do':
              case 'In Progress':
              case 'Completed':
                final updatedTask = Task(
                  id: task.id,
                  title: task.title,
                  description: task.description,
                  status: value,
                  dueDate: task.dueDate,
                  priority: task.priority,
                  subtasks: task.subtasks,
                  categories: task.categories,
                  isRecurring: task.isRecurring,
                  recurrencePattern: task.recurrencePattern,
                  userIds: task.userIds
                  , userId: task.userId
                );
                taskService.updateTask(updatedTask);
                if(value == "Completed"){
                  taskService.handleRecurrence(updatedTask);
                }
                break;
            }
          },
          itemBuilder: (context) => [
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
