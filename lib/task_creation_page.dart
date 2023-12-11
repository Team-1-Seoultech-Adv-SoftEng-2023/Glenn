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
              child: Column(
                children: [
                  buildDueDateTimeField(context, _dueDateController, _dueTimeController),
                  buildPriorityDropdown(_selectedPriority, (value) {setState(() {_selectedPriority = value!;});}),
                  buildRepeatTaskField(
                            isRepeating: _isRepeating,
                            dueDateController: _dueDateController,
                            dueTimeController: _dueTimeController,
                            repetitionEndDateController: _repetitionEndDateController,
                            repeatIntervalController: _repeatIntervalController,
                            selectedRepeatPeriod: _selectedRepeatPeriod,
                            showEndDatePicker: _showEndDatePicker,
                            onRepeatPeriodChanged: (RepeatPeriod? value) {if (value != null){setState((){_selectedRepeatPeriod = value;});}},
                            onRepeatingCheckboxChanged: (bool? value) {setState(() => _isRepeating = value!);},),],
              ),
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
                // Check if the task name is not empty before creating the task
                if (_nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar( content: Text('Task name cannot be empty. Please enter a task name.'),),
                    );
                } else{
                  final Task newTask = Task(
                    id: UniqueKey().toString(),
                    name: _nameController.text,
                    description: _descriptionController.text,
                    parentId: widget.parentId,
                    fields: [],
                    filePaths: [],
                  );

                  if(widget.parentId != ''){
                      // Notify the main page about the newly created task
                      widget.onTaskCreated(newTask);
                      if (kDebugMode) {
                        print('You created a new subtask!');
                      }
                  } 
                  else if(widget.parentId == ''){

                    if (_selectedPriority != 0) {   
                      PriorityField priorityField = PriorityField(priority: _selectedPriority);                 
                      newTask.updateTask(fields: [priorityField]);
                    }

                    // Create a new task object with the provided details
                    if (_dueDateController.text.isNotEmpty) {   
                      DueDateField dueDateField = DueDateField.createDueDateField(
                          _dueDateController, _dueTimeController);
                                      
                      newTask.updateTask(fields: [dueDateField]);
                    }

                    if(!_isRepeating){
                        widget.onTaskCreated(newTask);

                    } else if (_isRepeating){
                        List<Task> newTasks = generateRepeatingTasks(
                            originalTask: newTask,
                            repetitionEndDateController: _repetitionEndDateController,
                            selectedRepeatPeriod: _selectedRepeatPeriod,
                            repeatInterval: int.parse(_repeatIntervalController.text),
                        );

                        for (Task newTask in newTasks) {
                           widget.onTaskCreated(newTask);
                         }
                      }
                  }
                  
                  if (kDebugMode) {
                    print('Done on the task creation page... Back to the main task page!');
                  }
                  Navigator.of(context).pop();  
                } 
              },
              child: const Text('Create Task'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEndDatePicker() async {
    await showEndDatePicker(context, _dueDateController, _repetitionEndDateController);
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
}
