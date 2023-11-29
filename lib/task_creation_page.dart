//task_creation_page.dart
import 'package:flutter/material.dart';

import 'task/task.dart';

// TODO: Add 'Add Due Date' Button

class TaskCreationPage extends StatefulWidget {
  final Function(Task) onTaskCreated;
  final String parentId; // Add the parentId parameter

  const TaskCreationPage({super.key, 
    required this.onTaskCreated,
    this.parentId = '', // Set the default value
  });

  @override
  _TaskCreationPageState createState() => _TaskCreationPageState();
}

class _TaskCreationPageState extends State<TaskCreationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Task Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Task Description'),
            ),
            ElevatedButton(
              onPressed: () {
                // Create a new task object with the provided details
                final Task newTask = Task(
                  id: UniqueKey().toString(),
                  name: _nameController.text,
                  description: _descriptionController.text,
                  parentId: widget.parentId, // Use the parentId from the widget
                  fields: [],
                );

                // Notify the main page about the newly created task
                widget.onTaskCreated(newTask);

                // Clear the form
                _nameController.clear();
                _descriptionController.clear();
              },
              child: const Text('Create Task'),
            ),
          ],
        ),
      ),
    );
  }
}
