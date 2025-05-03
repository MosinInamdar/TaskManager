import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/task_service.dart';

void main() {
  runApp(const TaskPlannerApp());
}

class TaskPlannerApp extends StatelessWidget {
  const TaskPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Task Planner',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.indigo,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
