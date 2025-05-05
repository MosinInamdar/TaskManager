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
    final theme = Theme.of(context);

    // Status color mapping
    final Map<String, Color> statusColors = {
      'To Do': Colors.blue,
      'In Progress': Colors.amber,
      'Completed': Colors.green,
    };

    // Status icon mapping
    final Map<String, IconData> statusIcons = {
      'To Do': Icons.list_alt,
      'In Progress': Icons.play_circle_outline,
      'Completed': Icons.check_circle_outline,
    };

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
          userId: task.data.userId,
        );

        taskService.updateTask(updatedTask);

        // Call the callback to update the parent state if provided
        if (onTaskUpdated != null) {
          onTaskUpdated!();
        }
      },
      builder:
          (context, candidateData, rejectedData) => Container(
            decoration: BoxDecoration(
              color:
                  candidateData.isNotEmpty
                      ? statusColors[title]?.withOpacity(0.1) ??
                          Colors.grey[100]
                      : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    candidateData.isNotEmpty
                        ? statusColors[title] ?? Colors.blue
                        : statusColors[title]?.withOpacity(0.3) ??
                            Colors.grey.withOpacity(0.3),
                width: candidateData.isNotEmpty ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title, count, and icon
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: statusColors[title]?.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      // Status icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              statusColors[title]?.withOpacity(0.2) ??
                              Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          statusIcons[title] ?? Icons.list,
                          color: statusColors[title] ?? Colors.grey,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Title and count
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: statusColors[title] ?? Colors.grey[800],
                              ),
                            ),
                            Text(
                              '${tasks.length} task${tasks.length != 1 ? 's' : ''}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Task list
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                    ) {
                      return FadeTransition(
                        opacity: animation,
                        child: SizeTransition(
                          sizeFactor: animation,
                          child: child,
                        ),
                      );
                    },
                    child:
                        tasks.isEmpty
                            ? _buildEmptyState(context, title)
                            : ListView.builder(
                              key: ValueKey('${title}_${tasks.length}'),
                              itemCount: tasks.length,
                              itemBuilder:
                                  (context, index) =>
                                      TaskCard(task: tasks[index]),
                              padding: const EdgeInsets.symmetric(vertical: 4),
                            ),
                  ),
                ),

                // Drop indicator
                if (candidateData.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color:
                          statusColors[title]?.withOpacity(0.15) ??
                          Colors.blue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            statusColors[title]?.withOpacity(0.3) ??
                            Colors.blue.withOpacity(0.3),
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.input,
                            color: statusColors[title] ?? Colors.blue,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Drop to move task here',
                            style: TextStyle(
                              color: statusColors[title] ?? Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
    );
  }

  // Empty state placeholder with illustration
  Widget _buildEmptyState(BuildContext context, String title) {
    final messages = {
      'To Do': 'No pending tasks',
      'In Progress': 'No tasks in progress',
      'Completed': 'No completed tasks yet',
    };

    final icons = {
      'To Do': Icons.playlist_add,
      'In Progress': Icons.pending_actions,
      'Completed': Icons.task_alt,
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icons[title] ?? Icons.list,
            size: 48,
            color: Colors.grey.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            messages[title] ?? 'No tasks',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Drag and drop tasks here',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
