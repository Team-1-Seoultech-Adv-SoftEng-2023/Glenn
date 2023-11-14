import 'package:flutter/material.dart';
import 'main.dart'; // Import the Task class and any other necessary imports from the main.dart file

class CompletedTasksPage extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task) onTaskUpdated; // Add the callback
  final Function(Task) onTaskCreated; // Add the callback

  CompletedTasksPage({
    required this.tasks,
    required this.onTaskCreated,
    required this.onTaskUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final completedTasks = tasks.where((task) => task.isComplete).toList();

    return Scaffold(
      body: ListView.builder(
        itemCount: completedTasks.length,
        itemBuilder: (context, index) {
          final task = completedTasks[index];
          return TaskCard(
            task: task,
            allTasks: tasks,
            onTaskUpdated: onTaskUpdated,
            onTaskCreated: onTaskCreated,
            onUpdateDueDateTime: (dueDateField) {
              // Handle the update logic here
              print('Due date and time updated: ${dueDateField.value}');
            },
          );
        },
      ),
    );
  }
}