import 'package:flutter/material.dart';
import 'main.dart'; // Import the main.dart file
import 'task_edit_page.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;
  final List<Task> subtasks; // Add the list of subtasks

  final Function(Task) onTaskUpdated; // Add the callback
  final Function(Task) onTaskCreated; // Add the callback

  TaskDetailPage({
    required this.task,
    required this.subtasks,
    required this.onTaskUpdated,
    required this.onTaskCreated, // Update the constructor
  });

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Detail'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final updatedTask = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditTaskPage(
                      task: widget.task,
                      onTaskUpdated: (updatedTask) {
                        // Handle the updated task here
                        // Optionally, you can update the UI or perform other actions.
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
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.task.fields.map((field) {
                  return ListTile(
                    title: Text(field.name),
                    subtitle: Text(field.value),
                  );
                }).toList(),
              ),
            ),
            if (widget.subtasks.isNotEmpty) // Check if there are subtasks
              Column(
                children: <Widget>[
                  Text('Subtasks:'),
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
