import 'package:flutter/material.dart';
import 'main.dart';

class TaskCreationPage extends StatefulWidget {
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Create a new task object with the provided details
                final Task newTask = Task(
                  id: UniqueKey()
                      .toString(), // You can generate a unique ID here
                  name: _nameController.text,
                  description: _descriptionController.text,
                  parentId: '', // Set the parent ID if needed
                  fields: [],
                );

                // You can handle saving the task, e.g., to a list, database, or API.
                // For now, we'll print the task details as an example.
                print('New Task: ${newTask.name}, ${newTask.description}');

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
