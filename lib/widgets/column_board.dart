import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'package:provider/provider.dart';
import '../services/task_service.dart';
import 'task_card.dart';

class ColumnBoard extends StatelessWidget {
  final String title;
  final List<Task> tasks;
  final VoidCallback? onTaskUpdated;

  const ColumnBoard({
    super.key, 
    required this.title, 
    required this.tasks,
    this.onTaskUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final taskService = Provider.of<TaskService>(context, listen: false);
    
    return DragTarget<Task>(
      onWillAcceptWithDetails: (task) => task.data.status != title,
      onAcceptWithDetails: (task) {
        final updatedTask = Task(
          id: task.data.id,
          title: task.data.title,
          description: task.data.description,
          status: title,
          dueDate: task.data.dueDate,
          priority: task.data.priority,
          subtasks: task.data.subtasks,
          categories: task.data.categories,
          isRecurring: task.data.isRecurring, 
          recurrencePattern: task.data.recurrencePattern, 
          userIds: task.data.userIds, 
          userId: task.data.userId
        );
        
        taskService.updateTask(updatedTask);
        
        // Call the callback to update the parent state if provided
        if (onTaskUpdated != null) {
          onTaskUpdated!();
        }
      },
      builder: (context, candidateData, rejectedData) => Container(
        decoration: BoxDecoration(
          color: candidateData.isNotEmpty
              ? Colors.blue.shade50
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: candidateData.isNotEmpty ? Colors.blue : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              title, 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: ListView.builder(
                  key: ValueKey(tasks.length), 
                  itemCount: tasks.length,
                  itemBuilder: (context, index) => TaskCard(task: tasks[index]),
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