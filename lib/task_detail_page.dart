import 'package:flutter/material.dart';
import 'main.dart'; // Import the main.dart file

class TaskDetailPage extends StatelessWidget {
  final Task task;

  TaskDetailPage({required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Detail'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: Text(task.name),
            subtitle: Text(task.description),
          ),
          if (task.fields.isNotEmpty)
            Container(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: task.fields.map((field) {
                  return ListTile(
                    title: Text(field.name),
                    subtitle: Text(field.value),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
