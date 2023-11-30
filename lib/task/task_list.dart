import 'package:flutter/material.dart';
import 'task.dart';
import 'task_card.dart';

class TaskList extends StatefulWidget {
  final List<Task> tasks;
  final Function(Task) onTaskUpdated; // Add the callback
  final Function(Task) onTaskCreated; // Add the callback
  final Function(Task) onTaskDeleted; // Add the callback
  final Function(Task, bool) updateTaskCompletionStatus;

  const TaskList({
    super.key,
    required this.tasks,
    required this.updateTaskCompletionStatus,
    required this.onTaskUpdated,
    required this.onTaskCreated,
    required this.onTaskDeleted,
  });

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  List<Task> incompleteTasks = [];

  @override
  void initState() {
    super.initState();
    // Filter the initial list of tasks to show only incomplete tasks
    incompleteTasks = widget.tasks.where((task) => !task.isComplete).toList();
  }

  void _updateTaskCompletionStatus(Task task, bool isComplete) {
    setState(() {
      task.isComplete = isComplete;
      // Remove the completed task from the list
      incompleteTasks.removeWhere((element) => element == task);
    });
  }

  void _addTask(Task task) {
    setState(() {
      widget.tasks.add(task);
      if (!task.isComplete) {
        incompleteTasks.add(task);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("TaskList rebuilding");
    final mainTasks =
        incompleteTasks.where((task) => task.parentId == '').toList();
    return ListView.builder(
      itemCount: mainTasks.length,
      itemBuilder: (context, index) {
        final task = mainTasks[index];
        return TaskCard(
          task: task,
          allTasks: widget.tasks,
          onTaskUpdated: widget.onTaskUpdated,
          onTaskCreated: (createdTask) {
            widget.onTaskCreated(createdTask);
            _addTask(createdTask); // Add the new task to the list
          },
          onTaskDeleted: widget.onTaskDeleted,
          onUpdateDueDateTime: (dueDateField) {
            // Handle the update logic here
            print('Due date and time updated: ${dueDateField.value}');
          },
          updateTaskCompletionStatus: _updateTaskCompletionStatus,
        );
      },
    );
  }
}
