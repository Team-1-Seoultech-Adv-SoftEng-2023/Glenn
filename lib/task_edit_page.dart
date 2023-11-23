import 'package:flutter/material.dart';
import 'main.dart';
import 'task_creation_page.dart';

import 'task/task.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;

  final Function(Task) onTaskUpdated; // Add this callback
  final Function(Task) onTaskCreated; // Add this callback
  final Function(Task) onTaskDeleted; // Add this callback

  const EditTaskPage({super.key, 
    required this.task,
    required this.onTaskUpdated,
    required this.onTaskCreated,
    required this.onTaskDeleted, // Update the constructor
  });

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.task.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Function to handle task deletion
  void _deleteTask() {
    // Call the onTaskDeleted callback to notify the parent widget about the deletion
    widget.onTaskDeleted(widget.task);
    // Navigate back to the previous screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'add_sub_task') {
                // Navigate to the TaskCreationPage and assign the parent ID
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TaskCreationPage(
                      onTaskCreated: widget.onTaskCreated,
                      parentId: widget.task.id,
                    ),
                  ),
                );
              } else if (value == "delete_task") {
                // Call the function to handle task deletion

                _deleteTask();
              }
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'add_sub_task',
                  child: Text('Add Sub-Task'),
                ),
                // You can add more options here if needed
                const PopupMenuItem<String>(
                  value: 'delete_task',
                  child: Text('Delete'),
                )
              ];
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Task Name'),
            ),
            ElevatedButton(
              onPressed: () {
                // Update the task's name when the button is pressed
                setState(() {
                  widget.task.name = _nameController.text;
                });
                // Return the updated task to the previous page
                Navigator.pop(context, widget.task);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
