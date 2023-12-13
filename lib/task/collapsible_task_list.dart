// collapsible_task_list.dart
import 'package:flutter/material.dart';
import 'task.dart';
import 'task_list.dart';
import 'task_card.dart';

class CollapsibleTaskList extends StatefulWidget {
  final List<Task> tasks;
  final Function(Task) onTaskUpdated;
  final Function(Task) onTaskCreated;
  final Function(Task) onTaskDeleted;
  final Function(Task, bool) updateTaskCompletionStatus;
  final String name;
  final bool expandByDefault; // New parameter

  const CollapsibleTaskList({
    Key? key,
    required this.tasks,
    required this.updateTaskCompletionStatus,
    required this.onTaskUpdated,
    required this.onTaskCreated,
    required this.onTaskDeleted,
    required this.name,
    this.expandByDefault = true, // Set the default value
  }) : super(key: key);

  @override
  CollapsibleTaskListState createState() => CollapsibleTaskListState();
}

class CollapsibleTaskListState extends State<CollapsibleTaskList> {
  late bool isExpanded;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.expandByDefault && widget.tasks.isNotEmpty;
  }

  void toggleExpansion() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  // Function to handle task completion
  void handleTaskCompletion(Task completedTask) {
    setState(() {
      // Remove the completed task from the list
      widget.tasks.removeWhere((task) => task == completedTask);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(widget.name),
      initiallyExpanded: widget.expandByDefault,
      children: [
        Container(
          constraints: BoxConstraints(
            maxHeight: 300,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.tasks.length,
            itemBuilder: (context, index) {
              final task = widget.tasks[index];
              return TaskCard(
                task: task,
                allTasks: widget.tasks,
                onTaskUpdated: widget.onTaskUpdated,
                onTaskCreated: widget.onTaskCreated,
                onTaskDeleted: (deletedTask) {
                  widget.onTaskDeleted(deletedTask);
                  // Handle task completion in CollapsibleTaskList
                  handleTaskCompletion(deletedTask);
                },
                onUpdateDueDateTime: (dueDateField) {
                  print('Due date and time updated: ${dueDateField.value}');
                },
                updateTaskCompletionStatus: widget.updateTaskCompletionStatus,
              );
            },
          ),
        ),
      ],
    );
  }
}