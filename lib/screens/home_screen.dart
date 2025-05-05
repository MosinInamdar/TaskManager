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
    List<Task> filteredTasks =
        widget.taskService.tasks
            .where((task) => task.status == status)
            .toList();

    if (searchQuery.isNotEmpty) {
      filteredTasks =
          widget.taskService
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
      {
        "status": "In Progress",
        "filteredTask": _filterTasksByStatus("In Progress"),
      },
      {
        "status": "Completed",
        "filteredTask": _filterTasksByStatus("Completed"),
      },
    ];

    return Scaffold(
      appBar: _buildCustomAppBar(context),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 30, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // --- Title Section ---
            Row(
              children: const [
                Icon(Icons.dashboard_rounded, color: Colors.indigo, size: 28),
                SizedBox(width: 8),
                Text(
                  'Task Planner',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            // --- Search and Logout Section ---
            Row(
              children: [
                // Search Bar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isSearching ? 220 : 0,
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: isSearching,
                          decoration: const InputDecoration(
                            hintText: 'Search tasks...',
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onChanged: (value) {
                            setState(() => searchQuery = value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Toggle Search
                IconButton(
                  icon: Icon(
                    isSearching ? Icons.close : Icons.search,
                    color: Colors.indigo,
                  ),
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

                const SizedBox(width: 8),

                // Logout
                ElevatedButton.icon(
                  onPressed: () {
                    authService.logout();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text("Logout"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    _taskTitleController.clear();
    _categoryController.clear();
    List<String> categories = [];

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Add New Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _taskTitleController,
                  decoration: const InputDecoration(
                    hintText: 'Enter task title',
                  ),
                ),
                TextField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: "Categories (comma-separated)",
                  ),
                  onChanged: (value) {
                    categories = value.split(',').map((e) => e.trim()).toList();
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  final title = _taskTitleController.text.trim();
                  if (title.isNotEmpty) {
                    widget.taskService.addTask(
                      title: title,
                      categories: categories,
                    );
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
