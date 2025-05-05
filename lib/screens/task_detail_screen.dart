import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _newSubtaskController;
  late TextEditingController _newCategoryController;

  DateTime? _dueDate;
  int _priority = 0;
  late List<Task> _subtasks;
  late List<String> _categories;
  bool _isRecurring = false;
  String _recurrencePattern = '';
  List<String> _userIds = [];
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description ?? "",
    );
    _newSubtaskController = TextEditingController();
    _newCategoryController = TextEditingController();

    _dueDate = widget.task.dueDate;
    _selectedStatus = widget.task.status;
    _priority = widget.task.priority;
    _subtasks = List.from(widget.task.subtasks);
    _categories = List.from(widget.task.categories);
    _isRecurring = widget.task.isRecurring;
    _recurrencePattern = widget.task.recurrencePattern;
    _userIds = List.from(widget.task.userIds);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _newSubtaskController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskService = Provider.of<TaskService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              taskService.deleteTask(widget.task.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TITLE
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            /// DESCRIPTION
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            /// STATUS
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items:
                  ['To Do', 'In Progress', 'Completed']
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ),
                      )
                      .toList(),
              onChanged:
                  (value) => setState(() {
                    _selectedStatus = value;
                  }),
            ),

            const SizedBox(height: 16),

            /// DUE DATE
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Due Date'),
              subtitle: Text(
                _dueDate != null
                    ? DateFormat.yMMMd().format(_dueDate!)
                    : 'Not set',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now(),
                    firstDate: DateTime(2022),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _dueDate = picked;
                    });
                  }
                },
              ),
            ),

            const Divider(height: 32),

            /// PRIORITY
            const Text(
              "Priority",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Slider(
              value: _priority.toDouble(),
              min: 0,
              max: 5,
              divisions: 5,
              label: _priority.toString(),
              onChanged: (value) {
                setState(() {
                  _priority = value.round();
                });
              },
            ),

            const Divider(height: 32),

            /// SUBTASKS
            const Text(
              "Subtasks",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _subtasks.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(_subtasks[index].title),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _subtasks.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _newSubtaskController,
              decoration: InputDecoration(
                labelText: 'Add Subtask',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    final text = _newSubtaskController.text.trim();
                    if (text.isNotEmpty) {
                      setState(() {
                        _subtasks.add(
                          Task(
                            id: UniqueKey().toString(),
                            title: text,
                            userId: widget.task.userId,
                          ),
                        );
                        _newSubtaskController.clear();
                      });
                    }
                  },
                ),
              ),
            ),

            const Divider(height: 32),

            /// CATEGORIES
            const Text(
              "Categories",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children:
                  _categories
                      .map(
                        (category) => Chip(
                          label: Text(category),
                          onDeleted: () {
                            setState(() {
                              _categories.remove(category);
                            });
                          },
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _newCategoryController,
              decoration: InputDecoration(
                labelText: 'Add Category',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    final category = _newCategoryController.text.trim();
                    if (category.isNotEmpty &&
                        !_categories.contains(category)) {
                      setState(() {
                        _categories.add(category);
                        _newCategoryController.clear();
                      });
                    }
                  },
                ),
              ),
            ),

            const Divider(height: 32),

            /// RECURRING TASK
            CheckboxListTile(
              title: const Text('Recurring Task'),
              value: _isRecurring,
              onChanged: (value) {
                setState(() {
                  _isRecurring = value ?? false;
                });
              },
            ),
            if (_isRecurring)
              DropdownButtonFormField<String>(
                value:
                    _recurrencePattern.isNotEmpty ? _recurrencePattern : null,
                decoration: const InputDecoration(
                  labelText: 'Recurrence Pattern',
                  border: OutlineInputBorder(),
                ),
                items:
                    ['daily', 'weekly', 'monthly']
                        .map(
                          (pattern) => DropdownMenuItem(
                            value: pattern,
                            child: Text(pattern),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _recurrencePattern = value ?? '';
                  });
                },
              ),

            const SizedBox(height: 16),

            /// USER IDS
            TextField(
              controller: TextEditingController(text: _userIds.join(',')),
              decoration: const InputDecoration(
                labelText: 'User IDs (comma-separated)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _userIds = value.split(',').map((e) => e.trim()).toList();
              },
            ),

            const SizedBox(height: 24),

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
                onPressed: () {
                  final updatedTask = Task(
                    id: widget.task.id,
                    userId: widget.task.userId,
                    title: _titleController.text.trim(),
                    description: _descriptionController.text.trim(),
                    status: _selectedStatus ?? 'To Do',
                    dueDate: _dueDate,
                    priority: _priority,
                    subtasks: _subtasks,
                    categories: _categories,
                    isRecurring: _isRecurring,
                    recurrencePattern: _recurrencePattern,
                    userIds: _userIds,
                  );
                  taskService.updateTask(updatedTask);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
