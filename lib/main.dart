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
  String value;

  TaskField({
    required this.name,
    required this.value,
  });
}

class DueDateField extends TaskField {
  DateTime _dueDate;
  TimeOfDay _dueTime;

  DueDateField({
    required DateTime dueDate,
    required TimeOfDay dueTime,
  })   : _dueDate = dueDate,
        _dueTime = dueTime,
        super(name: 'Due Date', value: '${_formatDate(dueDate)} ${_formatTime(dueTime)}');

  DateTime get dueDate => _dueDate;
  set dueDate(DateTime value) {
    _dueDate = value;
    updateValue();
  }

  TimeOfDay get dueTime => _dueTime;
  set dueTime(TimeOfDay value) {
    _dueTime = value;
    updateValue();
  }

  void updateValue() {
    super.value = '${_formatDate(_dueDate)} ${_formatTime(_dueTime)}';
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}


void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


  // Callback function to handle newly created tasks
  void handleTaskCreated(Task newTask) {
    setState(() {
      tasks.add(newTask); // Add the newly created task to the global tasks list
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
        body: TaskList(
          tasks: tasks,
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
          onUpdateDueDateTime: (dueDateField) {
            // Handle the update logic here
            print('Due date and time updated: ${dueDateField.value}');
          },
        );
      },
    );
  }
}


class TaskCard extends StatefulWidget {
  final Task task;
  final Function(DueDateField) onUpdateDueDateTime;

  final List<Task> allTasks;
  final Function(Task) onTaskUpdated; // Add the callback
  final Function(Task) onTaskCreated; // Add the callback

  TaskCard({required this.task, required this.allTasks, required this.onTaskUpdated, required this.onTaskCreated, required this.onUpdateDueDateTime});

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  late TextEditingController dateController;
  late TextEditingController timeController;
  bool canEditDateTime = false;

  @override
  void initState() {
    super.initState();
    if (widget.task.fields.isNotEmpty && widget.task.fields.first is DueDateField) {
      canEditDateTime = false; // Set to false for TaskCard
      dateController = TextEditingController(text: _formatDate((widget.task.fields.first as DueDateField).dueDate));
      timeController = TextEditingController(text: _formatTime((widget.task.fields.first as DueDateField).dueTime));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Function to find child tasks for the current task
    List<Task> getChildTasks() {
      return widget.allTasks.where((t) => t.parentId == widget.task.id).toList();
    }
    return Card(
      margin: EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () async {
          // Pass the callback function to TaskDetailPage
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TaskDetailPage(
                task: widget.task,
                onTaskUpdated: (updatedTask) {
                  // Handle the updated task here
                  // Optionally, you can update the UI or perform other actions.
                },
                  onTaskCreated: widget.onTaskCreated, // Pass the callback
                  subtasks: getChildTasks(),
                  onUpdateDueDateTime: widget.onUpdateDueDateTime,
              ),
            ),
          );
          setState(() {
            // Update the date and time on TaskCard when returning from TaskDetailPage
            dateController.text = _formatDate((widget.task.fields.first as DueDateField).dueDate);
            timeController.text = _formatTime((widget.task.fields.first as DueDateField).dueTime);
          });
        },
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(widget.task.name),
              subtitle: Text(widget.task.description),
            ),
            if (widget.task.fields.isNotEmpty)
              Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ListTile(
                      title: Text('Due Date'),
                      subtitle: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: dateController,
                              keyboardType: TextInputType.datetime,
                              decoration: InputDecoration(labelText: 'Date'),
                              enabled: canEditDateTime, // Disable editing on TaskCard
                              onTap: canEditDateTime
                                  ? () async {
                                      DateTime? selectedDate = await showDatePicker(
                                        context: context,
                                        initialDate: (widget.task.fields.first as DueDateField).dueDate,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2101),
                                      );
                                      if (selectedDate != null) {
                                        setState(() {
                                          (widget.task.fields.first as DueDateField).dueDate = selectedDate;
                                          dateController.text = _formatDate(selectedDate);
                                        });
                                        // Pass the updated DueDateField to the callback function
                                        widget.onUpdateDueDateTime(widget.task.fields.first as DueDateField);
                                      }
                                    }
                                  : null,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: timeController,
                              keyboardType: TextInputType.datetime,
                              decoration: InputDecoration(labelText: 'Time'),
                              enabled: canEditDateTime, // Disable editing on TaskCard
                              onTap: canEditDateTime
                                  ? () async {
                                      TimeOfDay? selectedTime = await showTimePicker(
                                        context: context,
                                        initialTime: (widget.task.fields.first as DueDateField).dueTime,
                                      );
                                      if (selectedTime != null) {
                                        setState(() {
                                          (widget.task.fields.first as DueDateField).dueTime = selectedTime;
                                          timeController.text = _formatTime(selectedTime);
                                        });
                                        // Pass the updated DueDateField to the callback function
                                        widget.onUpdateDueDateTime(widget.task.fields.first as DueDateField);
                                      }
                                    }
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      title: Text('Field1'),
                      subtitle: Text('Value1'),
                    ),
                    ListTile(
                      title: Text('Field3'),
                      subtitle: Text('Value3'),
                    ),
                  ],
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
                      return TaskCard(task: getChildTasks()[index], allTasks: widget.allTasks,
                      onTaskUpdated: (updatedTask) {
                        // Handle the updated task here
                        // Optionally, you can update the UI or perform other actions.
                      },
                      onTaskCreated: widget.onTaskCreated,
                      onUpdateDueDateTime: widget.onUpdateDueDateTime
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
