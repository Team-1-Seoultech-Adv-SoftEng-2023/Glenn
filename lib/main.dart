import 'package:flutter/material.dart';
import 'task_detail_page.dart'; // Import the task_detail_page.dart file



class Task {
  final String id;
  final String name;
  final String description;
  final String parentId;
  final List<TaskField> fields;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.parentId,
    required this.fields,
  });
}

class TaskField {
  final String name;
  final String value;

  TaskField({
    required this.name,
    required this.value,
  });
}

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace this with your list of tasks
    final List<Task> tasks = [
      Task(id: '1', name: 'Task 1', description: 'Description for Task 1', parentId: '0', fields: [
        TaskField(name: 'Field1', value: 'Value1'),
        TaskField(name: 'Field3', value: 'Value3'),
      ]),
      Task(id: '2', name: 'Task 2', description: 'Description for Task 2', parentId: '1', fields: []),
    ];

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Task List'),
        ),
        body: TaskList(tasks: tasks),
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  final List<Task> tasks;

  TaskList({required this.tasks});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(task: task);
      },
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;

  TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TaskDetailPage(task: task),
            ),
          );
        },
        child: Column(
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
      ),
    );
  }
}



