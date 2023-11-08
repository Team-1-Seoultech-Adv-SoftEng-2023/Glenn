import 'package:flutter/material.dart';
import 'task_detail_page.dart'; // Import the task_detail_page.dart file
import 'completed_tasks_page.dart'; // Import the CompletedTasksPage widget

class Task {
  final String id;
  final String name;
  final String description;
  final String parentId;
  final List<TaskField> fields;
  bool isComplete; // Add this property

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.parentId,
    required this.fields,
    this.isComplete = false, // Initialize as incomplete
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
  // Create tasks with fields
  final task1 = Task(
    id: '1',
    name: 'Task 1',
    description: 'Description for Task 1',
    parentId: '0',
    fields: [
      TaskField(name: 'Field1', value: 'Value1'),
      TaskField(name: 'Field2', value: 'Value2'),
    ],
  );

  final task2 = Task(
    id: '2',
    name: 'Task 2',
    description: 'Description for Task 2',
    parentId: '1',
    fields: [
      TaskField(name: 'Field1', value: 'Value1'),
      TaskField(name: 'Field3', value: 'Value3'),
    ],
  );

  runApp(MyApp(
    tasks: [task1, task2],
  ));
}

class MyApp extends StatefulWidget {
  final List<Task> tasks;

  MyApp({required this.tasks});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Task> incompleteTasks = [];

  @override
  void initState() {
    super.initState();
    // Filter the initial list of tasks to show only incomplete tasks
    incompleteTasks = widget.tasks.where((task) => !task.isComplete).toList();
  }

  void _updateTaskCompletionStatus(Task task, bool isComplete) {
    setState(() {
      task.isComplete = isComplete;
      if (isComplete) {
        incompleteTasks.removeWhere((element) => element == task);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Task List'),
            bottom: TabBar(
              tabs: [
                Tab(text: 'Incomplete'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              TaskList(
                  tasks: incompleteTasks,
                  updateTaskCompletionStatus: _updateTaskCompletionStatus),
              CompletedTasksPage(
                tasks: widget.tasks,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskList extends StatefulWidget {
  final List<Task> tasks;
  final Function(Task, bool) updateTaskCompletionStatus;

  TaskList({
    required this.tasks,
    required this.updateTaskCompletionStatus,
  });

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  List<Task> incompleteTasks = [];

  @override
  void initState() {
    super.initState();
    // Filter the initial list of tasks to show only incomplete tasks
    incompleteTasks = widget.tasks.where((task) => !task.isComplete).toList();
  }

  void _updateTaskCompletionStatus(Task task, bool isComplete) {
    setState(() {
      task.isComplete = isComplete;
      // Remove the completed task from the list
      incompleteTasks.removeWhere((element) => element == task);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: incompleteTasks.length,
      itemBuilder: (context, index) {
        final task = incompleteTasks[index];
        return TaskCard(
            task: task,
            updateTaskCompletionStatus: _updateTaskCompletionStatus);
      },
    );
  }
}

class TaskCard extends StatefulWidget {
  final Task task;
  final Function(Task, bool) updateTaskCompletionStatus;

  TaskCard(
      {required this.task, this.updateTaskCompletionStatus = _dummyFunction});

  @override
  _TaskCardState createState() => _TaskCardState();
}

void _dummyFunction(Task task, bool isComplete) {
  // This is a placeholder function that does nothing.
}

class _TaskCardState extends State<TaskCard> {
  Future<void> _showConfirmationDialog(BuildContext context, bool value) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Task Completion"),
          content: Text("Do you want to mark this task as complete?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Confirm"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                widget.updateTaskCompletionStatus(widget.task, value);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TaskDetailPage(task: widget.task),
            ),
          );
        },
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(widget.task.name),
              subtitle: Text(widget.task.description),
            ),
            if (!widget.task.isComplete)
              CheckboxListTile(
                title: Text("Mark as Complete"),
                value: widget.task.isComplete,
                onChanged: (value) {
                  _showConfirmationDialog(context, value!);
                },
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
          ],
        ),
      ),
    );
  }
}
