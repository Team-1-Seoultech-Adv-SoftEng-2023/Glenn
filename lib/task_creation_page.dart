import 'package:flutter/material.dart';
import 'main.dart';

class TaskCreationPage extends StatefulWidget {
  final Function(Task) onTaskCreated;
  final String parentId; // Add the parentId parameter
  
  TaskCreationPage({
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
        title: Text('Create New Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Task Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Task Description'),
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
              child: Text('Create Task'),
            ),
          ],
        ),
      ),
    );
  }
}
