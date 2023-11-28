import 'package:flutter/material.dart';
import 'main.dart';

import 'task/task.dart';
import 'fields/due_date_field.dart';

class TaskCreationPage extends StatefulWidget {
  final Function(Task) onTaskCreated;
  final String parentId; // Add the parentId parameter

  const TaskCreationPage({
    super.key,
    required this.onTaskCreated,
    this.parentId = '', // Set the default value
  });

  @override
  _TaskCreationPageState createState() => _TaskCreationPageState();
}

class _TaskCreationPageState extends State<TaskCreationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Task Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Task Description'),
            ),
            ListTile(
              title: Text('Due Date'),
              subtitle: Row(
                children: [
                  Expanded(
                    child: _buildDateField(),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildTimeField(),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Check if the task name is not empty before creating the task
                if (_nameController.text.isNotEmpty) {
                  // Create a new task object with the provided details
                  final Task newTask = Task(
                    id: UniqueKey().toString(),
                    name: _nameController.text,
                    description: _descriptionController.text,
                    parentId:
                        widget.parentId, // Use the parentId from the widget
                    fields: [
                      DueDateField(
                        dueDate: _dateController.text.isNotEmpty
                            ? DateTime.parse(_dateController.text)
                            : DateTime.now(),
                        dueTime: _timeController.text.isNotEmpty
                            ? TimeOfDay(
                                hour: int.parse(
                                    _timeController.text.split(":")[0]),
                                minute: int.parse(
                                    _timeController.text.split(":")[1]),
                              )
                            : TimeOfDay.now(),
                      ),
                    ],
                  );

                  // Notify the main page about the newly created task
                  widget.onTaskCreated(newTask);

                  // Clear the form
                  _nameController.clear();
                  _descriptionController.clear();
                  _dateController.clear();
                  _timeController.clear();
                } else {
                  // Show an error message or handle the case where the task name is empty
                  // Show a SnackBar with the error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Task name cannot be empty. Please enter a task name.'),
                    ),
                  );
                }
              },
              child: const Text('Create Task'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dateController,
      keyboardType: TextInputType.datetime,
      decoration: InputDecoration(labelText: 'Date'),
      onTap: () => _showDatePicker(),
    );
  }

  Widget _buildTimeField() {
    return TextFormField(
      controller: _timeController,
      keyboardType: TextInputType.datetime,
      decoration: InputDecoration(labelText: 'Time'),
      onTap: () => _showTimePicker(),
    );
  }

  void _showDatePicker() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null) {
      setState(() {
        _dateController.text = formatDate(selectedDate);
      });
    }
  }

  void _showTimePicker() async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      setState(() {
        _timeController.text = formatTime(selectedTime);
      });
    }
  }
}
