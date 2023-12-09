import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'fields/due_date_field.dart';
import 'fields/priority_field.dart';
import 'task_creation_page.dart';
import 'task/task.dart';
import 'package:permission_handler/permission_handler.dart';


class EditTaskPage extends StatefulWidget {
  final Task task;
  final Function(Task) onTaskUpdated;
  final Function(dynamic) onTaskCreated;
  final Function(Task) onTaskDeleted;

  const EditTaskPage({
    super.key,
    required this.task,
    required this.onTaskUpdated,
    required this.onTaskCreated,
    required this.onTaskDeleted,
  });

  @override
  EditTaskPageState createState() => EditTaskPageState();
}

class EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _dueDateController;
  late TextEditingController _dueTimeController;
  late int _selectedPriority;

  @override
  void initState() {
    super.initState();
    //_nameController = TextEditingController(text: widget.task.name);
    initializeControllers();
  }

  void initializeControllers() {
    _nameController = TextEditingController(text: widget.task.name);
    _descriptionController = TextEditingController(text: widget.task.description);
    _dueDateController = TextEditingController(text: _getDueDateFormatted());
    _dueTimeController = TextEditingController(text: _getDueTimeFormatted());
    _selectedPriority = getPriority() ?? 0;
  }

  int? getPriority() {
  final priorityField = widget.task.fields.firstWhere(
    (field) => field is PriorityField,
    orElse: () => PriorityField(priority: 0), // Default to priority 0 if not found
  ) as PriorityField;


    return priorityField.priority;
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _nameController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    _dueTimeController.dispose();
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
    if (widget.task.hasDueDate) {
      return formatTime(widget.task.getDueTime()!);
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

  // Function to handle file attachment
  void _attachFile() async {
    // Check storage permission before proceeding
    var status = await Permission.storage.status;

    if (status.isDenied) {
      // Here just ask for the permission for the first time
      await Permission.storage.request();

      // Check again and go to app settings if permission is still denied
      if (await Permission.storage.isDenied) {
        await openAppSettings();
        return; // Return to avoid proceeding with file selection
      }
    } else if (status.isPermanentlyDenied) {
      // Open app settings for the user to manually enable permission
      await openAppSettings();
      return; // Return to avoid proceeding with file selection
    }

    // Permission is granted, proceed with file selection
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && mounted) {
      String filePath = result.files.single.path!;
      // Add logic to handle the file path as needed
      // For example, you can update the task's file paths list
      setState(() {
        widget.task.filePaths.add(filePath);
      });
    }
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
              } else if (value == 'attach_file') {
                // Call the function to handle file attachment
                _attachFile();
              } else if (value == 'delete_task') {
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
                const PopupMenuItem<String>(
                  value: 'attach_file',
                  child: Text('Attach File'),
                ),
                const PopupMenuItem<String>(
                  value: 'delete_task',
                  child: Text('Delete'),
                ),
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

            _buildPriorityDropdown(),

            // Date and Time form fields for due date
            ListTile(
              title: const Text('Due Date'),
              subtitle: Row(
                children: [
                  Expanded(
                    child: _buildDateField(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimeField(),
                  ),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: () {
                
                // Update the task's attributes when the button is pressed
                setState(() {
                  widget.task.updateTask(
                    name: _nameController.text,
                    description: _descriptionController.text,
                    fields: [
                        createDueDateField(),
                        if(_selectedPriority != 0) PriorityField(priority: _selectedPriority),
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
      controller: _dueDateController,
      keyboardType: TextInputType.datetime,
      decoration: const InputDecoration(labelText: 'Date'),
      onTap: () => _showDatePicker(),
    );
  }

  // Widget method to build the TextFormField for the time input
  Widget _buildTimeField() {
    return TextFormField(
      controller: _dueTimeController,
      keyboardType: TextInputType.datetime,
      decoration: const InputDecoration(labelText: 'Time'),
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
      _dueDateController.text = formatDate(selectedDate);
    }
  }

  void _updateDueTime(TimeOfDay selectedTime) {
    if (widget.task.fields.isNotEmpty &&
        widget.task.fields.first is DueDateField) {
      DueDateField dueDateField = widget.task.fields.first as DueDateField;
      dueDateField.dueTime = selectedTime;
      _dueTimeController.text = formatTime(selectedTime);
    }
  }
  
  DueDateField createDueDateField() {
    DueDateField dueDateField = DueDateField(dueDateTime: DateTime.parse(_dueDateController.text));
    dueDateField.dueTime = TimeOfDay(
                      hour: int.parse(_dueTimeController.text.split(":")[0]),
                      minute: int.parse(_dueTimeController.text.split(":")[1]),
                      );
    return dueDateField;
  }

  Widget _buildPriorityDropdown() {
  return DropdownButtonFormField<int>(
    value: _selectedPriority,
    items: const [
      DropdownMenuItem<int>(
        value: 0,
        child: Text('None'),
      ),
      DropdownMenuItem<int>(
        value: 1,
        child: Text('Low'),
      ),
      DropdownMenuItem<int>(
        value: 2,
        child: Text('Medium'),
      ),
      DropdownMenuItem<int>(
        value: 3,
        child: Text('High'),
      ),
      DropdownMenuItem<int>(
        value: 4,
        child: Text('Critical'),
      ),
    ],
    onChanged: (value) {
      setState(() {
        _selectedPriority = value!;
      });
    },
    decoration: const InputDecoration(labelText: 'Priority'),
  );
}

}
