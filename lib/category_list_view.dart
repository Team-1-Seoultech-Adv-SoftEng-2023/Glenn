// category_list_view.dart
import 'package:flutter/material.dart';
import 'package:glenn/task/task_card.dart';
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

  const CategoryListView({
    Key? key,
    required this.taskCategories,
    required this.categoryNames,
    required this.updateTaskCompletionStatus,
    required this.onTaskUpdated,
    required this.onTaskCreated,
    required this.onTaskDeleted,
    this.defaultTab = 0,
  }) : super(key: key);

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

class CollapsibleTaskList extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task, bool) updateTaskCompletionStatus;
  final Function(Task) onTaskUpdated;
  final Function(Task) onTaskCreated;
  final Function(Task) onTaskDeleted;
  final String name;
  final bool expandByDefault;

  CollapsibleTaskList({
    required this.tasks,
    required this.updateTaskCompletionStatus,
    required this.onTaskUpdated,
    required this.onTaskCreated,
    required this.onTaskDeleted,
    required this.name,
    required this.expandByDefault,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(name),
      initiallyExpanded: expandByDefault,
      children: [
        Container(
          constraints: BoxConstraints(
            maxHeight: 300, // Set your default box height or adjust as needed
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskCard(
                task: task,
                allTasks: tasks,
                onTaskUpdated: onTaskUpdated,
                onTaskCreated: (createdTask) {
                  onTaskCreated(createdTask);
                },
                onTaskDeleted: onTaskDeleted,
                onUpdateDueDateTime: (dueDateField) {
                  // Handle the update logic here
                  print('Due date and time updated: ${dueDateField.value}');
                },
                updateTaskCompletionStatus: (task, isComplete) {
                  updateTaskCompletionStatus(task, isComplete);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

