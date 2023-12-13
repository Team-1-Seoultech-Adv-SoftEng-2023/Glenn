// due_date_list_view.dart
import 'package:flutter/material.dart';
import 'task/task.dart';
import 'category_list_view.dart';

class DueDateListView extends StatefulWidget {
  final Key key;
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
    required this.key,
  });

  @override
  DueDateListViewState createState() => DueDateListViewState();
}

class DueDateListViewState extends State<DueDateListView> {
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

    for (Task task in widget.tasks) {
      if (task.hasDueDate) {
        DateTime dueDate = task.getDueDate()!;
        if (dueDate.isBefore(now.subtract(const Duration(days: 1)))) {
          pastTasks.add(task); // Tasks in the past
        } else if (dueDate.isBefore(now.add(const Duration(days: 0)))) {
          todayTasks.add(task);
        } else if (dueDate.isBefore(now.add(const Duration(days: 7)))) {
          thisWeekTasks.add(task);
        } else if (dueDate.isBefore(now.add(const Duration(days: 30)))) {
          thisMonthTasks.add(task);
        } else {
          laterTasks.add(task);
        }
      } else {
        noDueDateTasks.add(task);
      }
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
      categoryNames: const [
        "Past",
        "Today",
        "This Week",
        "This Month",
        "Later",
        "No Due Date",
      ],
      updateTaskCompletionStatus: widget.updateTaskCompletionStatus,
      onTaskUpdated: widget.onTaskUpdated,
      onTaskCreated: widget.onTaskCreated,
      onTaskDeleted: widget.onTaskDeleted,
      defaultTab: 1, // Set the default tab index (e.g., 1 for "Today")
    );
  }
}
