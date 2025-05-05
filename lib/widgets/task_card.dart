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
    final theme = Theme.of(context);

    return Draggable<Task>(
      data: task,
      feedback: Material(
        color: Colors.transparent,
        elevation: 8.0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Opacity(
            opacity: 0.9,
            child: _buildTaskCardContent(context, taskService, theme),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildTaskCardContent(context, taskService, theme),
      ),
      child: _buildTaskCardContent(context, taskService, theme),
    );
  }

  Widget _buildTaskCardContent(
    BuildContext context,
    TaskService taskService,
    ThemeData theme,
  ) {
    // Status color indicators
    final Map<String, Color> statusColors = {
      'To Do': Colors.blue.shade100,
      'In Progress': Colors.amber.shade100,
      'Completed': Colors.green.shade100,
    };

    // Get days left until due date
    String getDueInText() {
      if (task.dueDate == null) return '';

      final daysLeft = task.dueDate!.difference(DateTime.now()).inDays;

      if (daysLeft < 0) {
        return 'Overdue';
      } else if (daysLeft == 0) {
        return 'Due today';
      } else if (daysLeft == 1) {
        return 'Due tomorrow';
      } else {
        return 'Due in $daysLeft days';
      }
    }

    // Configure urgency color
    Color getDueDateColor() {
      if (task.dueDate == null) return Colors.grey;

      final daysLeft = task.dueDate!.difference(DateTime.now()).inDays;

      if (daysLeft < 0) {
        return Colors.red;
      } else if (daysLeft <= 1) {
        return Colors.orange;
      } else if (daysLeft <= 3) {
        return Colors.amber;
      } else {
        return Colors.green;
      }
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: statusColors[task.status] ?? Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.transparent),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [statusColors[task.status] ?? Colors.white, Colors.white],
              stops: const [0.0, 0.3],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status indicator and title bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color:
                      statusColors[task.status]?.withOpacity(0.3) ??
                      Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Priority stars in header
                    if (task.priority > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (int i = 0; i < task.priority; i++)
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                        ],
                      ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description (if exists)
                    if (task.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          task.description,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    // Show subtasks count if there are any
                    if (task.subtasks.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.checklist,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${task.subtasks.length} subtask${task.subtasks.length > 1 ? 's' : ''}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Due date with indicator
                    if (task.dueDate != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.event,
                              size: 16,
                              color: getDueDateColor(),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('EEE, MMM d').format(task.dueDate!),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: getDueDateColor(),
                                fontWeight:
                                    task.dueDate!
                                                .difference(DateTime.now())
                                                .inDays <
                                            2
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${getDueInText()})',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: getDueDateColor(),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Recurring indicator
                    if (task.isRecurring)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.repeat,
                              size: 16,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.recurrencePattern.isNotEmpty
                                  ? task.recurrencePattern
                                  : 'Recurring',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Team members assigned (if any)
                    if (task.userIds.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.people,
                              size: 16,
                              color: Colors.indigo,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${task.userIds.length} member${task.userIds.length > 1 ? 's' : ''}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Categories as chips
                    if (task.categories.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children:
                            task.categories
                                .map(
                                  (category) => Chip(
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    labelPadding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 0,
                                    ),
                                    padding: EdgeInsets.zero,
                                    label: Text(
                                      category,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(fontSize: 10),
                                    ),
                                    backgroundColor:
                                        theme.colorScheme.surfaceVariant,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                )
                                .toList(),
                      ),
                  ],
                ),
              ),

              // Action footer
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Complete button if not completed
                    if (task.status != 'Completed')
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline),
                        tooltip: 'Mark as completed',
                        color: Colors.green,
                        onPressed: () {
                          final updatedTask = task.copyWith(
                            status: 'Completed',
                          );
                          taskService.updateTask(updatedTask);
                          taskService.handleRecurrence(updatedTask);
                        },
                      ),

                    // Status menu
                    PopupMenuButton<String>(
                      tooltip: 'Change status',
                      icon: const Icon(Icons.arrow_drop_down_circle_outlined),
                      onSelected: (value) {
                        if (value != 'Delete') {
                          final updatedTask = task.copyWith(status: value);
                          taskService.updateTask(updatedTask);
                          if (value == "Completed") {
                            taskService.handleRecurrence(updatedTask);
                          }
                        } else {
                          // Show confirmation dialog before deleting
                          showDialog(
                            context: context,
                            builder:
                                (ctx) => AlertDialog(
                                  title: const Text('Delete Task'),
                                  content: const Text(
                                    'Are you sure you want to delete this task?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text('CANCEL'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        taskService.deleteTask(task.id);
                                        Navigator.of(ctx).pop();
                                      },
                                      child: const Text('DELETE'),
                                    ),
                                  ],
                                ),
                          );
                        }
                      },
                      itemBuilder:
                          (context) => [
                            if (task.status != 'To Do')
                              const PopupMenuItem(
                                value: 'To Do',
                                child: Row(
                                  children: [
                                    Icon(Icons.list, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text('Move to To Do'),
                                  ],
                                ),
                              ),
                            if (task.status != 'In Progress')
                              const PopupMenuItem(
                                value: 'In Progress',
                                child: Row(
                                  children: [
                                    Icon(Icons.play_arrow, color: Colors.amber),
                                    SizedBox(width: 8),
                                    Text('Move to In Progress'),
                                  ],
                                ),
                              ),
                            if (task.status != 'Completed')
                              const PopupMenuItem(
                                value: 'Completed',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Move to Completed'),
                                  ],
                                ),
                              ),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                              value: 'Delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete'),
                                ],
                              ),
                            ),
                          ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
