import 'package:flutter/material.dart';
import 'main.dart';
import 'task_creation_page.dart';
import 'fields/due_date_field.dart';
import 'task/task.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;

  final Function(Task) onTaskUpdated; // Add this callback
  final Function(Task) onTaskCreated; // Add this callback
  final Function(Task) onTaskDeleted; // Add this callback

  const EditTaskPage({
    super.key,
    required this.task,
    required this.onTaskUpdated,
    required this.onTaskCreated,
    required this.onTaskDeleted, // Update the constructor
  });

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;

  @override
  void initState() {
    super.initState();
    //_nameController = TextEditingController(text: widget.task.name);
    initializeControllers();
  }

  void initializeControllers() {
    _nameController = TextEditingController(text: widget.task.name);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _dateController = TextEditingController(text: _getDueDateFormatted());
    _timeController = TextEditingController(text: _getDueTimeFormatted());
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _nameController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  // Method to get the formatted due date as a string
  String _getDueDateFormatted() {
    if (widget.task.hasDueDate) {
      return formatDate(widget.task.getDueDate()!);
    } else {
      return '';
    }
  }

  // Method to get the formatted due time as a string
  String _getDueTimeFormatted() {
    if (widget.task.hasDueDate && widget.task.fields.first is DueDateField) {
      return formatTime((widget.task.fields.first as DueDateField).dueTime);
    } else {
      return '';
    }
  }

  // Function to handle task deletion
  void _deleteTask() {
    // Call the onTaskDeleted callback to notify the parent widget about the deletion
    widget.onTaskDeleted(widget.task);
    // Navigate back to the previous screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'add_sub_task') {
                // Navigate to the TaskCreationPage and assign the parent ID
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TaskCreationPage(
                      onTaskCreated: widget.onTaskCreated,
                      parentId: widget.task.id,
                    ),
                  ),
                );
              } else if (value == "delete_task") {
                // Call the function to handle task deletion

                _deleteTask();
              }
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'add_sub_task',
                  child: Text('Add Sub-Task'),
                ),
                // You can add more options here if needed
                const PopupMenuItem<String>(
                  value: 'delete_task',
                  child: Text('Delete'),
                )
              ];
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Text form field for task name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Task Name'),
            ),
            // Text form field for task description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            // Date and Time form fields for due date
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
                // Update the task's name when the button is pressed
                setState(() {
                  widget.task.updateTask(
                    name: _nameController.text,
                    description: _descriptionController.text,
                    fields: [
                      DueDateField(
                        dueDate: DateTime.parse(_dateController.text),
                        dueTime: TimeOfDay(
                          hour: int.parse(_timeController.text.split(":")[0]),
                          minute: int.parse(_timeController.text.split(":")[1]),
                        ),
                      ),
                    ],
                  );
                });
                // Return the updated task to the previous page
                Navigator.pop(context, widget.task);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  // Widget method to build the TextFormField for the date input
  Widget _buildDateField() {
    return TextFormField(
      controller: _dateController,
      keyboardType: TextInputType.datetime,
      decoration: InputDecoration(labelText: 'Date'),
      onTap: () => _showDatePicker(),
    );
  }

  // Widget method to build the TextFormField for the time input
  Widget _buildTimeField() {
    return TextFormField(
      controller: _timeController,
      keyboardType: TextInputType.datetime,
      decoration: InputDecoration(labelText: 'Time'),
      onTap: () => _showTimePicker(),
    );
  }

  // Method to show the date picker dialog and update the due date
  void _showDatePicker() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: widget.task.getDueDate() ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null) {
      _updateDueDate(selectedDate);
    }
  }

  // Method to show the time picker dialog and update the due time
  void _showTimePicker() async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      _updateDueTime(selectedTime);
    }
  }

  void _updateDueDate(DateTime selectedDate) {
    if (widget.task.fields.isNotEmpty &&
        widget.task.fields.first is DueDateField) {
      DueDateField dueDateField = widget.task.fields.first as DueDateField;
      dueDateField.dueDate = selectedDate;
      _dateController.text = formatDate(selectedDate);
    }
  }

  void _updateDueTime(TimeOfDay selectedTime) {
    if (widget.task.fields.isNotEmpty &&
        widget.task.fields.first is DueDateField) {
      DueDateField dueDateField = widget.task.fields.first as DueDateField;
      dueDateField.dueTime = selectedTime;
      _timeController.text = formatTime(selectedTime);
    }
  }
}
