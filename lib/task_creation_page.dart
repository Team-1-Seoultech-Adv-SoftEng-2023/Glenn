//task_creation_page.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:glenn/fields/priority_field.dart';

import 'task/task.dart';
import 'fields/due_date_field.dart';
import 'task/repeating_task_utils.dart';

import 'widgets/priority_widgets.dart';
import 'widgets/due_date_widgets.dart';
import 'widgets/repeating_tasks_widgets.dart';

class TaskCreationPage extends StatefulWidget {
  final Function(Task) onTaskCreated;
  final String parentId;

  const TaskCreationPage({
    super.key,
    required this.onTaskCreated,
    this.parentId = '',
  });

  @override
  TaskCreationPageState createState() => TaskCreationPageState();
}

class TaskCreationPageState extends State<TaskCreationPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _dueDateController;
  late TextEditingController _dueTimeController;
  late int _selectedPriority;

  late bool _isRepeating;
  late RepeatPeriod _selectedRepeatPeriod;
  late TextEditingController _repetitionEndDateController;
  late TextEditingController _repeatIntervalController;

  @override
  void initState() {
    super.initState();
    initializeControllersNewTask();
  }

  void initializeControllersNewTask() {
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _dueDateController = TextEditingController();
    _dueTimeController = TextEditingController();
    _repetitionEndDateController = TextEditingController();
    _selectedPriority = 0;
    _isRepeating = false;
    _selectedRepeatPeriod = RepeatPeriod.days;
    _repeatIntervalController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Task'),
      ),
      body: SingleChildScrollView(
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

            Visibility(
              visible: widget.parentId == '',
              child: _buildFields(),
            ),

            Visibility(
              visible: widget.parentId == '',
              child: ElevatedButton(
                onPressed: _pickFile,
                child: const Text('Add File'),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                // Check if nessesary elements are empty
                // Then Show a snackbar if the task name is empty
                if (_nameController.text.isEmpty) {
                   showSnackBar('The task name cannot be empty. Please enter a task name.');
                } else if (_dueDateController.text.isNotEmpty && !isValidDate(_dueDateController.text)) {
                  showSnackBar('Invalid date. Please enter a valid date in the format yyyy-mm-dd.');
                } else if (_dueTimeController.text.isNotEmpty && !isValidTime(_dueTimeController.text)) {
                  showSnackBar('Invalid time. Please enter a valid time in the format HH:mm.');
                } else if (_dueTimeController.text.isNotEmpty && _dueDateController.text.isEmpty) {
                  showSnackBar('Please pick a due date.');
                } 
                
                 else if (_isRepeating && _repetitionEndDateController.text.isNotEmpty && !isValidDate(_repetitionEndDateController.text)) {
                  showSnackBar('Invalid end date. Please enter a valid end date in the format yyyy-mm-dd.');
                } else if (_isRepeating && _repetitionEndDateController.text.isEmpty) {
                  showSnackBar('Invalid end date. Please enter a valid end date in the format yyyy-mm-dd.');
                } else if (_isRepeating && _repeatIntervalController.text.isEmpty) {
                  showSnackBar('Invalid repeat interval. Please enter a valid interval between 1 and 99.');
                } else {
                  createTask();
                }
              },
              child: const Text('Create Task'),
            ),
          ],
        ),
      ),
    );
  }

  // Method to handle file picking
  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String filePath = result.files.single.path!;
      // Add logic to handle the file path as needed
    }
  }

  void resetForm() {
    _nameController.clear();
    _descriptionController.clear();
    _dueDateController.clear();
    _dueTimeController.clear();
    _repetitionEndDateController.clear();
    _repeatIntervalController.clear();
    setState(() {
      _isRepeating = false;
      _selectedRepeatPeriod = RepeatPeriod.days;
    });
  }

  void createTask() {
    final Task newTask = Task(
      id: UniqueKey().toString(),
      name: _nameController.text,
      description: _descriptionController.text,
      parentId: widget.parentId,
      fields: [],
      filePaths: [],
    );

    if (widget.parentId.isNotEmpty) {
      // Notify the main page about the newly created subtask
      widget.onTaskCreated(newTask);
      if (kDebugMode) {
        print('You created a new subtask!');
      }
    } else {
      // Handle priority field
      if (_selectedPriority != 0) {
        PriorityField priorityField =
            PriorityField(priority: _selectedPriority);
        newTask.updateTask(fields: [priorityField]);
      }

      // Handle due date field
      if (_dueDateController.text.isNotEmpty) {
        DueDateField dueDateField = createDueDateField(
          _dueDateController,
          _dueTimeController,
        );
        newTask.updateTask(fields: [dueDateField]);
      }

      if (!_isRepeating) {
        // Notify the main page about the newly created task
        widget.onTaskCreated(newTask);
      } else {
        // Generate repeating tasks if needed
        List<Task> newTasks = generateRepeatingTasks(
          originalTask: newTask,
          repetitionEndDateController: _repetitionEndDateController,
          selectedRepeatPeriod: _selectedRepeatPeriod,
          repeatInterval: int.parse(_repeatIntervalController.text),
        );

        for (Task repeatedTask in newTasks) {
          widget.onTaskCreated(repeatedTask);
        }
      }
    }

    if (kDebugMode) {
      print('Done on the task creation page... Back to the main task page!');
    }
    Navigator.of(context).pop();
  }

  Widget _buildFields() {
  return Column(
    children: [
      buildDueDateTimeField(context, _dueDateController, _dueTimeController),
      buildPriorityDropdown(_selectedPriority, (value) {
        setState(() => _selectedPriority = value!);
      }),
      buildRepeatTaskField(
        isRepeating: _isRepeating,
        dueDateController: _dueDateController,
        dueTimeController: _dueTimeController,
        repetitionEndDateController: _repetitionEndDateController,
        repeatIntervalController: _repeatIntervalController,
        selectedRepeatPeriod: _selectedRepeatPeriod,
        context: context,
        onRepeatPeriodChanged: (RepeatPeriod? value) {
          setState(() => _selectedRepeatPeriod = value!);
        },
        onRepeatingCheckboxChanged: (bool? value) {
          setState(() => _isRepeating = value!);
        },
      ),
    ],
  );
}

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

}
