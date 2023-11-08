import 'package:flutter/material.dart';
import 'task_detail_page.dart'; // Import the task_detail_page.dart file
import 'task_creation_page.dart'; // Import the task_creation_page.dart file

// Define the tasks list with sample data
final List<Task> tasks = [
  Task(
    id: '1',
    name: 'Sample Task 1',
    description: 'Description for Sample Task 1',
    parentId: '',
    fields: [],
  ),
  Task(
    id: '2',
    name: 'Sample Task 2',
    description: 'Description for Sample Task 2',
    parentId: '',
    fields: [],
  ),
];


class Task {
  final String id;
  String name;
  String description;
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

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final List<Task> tasks = []; // List to store tasks

  // Callback function to handle newly created tasks
  void handleTaskCreated(Task newTask) {
    setState(() {
      tasks.add(newTask);
    });
  }

  // Define the callback function to handle task updates
  void handleTaskUpdated(Task updatedTask) {
    setState(() {
      // Update the task in the tasks list
      final index = tasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        tasks[index] = updatedTask;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Task List'),
        ),
        body: TaskList(tasks: tasks,
            onTaskUpdated: (updatedTask) {
              // Handle the updated task here
              // Optionally, you can update the UI or perform other actions.
            },
            onTaskCreated: handleTaskCreated,
          ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // Navigate to the TaskCreationPage and pass the callback function
            final newTask = await navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => TaskCreationPage(onTaskCreated: handleTaskCreated),
              ),
            );
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}



class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task) onTaskUpdated; // Add the callback
  final Function(Task) onTaskCreated; // Add the callback

  TaskList({required this.tasks, required this.onTaskUpdated, required this.onTaskCreated}); // Update the constructor

  @override
  Widget build(BuildContext context) {
    final mainTasks = tasks.where((task) => task.parentId == '').toList();
    return ListView.builder(
      itemCount: mainTasks.length,
      itemBuilder: (context, index) {
        final task = mainTasks[index];
        return TaskCard(
          task: task,
          allTasks: tasks,
          onTaskUpdated: onTaskUpdated,
          onTaskCreated: onTaskCreated,
        );
      },
    );
  }
}



class TaskCard extends StatelessWidget {
  final Task task;

  final List<Task> allTasks;
  final Function(Task) onTaskUpdated; // Add the callback
  final Function(Task) onTaskCreated; // Add the callback

  TaskCard({required this.task, required this.allTasks, required this.onTaskUpdated, required this.onTaskCreated});


  @override
  Widget build(BuildContext context) {
    // Function to find child tasks for the current task
    List<Task> getChildTasks() {
      return allTasks.where((t) => t.parentId == task.id).toList();
    }
    return Card(
      margin: EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TaskDetailPage(
                task: task,
                onTaskUpdated: (updatedTask) {
                  // Handle the updated task here
                  // Optionally, you can update the UI or perform other actions.
                },
                  onTaskCreated: onTaskCreated, // Pass the callback
                  subtasks: getChildTasks(),
              ),
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
            // Display child tasks under the main task
            if (getChildTasks().isNotEmpty)
              Column(
                children: <Widget>[
                  Text('Sub Tasks:'),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: getChildTasks().length,
                    itemBuilder: (context, index) {
                      return TaskCard(task: getChildTasks()[index], allTasks: allTasks,
                      onTaskUpdated: (updatedTask) {
                        // Handle the updated task here
                        // Optionally, you can update the UI or perform other actions.
                      },
                      onTaskCreated: onTaskCreated,
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}


