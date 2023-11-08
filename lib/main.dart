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
  // // Create tasks with fields
  // final task1 = Task(
  //   id: '1',
  //   name: 'Task 1',
  //   description: 'Description for Task 1',
  //   parentId: '0',
  //   fields: [
  //     DueDateField(
  //       dueDate: DateTime(2023, 11, 8),
  //       dueTime: TimeOfDay(hour: 12, minute: 0),
  //     ),
  //     TaskField(name: 'Field1', value: 'Value1'),
  //     TaskField(name: 'Field2', value: 'Value2'),
  //   ],
  // );

  // final task2 = Task(
  //   id: '2',
  //   name: 'Task 2',
  //   description: 'Description for Task 2',
  //   parentId: '1',
  //   fields: [
  //     DueDateField(
  //       dueDate: DateTime(2023, 11, 10),
  //       dueTime: TimeOfDay(hour: 15, minute: 30),
  //     ),
  //     TaskField(name: 'Field1', value: 'Value1'),
  //     TaskField(name: 'Field3', value: 'Value3'),
  //   ],
  // );

  // // Display task information
  // print('Task 1:');
  // print('ID: ${task1.id}');
  // print('Name: ${task1.name}');
  // print('Description: ${task1.description}');
  // print('Parent ID: ${task1.parentId}');
  // print('Fields:');
  // for (var field in task1.fields) {
  //   print('${field.name}: ${field.value}');
  // }

  // print('\nTask 2:');
  // print('ID: ${task2.id}');
  // print('Name: ${task2.name}');
  // print('Description: ${task2.description}');
  // print('Parent ID: ${task2.parentId}');
  // print('Fields:');
  // for (var field in task2.fields) {
  //   print('${field.name}: ${field.value}');
  // }
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace this with your list of tasks
    final List<Task> tasks = [
      Task(
        id: '1', 
        name: 'Task 1', 
        description: 'Description for Task 1', 
        parentId: '0', 
        fields: [
          DueDateField(
            dueDate: DateTime(2023, 11, 10),
            dueTime: TimeOfDay(hour: 15, minute: 30),
          ),
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

class TaskCard extends StatefulWidget {
  final Task task;

  TaskCard({required this.task});

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  late TextEditingController dateController;
  late TextEditingController timeController;

  @override
  void initState() {
    super.initState();
    dateController = TextEditingController(
        text: widget.task.fields.isNotEmpty
            ? _formatDate((widget.task.fields.first as DueDateField).dueDate)
            : '');
    timeController = TextEditingController(
        text: widget.task.fields.isNotEmpty
            ? _formatTime((widget.task.fields.first as DueDateField).dueTime)
            : '');
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
                              onTap: () async {
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
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: timeController,
                              keyboardType: TextInputType.datetime,
                              decoration: InputDecoration(labelText: 'Time'),
                              onTap: () async {
                                TimeOfDay? selectedTime = await showTimePicker(
                                  context: context,
                                  initialTime: (widget.task.fields.first as DueDateField).dueTime,
                                );
                                if (selectedTime != null) {
                                  setState(() {
                                    (widget.task.fields.first as DueDateField).dueTime = selectedTime;
                                    timeController.text = _formatTime(selectedTime);
                                  });
                                }
                              },
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