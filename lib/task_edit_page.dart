import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'fields/due_date_field.dart';
import 'fields/priority_field.dart';
import 'task_creation_page.dart';
import 'task/task.dart';
import 'package:permission_handler/permission_handler.dart';
import 'task/repeating_task_utils.dart';
import 'main.dart';

import 'widgets/priority_widgets.dart';
import 'widgets/due_date_widgets.dart';
import 'widgets/repeating_tasks_widgets.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;
  final Function(Task) onTaskUpdated;
  final Function(dynamic) onTaskCreated;
  final Function(Task) onTaskDeleted;
  final List<Task> repeatingTasks;

  const EditTaskPage({
    super.key,
    required this.task,
    required this.onTaskUpdated,
    required this.onTaskCreated,
    required this.onTaskDeleted,
    required this.repeatingTasks,
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

  late bool _isRepeating;
  late RepeatPeriod _selectedRepeatPeriod;
  late TextEditingController _repeatIntervalController;
  late TextEditingController _repetitionEndDateController;

  @override
  void initState() {
    super.initState();
    initializeControllersEditTask();

    if (widget.repeatingTasks.isNotEmpty) {
      calculateRepeatingInterval(
        widget.repeatingTasks,
        _repeatIntervalController,
        _selectedRepeatPeriod,
      );
    }
  }

  void initializeControllersEditTask() {
    _nameController = TextEditingController(text: widget.task.name);
    _descriptionController = TextEditingController(text: widget.task.description);
    _dueDateController = TextEditingController(text: formatDate(widget.task.getDueDate()!));
    _dueTimeController = TextEditingController(text: formatTime(widget.task.getDueTime()!));
    _repetitionEndDateController = TextEditingController(text: getEndDateFormatted(widget.repeatingTasks)!);
    _selectedPriority = (widget.task.fields.firstWhere((field) => field is PriorityField,
                orElse: () => PriorityField(priority: 0)) as PriorityField?)?.priority ?? 0; 
                _isRepeating = widget.repeatingTasks.isNotEmpty;
    _selectedRepeatPeriod = RepeatPeriod.days;
    _repeatIntervalController = TextEditingController();
  }

  // Dispose controllers to avoid memory leaks
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    _dueTimeController.dispose();
    _repeatIntervalController.dispose();
    _repetitionEndDateController.dispose();
    super.dispose();
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
                  addSubtask(context);
                } else if (value == 'attach_file') {
                  _attachFile();
                } else if (value == 'delete_task') {
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
        body: SingleChildScrollView(
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

                Visibility(
                  visible: widget.task.parentId == '',
                  child: _buildFields(),
                ),

                ElevatedButton(
                  onPressed: () {
                    // Update the task's attributes when the button is pressed
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
                    }else{
                      
                    setState(() {

                      updateTask();

                      if (_isRepeating && widget.task.repeatingId.isEmpty) {
                        createRepeatingTasks();
                      }

                      if (!_isRepeating && widget.repeatingTasks.isNotEmpty) {
                        
                          for (Task t in widget.repeatingTasks) {
                            if (!t.isComplete && t != widget.task) {
                              widget.onTaskDeleted(t);
                            }
                          }

                        widget.task.repeatingId = '';
                      } 

                      if (_isRepeating && widget.repeatingTasks.isNotEmpty) {
                        
                          for (Task t in widget.repeatingTasks) {
                            if (!t.isComplete && t != widget.task) {
                              widget.onTaskDeleted(t);
                            }
                          }
                        
                          createRepeatingTasks();
                      } 


                    });
                    Navigator.pop(context, widget.task);

                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        );
  }

  void addSubtask(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskCreationPage(
          onTaskCreated: widget.onTaskCreated,
          parentId: widget.task.id,
        ),
      ),
    );
  }

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

  void _deleteTask() {
    if (widget.repeatingTasks.isNotEmpty) {
      for (Task t in widget.repeatingTasks) {
        if (!t.isComplete) {
          widget.onTaskDeleted(t);
        }
      }
    } else {
      widget.onTaskDeleted(widget.task);
    }
    Navigator.pop(context);
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

  void updateTask() {
    widget.task.updateTask(
      name: _nameController.text,
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : '',
      fields: [],
    );

    if (_selectedPriority != 0) {
      PriorityField priorityField = PriorityField(priority: _selectedPriority);
      widget.task.updateTask(fields: [priorityField]);
    }

    if (_dueDateController.text.isNotEmpty) {
      DueDateField dueDateField =
          createDueDateField(_dueDateController, _dueTimeController);
      widget.task.updateTask(fields: [dueDateField]);
    }
  }

  void createRepeatingTasks() {
    final Task newTask = Task.copyWithUniqueID(widget.task);

    final List<Task> newTasks = generateRepeatingTasks(
      originalTask: newTask,
      repetitionEndDateController: _repetitionEndDateController,
      selectedRepeatPeriod: _selectedRepeatPeriod,
      repeatInterval: int.parse(_repeatIntervalController.text),
    );
    for (Task newTask in newTasks) {
      widget.onTaskCreated(newTask);
    }

    widget.onTaskDeleted(widget.task);
  }
}
