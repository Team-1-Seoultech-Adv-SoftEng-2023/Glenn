import 'package:flutter/material.dart';
import 'main.dart'; // Import the main.dart file
import 'task_edit_page.dart';

import 'task/task.dart';

import 'fields/due_date_field.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;
  final List<Task> subtasks; // Add the list of subtasks

  final Function(Task) onTaskUpdated; 
  final Function(Task) onTaskCreated; 
  final Function(Task) onTaskDeleted; 
  final Function(DueDateField) onUpdateDueDateTime;

  const TaskDetailPage({
    super.key,
    required this.task,
    required this.subtasks,
    required this.onTaskUpdated,
    required this.onTaskCreated,
    required this.onTaskDeleted,
    required this.onUpdateDueDateTime, // Update the constructor
  });

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Detail'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updatedTask = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditTaskPage(
                      task: widget.task,
                      onTaskUpdated: (updatedTask) {
                        },
                      onTaskDeleted: (deleteTask) {
                        widget.onTaskDeleted(deleteTask);
                      },
                      onTaskCreated: (newTask) {
                        widget.onTaskCreated(newTask);
                      }),
                ),
              );
              if (updatedTask != null) {
                // Update the task with the updated task received from EditTaskPage
                setState(() {
                  widget.task.name = updatedTask.name;
                  // Update other task properties as needed
                });
              }
            },
          ),
        ],
      ),
      body: Column(
        // You should access the task property using widget.task
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: Text(widget.task.name), // Access task using widget.task
            subtitle:
                Text(widget.task.description), // Access task using widget.task
          ),
          if (widget.task.fields.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ...widget.task.fields.map((field) {
                    if (field is DueDateField) {
                      // Display information for DueDateField
                      return ListTile(
                        title: Text('Due Date'),
                        subtitle: Row(
                          children: [
                            Text('Date: ${formatDate(field.dueDate)}'),
                            const SizedBox(width: 8),
                            Text('Time: ${formatTime(field.dueTime)}'),
                          ],
                        ),
                      );
                    } else if (field is! DueDateField) {
                      return ListTile(
                        title: Text(field.name),
                        subtitle: Text(field.value),
                      );
                    } else {
                      return Container(); // Skip the DueDateField as it's already displayed separately
                    }
                  }).toList(),
                ],
              ),
            ),
          if (widget.subtasks.isNotEmpty) // Check if there are subtasks
            Column(
              children: <Widget>[
                const Text('Subtasks:'),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.subtasks.length,
                  itemBuilder: (context, index) {
                    final subtask = widget.subtasks[index];
                    return ListTile(
                      title: Text(subtask.name),
                      subtitle: Text(subtask.description),
                      // Add any other subtask details you want to display
                    );
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

}
