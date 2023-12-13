//task_creation_page.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:glenn/fields/reminder_date_field.dart';

import 'task/task.dart';
import 'fields/due_date_field.dart';
import 'fields/repeating_field.dart';

class TaskCreationPage extends StatefulWidget {
  final Function(Task) onTaskCreated;
  final String parentId;

  const TaskCreationPage({
    super.key,
    required this.onTaskCreated,
    this.parentId = '',
  });

  @override
  _TaskCreationPageState createState() => _TaskCreationPageState();
}

class _TaskCreationPageState extends State<TaskCreationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  bool _isRepeating = false;
  RepeatPeriod _selectedRepeatPeriod = RepeatPeriod.Daily;

  // Method to handle file picking
  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String filePath = result.files.single.path!;
      // Add logic to handle the file path as needed
    }
  }

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
            if (widget.parentId == '')
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
            if (widget.parentId == '')
              CheckboxListTile(
                title: Text('Repeat Task'),
                value: _isRepeating,
                onChanged: (value) {
                  setState(() {
                    _isRepeating = value!;
                    if (_isRepeating) {
                      // If repeating is enabled, set due date to today if it's empty
                      if (_dateController.text.isEmpty) {
                        _dateController.text = formatDate(DateTime.now());
                      }
                      if (_timeController.text.isEmpty) {
                        _timeController.text = formatTime(TimeOfDay.now());
                      }
                      _startDateController.text = formatDate(DateTime.now());
                      _endDateController.text =
                          formatDate(DateTime.now().add(Duration(days: 365)));
                    }
                  });
                },
              ),
            if (_isRepeating && widget.parentId == '')
              _buildRepeatPatternDropdown(),
            ElevatedButton(
              onPressed: _pickFile, // Add file picking button
              child: const Text('Add File'),
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
                    parentId: widget.parentId,
                    fields: [
                      if (!_isRepeating && widget.parentId == '')
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
                      ReminderDateField(hasReminder: true),
                      if (_isRepeating && widget.parentId == '')
                        RepeatingTaskField(
                          repeatPeriod: _selectedRepeatPeriod,
                          startDate: _startDateController.text.isNotEmpty
                              ? DateTime.parse(_startDateController.text)
                              : DateTime.now(),
                          endDate: _endDateController.text.isNotEmpty
                              ? DateTime.parse(_endDateController.text)
                              : DateTime.now(),
                        ),
                    ],
                    filePaths: [],
                  );

                  // Notify the main page about the newly created task
                  widget.onTaskCreated(newTask);

                  // Clear the form
                  _nameController.clear();
                  _descriptionController.clear();
                  _dateController.clear();
                  _timeController.clear();
                  setState(() {
                    _isRepeating = false;
                    _selectedRepeatPeriod = RepeatPeriod.Daily;
                  });

                  Navigator.of(context).pop();
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

  Widget _buildRepeatPatternDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Repeat Pattern'),
        DropdownButton<RepeatPeriod>(
          value: _selectedRepeatPeriod,
          onChanged: (RepeatPeriod? value) {
            if (value != null) {
              setState(() {
                _selectedRepeatPeriod = value;
              });
            }
          },
          items: RepeatPeriod.values
              .map<DropdownMenuItem<RepeatPeriod>>(
                (RepeatPeriod value) => DropdownMenuItem<RepeatPeriod>(
                  value: value,
                  child: Text(value.toString().split('.').last),
                ),
              )
              .toList(),
        ),
        if (_selectedRepeatPeriod !=
            RepeatPeriod.Custom) // Additional check for custom
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Start Date'),
                    _buildStartDateField(),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('End Date'),
                    _buildEndDateField(),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildStartDateField() {
    return TextFormField(
      controller: _startDateController,
      keyboardType: TextInputType.datetime,
      //decoration: InputDecoration(labelText: 'Start Date'),
      onTap: () => _showStartDatePicker(),
    );
  }

  Widget _buildEndDateField() {
    return TextFormField(
      controller: _endDateController,
      keyboardType: TextInputType.datetime,
      //decoration: InputDecoration(labelText: 'End Date'),
      onTap: () => _showEndDatePicker(),
    );
  }

  void _showStartDatePicker() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        _startDateController.text = formatDate(selectedDate);
      });
    }
  }

  void _showEndDatePicker() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default to one year from now
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        _endDateController.text = formatDate(selectedDate);
      });
    }
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
