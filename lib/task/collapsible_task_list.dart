// collapsible_task_list.dart
import 'package:flutter/material.dart';
import 'task.dart';
import 'task_list.dart';

class CollapsibleTaskList extends StatefulWidget {
  final List<Task> tasks;
  final Function(Task) onTaskUpdated;
  final Function(Task) onTaskCreated;
  final Function(Task) onTaskDeleted;
  final Function(Task, bool) updateTaskCompletionStatus;
  final String name; // New property to store the category name

  const CollapsibleTaskList({
    Key? key,
    required this.tasks,
    required this.updateTaskCompletionStatus,
    required this.onTaskUpdated,
    required this.onTaskCreated,
    required this.onTaskDeleted,
    required this.name, // Added property
  }) : super(key: key);

  @override
  _CollapsibleTaskListState createState() => _CollapsibleTaskListState();
}

class _CollapsibleTaskListState extends State<CollapsibleTaskList> {
  late bool isExpanded;
  double expandedHeight = 0.0;

  @override
  void initState() {
    super.initState();
    // Check if tasks list is not empty, then expand by default
    isExpanded = widget.tasks.isNotEmpty;
    // Calculate the expanded height based on the number of tasks
    expandedHeight = calculateExpandedHeight(widget.tasks.length);
  }

  double calculateExpandedHeight(int numberOfTasks) {
    // Adjust this value based on your requirements
    const taskHeight = 50.0;
    const spacingHeight = 8.0;
    return numberOfTasks * taskHeight + (numberOfTasks - 1) * spacingHeight;
  }

  void toggleExpansion() {
    setState(() {
      isExpanded = !isExpanded;
      // Recalculate the expanded height when toggling
      expandedHeight = calculateExpandedHeight(widget.tasks.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      elevation: 1,
      expandedHeaderPadding: EdgeInsets.all(0),
      expansionCallback: (int index, bool isExpanded) {
        toggleExpansion();
      },
      children: [
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(widget.name), // Display the category name
            );
          },
          body: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            height: isExpanded ? expandedHeight : 0.0,
            child: TaskList(
              tasks: widget.tasks,
              updateTaskCompletionStatus: widget.updateTaskCompletionStatus,
              onTaskUpdated: widget.onTaskUpdated,
              onTaskCreated: widget.onTaskCreated,
              onTaskDeleted: widget.onTaskDeleted,
            ),
          ),
          isExpanded: isExpanded,
        ),
      ],
    );
  }
}
