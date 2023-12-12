// due_date_list_view.dart
import 'package:flutter/material.dart';
import 'task/task.dart';
import 'category_list_view.dart';

class DueDateListView extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task, bool) updateTaskCompletionStatus;
  final Function(Task) onTaskUpdated;
  final Function(Task) onTaskCreated;
  final Function(Task) onTaskDeleted;

  DueDateListView({
    required this.tasks,
    required this.updateTaskCompletionStatus,
    required this.onTaskUpdated,
    required this.onTaskCreated,
    required this.onTaskDeleted,
  });

  @override
  Widget build(BuildContext context) {
    // Organize tasks into categories
    List<Task> pastTasks = [];
    List<Task> todayTasks = [];
    List<Task> thisWeekTasks = [];
    List<Task> thisMonthTasks = [];
    List<Task> laterTasks = [];
    List<Task> noDueDateTasks = [];

    DateTime now = DateTime.now();

    for (Task task in tasks) {
      // ... (your existing code)
    }

    return CategoryListView(
      taskCategories: [
        pastTasks,
        todayTasks,
        thisWeekTasks,
        thisMonthTasks,
        laterTasks,
        noDueDateTasks,
      ],
      categoryNames: [
        "Past",
        "Today",
        "This Week",
        "This Month",
        "Later",
        "No Due Date",
      ],
      updateTaskCompletionStatus: updateTaskCompletionStatus,
      onTaskUpdated: onTaskUpdated,
      onTaskCreated: onTaskCreated,
      onTaskDeleted: onTaskDeleted,
      defaultTab: 1, // Set the default tab index (e.g., 1 for "Today")
    );
  }
}
