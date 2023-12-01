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
  final String name;

  const CollapsibleTaskList({
    Key? key,
    required this.tasks,
    required this.updateTaskCompletionStatus,
    required this.onTaskUpdated,
    required this.onTaskCreated,
    required this.onTaskDeleted,
    required this.name,
  }) : super(key: key);

  @override
  _CollapsibleTaskListState createState() => _CollapsibleTaskListState();
}

class _CollapsibleTaskListState extends State<CollapsibleTaskList> {
  late bool isExpanded;

  @override
  void initState() {
    super.initState();
    // Check if tasks list is not empty, then expand by default
    isExpanded = widget.tasks.isNotEmpty;
  }

  void toggleExpansion() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      elevation: 1,
      expandedHeaderPadding: const EdgeInsets.all(0),
      expansionCallback: (int index, bool isExpanded) {
        toggleExpansion();
      },
      children: [
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(widget.name),
            );
          },
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: isExpanded ? 300.0 : 0.0,
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
