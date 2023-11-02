import 'package:flutter/material.dart';
import 'main.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;

  EditTaskPage({required this.task});

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
