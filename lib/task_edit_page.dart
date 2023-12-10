import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'fields/due_date_field.dart';
import 'fields/priority_field.dart';
import 'task_creation_page.dart';
import 'task/task.dart';
import 'package:permission_handler/permission_handler.dart';
import 'task/repeating_task_utils.dart';
import 'main.dart';

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
    initializeControllers();
    calculateRepeatingInterval();
      
  }

  void initializeControllers() {
    _nameController = TextEditingController(text: widget.task.name);
    _descriptionController = TextEditingController(text: widget.task.description);
    _dueDateController = TextEditingController(text: _getDueDateFormatted());
    _dueTimeController = TextEditingController(text: _getDueTimeFormatted());
    _repetitionEndDateController = TextEditingController(text: _getEndDateFormatted());
    _selectedPriority = getPriority() ?? 0;
    _isRepeating = widget.repeatingTasks.isNotEmpty;
    _selectedRepeatPeriod = RepeatPeriod.days;
    _repeatIntervalController = TextEditingController();
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
    _repeatIntervalController.dispose();
    _repetitionEndDateController.dispose();
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

  String _getEndDateFormatted() {
    if (widget.repeatingTasks.isNotEmpty) {
      Task lastTask = widget.repeatingTasks.lastWhere(
        (task) => !task.isComplete,
        orElse: () => widget.task,
      );
      return formatDate(lastTask.getDueDate()!);
    } else {
      return '';
    }
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
                if (widget.repeatingTasks.isNotEmpty) {
                  for (Task t in widget.repeatingTasks) {
                    if (!t.isComplete) {
                      widget.onTaskDeleted(t);
                    }
                  }
                }else {
                  widget.onTaskDeleted(widget.task);
                }
                 Navigator.pop(context);
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
      child: Padding(
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

            Visibility(
              visible: widget.task.parentId == '',
              child: _buildRepeatTaskField(),
            ),

            ElevatedButton(
                  onPressed: () {
                    // Update the task's attributes when the button is pressed
                    setState(() {

                      widget.task.updateTask(
                          name: _nameController.text,
                          description: _descriptionController.text.isNotEmpty ? _descriptionController.text : '',
                          fields: []
                        );

                      if (_selectedPriority != 0) {   
                        PriorityField priorityField = PriorityField(priority: _selectedPriority);                 
                        widget.task.updateTask(fields: [priorityField]);
                      }

                      // Create a new task object with the provided details
                      if (_dueDateController.text.isNotEmpty) {   
                        DueDateField dueDateField = createDueDateField();                 
                        widget.task.updateTask(fields: [dueDateField]);
                      }


                      if (_isRepeating && widget.task.repeatingId.isEmpty) {
                        
                        final Task newTask = Task(
                          id: UniqueKey().toString(),
                          name: _nameController.text,
                          description: _descriptionController.text,
                          parentId: '',
                          fields: [],
                          filePaths: [],
                        );

                        if (_selectedPriority != 0) {   
                          PriorityField priorityField = PriorityField(priority: _selectedPriority);                 
                          newTask.updateTask(fields: [priorityField]);
                        }

                      // Create a new task object with the provided details
                        if (_dueDateController.text.isNotEmpty) {   
                          DueDateField dueDateField = createDueDateField();                 
                          newTask.updateTask(fields: [dueDateField]);
                        }

                        List<Task> newTasks = generateRepeatingTasks(
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
                      if(!_isRepeating){

                        if (widget.repeatingTasks.isNotEmpty) {
                        for (Task t in widget.repeatingTasks) {
                          if (!t.isComplete && t != widget.task) {
                            widget.onTaskDeleted(t);
                          }
                        }
                       }
                       widget.task.repeatingId = '';
                      } 
                      else{ //_isRepeating = false 
                        Navigator.pop(context, widget.task);
                      }
                    });

                    // Return the updated task to the previous page
                    Navigator.pop(context, widget.task);
                  },
                  child: const Text('Save'),
                ),
          ],
        ),
      ),
    ));
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

Widget _buildRepeatTaskField() {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('Repeat Task'),
          value: _isRepeating,
          onChanged: (value) {
            setState(() {
              _isRepeating = value!;
              if (_isRepeating) {
                // If repeating is enabled, set due date to today if it's empty
                if (_dueDateController.text.isEmpty) {
                  _dueDateController.text = formatDate(DateTime.now());
                }
                if (_dueTimeController.text.isEmpty) {
                  _dueTimeController.text = formatTime(
                    const TimeOfDay(hour: 23, minute: 59),
                  );
                }
                if(_repeatIntervalController.text.isEmpty){
                  _repeatIntervalController.text = '1';
                } 
                if(_repetitionEndDateController.text.isEmpty){
                  _repetitionEndDateController.text = formatDate(DateTime.now());
                } 
              }
            });
          },
        ),
        Visibility(
          visible: _isRepeating,
          child: _buildRepeatPatternDropdown(),
        ),
      ],
    );
}

Widget _buildRepeatPatternDropdown() {
    return Padding(
      padding: const EdgeInsets.all(0.0), // Add padding around the entire Container
      child: Container(
        color: Colors.grey.withOpacity(0.1), // Set a very faded light blue background color
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Add padding around the child Column
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('End Date'),
                  _buildEndDateField(),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 25.0), // Add vertical padding between the two children
                child: _buildRepeatIntervalDropdown(),
              ),
            ],
          ),
        ),
      ),
    );
  }

    Widget _buildEndDateField() {
    return TextFormField(
      controller: _repetitionEndDateController,
      keyboardType: TextInputType.datetime,
      //decoration: InputDecoration(labelText: 'End Date'),
      onTap: () => _showEndDatePicker(),
    );
  }

 Widget _buildRepeatIntervalDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Repeats every...'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    right: 15.0,
                    left: 100.0), // Add some right padding for spacing
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 50, // Set the width of the TextFormField
                      child: TextFormField(
                        controller: _repeatIntervalController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }


void calculateRepeatingInterval() {
  List<DateTime> dueDates = [];
  for (Task task in widget.repeatingTasks) {
    if (task.hasDueDate) {
      DateTime? dueDate = task.getDueDate();
      if (dueDate != null) {
        dueDates.add(dueDate);
      }
    }
  }
  dueDates.sort();
  
  // Calculate the repeating interval
  if (dueDates.length >= 2) {
    // Calculate the customRepeat
    int customRepeat = dueDates[1].difference(dueDates[0]).inDays;

    // Calculate the repeatPeriod
    RepeatPeriod repeatPeriod;
    if (customRepeat % 365 == 0) {
      repeatPeriod = RepeatPeriod.years;
      customRepeat = customRepeat ~/ 365;
    } else if (customRepeat % 30 == 0) {
      repeatPeriod = RepeatPeriod.months;
      customRepeat = customRepeat ~/ 30;
    } else if (customRepeat % 7 == 0) {
      repeatPeriod = RepeatPeriod.weeks;
      customRepeat = customRepeat ~/ 7;
    } else {
      repeatPeriod = RepeatPeriod.days;
    }
    
    // Set the values
    setState(() {
      _selectedRepeatPeriod = repeatPeriod;
      _repeatIntervalController.text = customRepeat.toString();
    });
  }
}

void _showEndDatePicker() async {
  DateTime? dueDate = _dueDateController.text.isNotEmpty
      ? DateTime.parse(_dueDateController.text)
      : null;

  DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: dueDate ?? DateTime(2000),
    lastDate: DateTime(2101),
    selectableDayPredicate: (DateTime day) {
      // Disable dates before the due date
      return dueDate == null || day.isAfter(dueDate);
    },
  );

  if (selectedDate != null) {
    _updateEndDate(selectedDate);
  }
}

void _updateEndDate(DateTime selectedDate) {
  setState(() {
    _repetitionEndDateController.text = formatDate(selectedDate);
  });
}


}