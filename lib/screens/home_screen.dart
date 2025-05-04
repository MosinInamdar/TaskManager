import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import '../widgets/column_board.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskService = Provider.of<TaskService>(context);

    return _HomeScreenContent(taskService: taskService);
  }
}

class _HomeScreenContent extends StatefulWidget {
  final TaskService taskService;
  const _HomeScreenContent({required this.taskService});

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  String searchQuery = "";
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _taskTitleController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  List<Task> _filterTasksByStatus(String status) {
    List<Task> filteredTasks = widget.taskService.tasks
        .where((task) => task.status == status)
        .toList();

    if (searchQuery.isNotEmpty) {
      filteredTasks = widget.taskService
          .searchTasks(searchQuery)
          .where((task) => task.status == status)
          .toList();
    }

    return filteredTasks;
  }
  
  void updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final statusFilter = [
      {"status": "To Do", "filteredTask": _filterTasksByStatus("To Do")},
      {"status": "In Progress", "filteredTask": _filterTasksByStatus("In Progress")},
      {"status": "Completed", "filteredTask": _filterTasksByStatus("Completed")},
    ];

    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ColumnBoard(
                title: 'To Do',
                tasks: statusFilter[0]["filteredTask"] as List<Task>,
                onTaskUpdated: updateState,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ColumnBoard(
                title: 'In Progress',
                tasks: statusFilter[1]["filteredTask"] as List<Task>,
                onTaskUpdated: updateState,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ColumnBoard(
                title: 'Completed',
                tasks: statusFilter[2]["filteredTask"] as List<Task>,
                onTaskUpdated: updateState,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: !isSearching
          ? const Text('Task Planner')
          : TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search tasks...',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
            ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            final authService = Provider.of<AuthService>(context, listen: false);
            authService.logout();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              if (isSearching) {
                searchQuery = "";
                _searchController.clear();
              }
              isSearching = !isSearching;
            });
          },
        ),
      ],
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    _taskTitleController.clear();
    _categoryController.clear();
    List<String> categories = [];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _taskTitleController,
              decoration: const InputDecoration(hintText: 'Enter task title'),
            ),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: "Categories (comma-separated)"),
              onChanged: (value) {
                categories = value.split(',').map((e) => e.trim()).toList();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = _taskTitleController.text.trim();
              if (title.isNotEmpty) {
                widget.taskService.addTask(title: title, categories: categories);
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