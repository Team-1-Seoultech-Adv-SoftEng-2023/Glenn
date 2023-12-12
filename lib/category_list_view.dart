// category_list_view.dart
import 'package:flutter/material.dart';
import 'task/task.dart';
import 'task/collapsible_task_list.dart';

class CategoryListView extends StatelessWidget {
  final List<List<Task>> taskCategories;
  final List<String> categoryNames;
  final Function(Task, bool) updateTaskCompletionStatus;
  final Function(Task) onTaskUpdated;
  final Function(Task) onTaskCreated;
  final Function(Task) onTaskDeleted;
  final int defaultTab;

  CategoryListView({
    required this.taskCategories,
    required this.categoryNames,
    required this.updateTaskCompletionStatus,
    required this.onTaskUpdated,
    required this.onTaskCreated,
    required this.onTaskDeleted,
    this.defaultTab = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(
          taskCategories.length,
          (index) => _buildTaskCategory(categoryNames[index], taskCategories[index], index == defaultTab),
        ),
      ),
    );
  }

  Widget _buildTaskCategory(String categoryName, List<Task> tasks, bool expandedByDefault) {
    return CollapsibleTaskList(
      tasks: tasks,
      updateTaskCompletionStatus: updateTaskCompletionStatus,
      onTaskUpdated: onTaskUpdated,
      onTaskCreated: onTaskCreated,
      onTaskDeleted: onTaskDeleted,
      name: categoryName,
      expandByDefault: expandedByDefault,
    );
  }
}
