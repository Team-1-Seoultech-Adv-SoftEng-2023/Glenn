//expandable_task_list.dart
import 'package:flutter/material.dart';
import 'task.dart';
import 'task_card.dart';
import 'task_list.dart';

class CollapsibleTaskList extends StatefulWidget {
  final List<Task> tasks;
  final Function(Task) onTaskUpdated; // Add the callback
  final Function(Task) onTaskCreated; // Add the callback
  final Function(Task) onTaskDeleted; // Add the callback
  final Function(Task, bool) updateTaskCompletionStatus;

  const CollapsibleTaskList({
    Key? key,
    required this.tasks,
    required this.updateTaskCompletionStatus,
    required this.onTaskUpdated,
    required this.onTaskCreated,
    required this.onTaskDeleted,
  }) : super(key: key);

  @override
  _CollapsibleTaskListState createState() => _CollapsibleTaskListState();
}

class _CollapsibleTaskListState extends State<CollapsibleTaskList> {
  bool isExpanded = false;

  void toggleExpansion() {
    setState(() {
      isExpanded = !isExpanded;
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
              title: Text('Tasks'),
            );
          },
          body: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            height: isExpanded ? 200.0 : 0.0,
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
