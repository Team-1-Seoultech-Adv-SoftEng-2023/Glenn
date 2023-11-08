import 'package:flutter/material.dart';
import 'main.dart';
import 'task_creation_page.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;

  final Function(Task) onTaskUpdated; // Add this callback

  EditTaskPage({required this.task, required this.onTaskUpdated}); // Update the constructor

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'add_sub_task') {
                // Navigate to the TaskCreationPage and assign the parent ID
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TaskCreationPage(
                      onTaskCreated: (newTask) {
                        // Handle the created task here (e.g., adding it to the parent task's sub-tasks)
                        // Optionally, you can also update the UI or perform other actions.
                      },
                      parentId: widget.task.id,
                    ),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'add_sub_task',
                  child: Text('Add Sub-Task'),
                ),
                // You can add more options here if needed
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
              decoration: InputDecoration(labelText: 'Task Name'),
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
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
