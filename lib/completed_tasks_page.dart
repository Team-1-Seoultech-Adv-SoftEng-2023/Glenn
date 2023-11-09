import 'package:flutter/material.dart';
import 'main.dart'; // Import the Task class and any other necessary imports from the main.dart file

class CompletedTasksPage extends StatelessWidget {
  final List<Task> tasks;

  CompletedTasksPage({
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    final completedTasks = tasks.where((task) => task.isComplete).toList();

    return Scaffold(
      body: ListView.builder(
        itemCount: completedTasks.length,
        itemBuilder: (context, index) {
          final task = completedTasks[index];
          return TaskCard(task: task);
        },
      ),
    );
  }
}
