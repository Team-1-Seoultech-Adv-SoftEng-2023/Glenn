import 'package:flutter/material.dart';
import 'task_detail_page.dart'; // Import the task_detail_page.dart file
import 'task_creation_page.dart'; // Import the task_creation_page.dart file
import 'completed_tasks_page.dart'; // Import the CompletedTasksPage widget
import 'calendar_view.dart';

// Define the tasks list with sample data
final List<Task> tasks = [
  Task(
    id: '1',
    name: 'Sample Task 1',
    description: 'Description for Sample Task 1',
    parentId: '',
    fields: [
      DueDateField(
        dueDate: DateTime(2023, 11, 15), // Sample date (year, month, day)
        dueTime: TimeOfDay(hour: 14, minute: 30), // Sample time (hour, minute)
      ),
    ],
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
  })  : _dueDate = dueDate,
        _dueTime = dueTime,
        super(
            name: 'Due Date',
            value: '${_formatDate(dueDate)} ${_formatTime(dueTime)}');

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
  runApp(MyApp(tasks: tasks));
}

class MyApp extends StatefulWidget {
  final List<Task> tasks;

  MyApp({required this.tasks});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  List<Task> incompleteTasks = [];

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
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Task List'),
            bottom: TabBar(
              tabs: [
                Tab(text: 'Due Date'),
                Tab(text: 'Priority'),
                Tab(text: 'Calendar'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              TaskList(
                tasks: incompleteTasks,
                updateTaskCompletionStatus: _updateTaskCompletionStatus,
                onTaskUpdated: (updatedTask) {
                  // Handle the updated task here
                  // Optionally, you can update the UI or perform other actions.
                },
                onTaskCreated: handleTaskCreated,
              ),

              TaskList(
                tasks: incompleteTasks,
                updateTaskCompletionStatus: _updateTaskCompletionStatus,
                onTaskUpdated: (updatedTask) {
                  // Handle the updated task here
                  // Optionally, you can update the UI or perform other actions.
                },
                onTaskCreated: handleTaskCreated,
              ),

              CalendarView(tasks: widget.tasks), // Added CalendarView
              CompletedTasksPage(
                tasks: widget.tasks,
                onTaskCreated: handleTaskCreated,
                onTaskUpdated: handleTaskUpdated,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              // Navigate to the TaskCreationPage and pass the callback function
              final newTask = await navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (context) =>
                      TaskCreationPage(onTaskCreated: handleTaskCreated),
                ),
              );
            },
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

class TaskList extends StatefulWidget {
  final List<Task> tasks;
  final Function(Task) onTaskUpdated; // Add the callback
  final Function(Task) onTaskCreated; // Add the callback
  final Function(Task, bool) updateTaskCompletionStatus;

  TaskList({
    required this.tasks,
    required this.updateTaskCompletionStatus,
    required this.onTaskUpdated,
    required this.onTaskCreated,
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
    final mainTasks =
        incompleteTasks.where((task) => task.parentId == '').toList();
    return ListView.builder(
      itemCount: mainTasks.length,
      itemBuilder: (context, index) {
        final task = mainTasks[index];
        return TaskCard(
          task: task,
          allTasks: tasks,
          onTaskUpdated: widget.onTaskUpdated,
          onTaskCreated: widget.onTaskCreated,
          onUpdateDueDateTime: (dueDateField) {
            // Handle the update logic here
            print('Due date and time updated: ${dueDateField.value}');
          },
          updateTaskCompletionStatus: _updateTaskCompletionStatus,
        );
      },
    );
  }
}

class TaskCard extends StatefulWidget {
  final Task task;
  final Function(DueDateField) onUpdateDueDateTime;
  final Function(Task, bool) updateTaskCompletionStatus;

  final List<Task> allTasks;
  final Function(Task) onTaskUpdated; // Add the callback
  final Function(Task) onTaskCreated; // Add the callback

  TaskCard(
      {required this.task,
      required this.allTasks,
      required this.onTaskUpdated,
      required this.onTaskCreated,
      required this.onUpdateDueDateTime,
      this.updateTaskCompletionStatus = _dummyFunction});

  @override
  _TaskCardState createState() => _TaskCardState();
}

void _dummyFunction(Task task, bool isComplete) {
  // This is a placeholder function that does nothing.
}

class _TaskCardState extends State<TaskCard> {
  late TextEditingController dateController;
  late TextEditingController timeController;
  bool canEditDateTime = false;

  @override
  void initState() {
    super.initState();
    if (widget.task.fields.isNotEmpty &&
        widget.task.fields.first is DueDateField) {
      canEditDateTime = false; // Set to false for TaskCard
      dateController = TextEditingController(
          text:
              _formatDate((widget.task.fields.first as DueDateField).dueDate));
      timeController = TextEditingController(
          text:
              _formatTime((widget.task.fields.first as DueDateField).dueTime));
    }
  }

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
    // Function to find child tasks for the current task
    List<Task> getChildTasks() {
      return widget.allTasks
          .where((t) => t.parentId == widget.task.id)
          .toList();
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
            dateController.text =
                _formatDate((widget.task.fields.first as DueDateField).dueDate);
            timeController.text =
                _formatTime((widget.task.fields.first as DueDateField).dueTime);
          });
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
                              enabled:
                                  canEditDateTime, // Disable editing on TaskCard
                              onTap: canEditDateTime
                                  ? () async {
                                      DateTime? selectedDate =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: (widget.task.fields.first
                                                as DueDateField)
                                            .dueDate,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2101),
                                      );
                                      if (selectedDate != null) {
                                        setState(() {
                                          (widget.task.fields.first
                                                  as DueDateField)
                                              .dueDate = selectedDate;
                                          dateController.text =
                                              _formatDate(selectedDate);
                                        });
                                        // Pass the updated DueDateField to the callback function
                                        widget.onUpdateDueDateTime(widget
                                            .task.fields.first as DueDateField);
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
                              enabled:
                                  canEditDateTime, // Disable editing on TaskCard
                              onTap: canEditDateTime
                                  ? () async {
                                      TimeOfDay? selectedTime =
                                          await showTimePicker(
                                        context: context,
                                        initialTime: (widget.task.fields.first
                                                as DueDateField)
                                            .dueTime,
                                      );
                                      if (selectedTime != null) {
                                        setState(() {
                                          (widget.task.fields.first
                                                  as DueDateField)
                                              .dueTime = selectedTime;
                                          timeController.text =
                                              _formatTime(selectedTime);
                                        });
                                        // Pass the updated DueDateField to the callback function
                                        widget.onUpdateDueDateTime(widget
                                            .task.fields.first as DueDateField);
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
                  // children: widget.task.fields.map((field) {
                  //   return ListTile(
                  //     title: Text(field.name),
                  //     subtitle: Text(field.value),
                  //   );
                  // }).toList(),
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
                      return TaskCard(
                          task: getChildTasks()[index],
                          allTasks: widget.allTasks,
                          onTaskUpdated: (updatedTask) {
                            // Handle the updated task here
                            // Optionally, you can update the UI or perform other actions.
                          },
                          onTaskCreated: widget.onTaskCreated,
                          onUpdateDueDateTime: widget.onUpdateDueDateTime);
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

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

String _formatTime(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
