//task_creation_page.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'task/task.dart';
import 'fields/due_date_field.dart';
import 'task/repeating_task.dart';
import 'fields/task_field.dart';

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
  
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _dueTimeController = TextEditingController();

  final TextEditingController _endDateController = TextEditingController();
  bool _isRepeating = false;
  RepeatPeriod _selectedRepeatPeriod = RepeatPeriod.days;
  final TextEditingController _repeatIntervalController =TextEditingController();

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
              child: ListTile(
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
            ),
            Visibility(
              visible: widget.parentId == '',
              child: Column(
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
                          if (_dueTimeController.text.isEmpty){
                            _dueTimeController.text = formatTime(TimeOfDay(hour: 23, minute: 59,));
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
              ),
            ),
            ElevatedButton(
              onPressed: _pickFile, // Add file picking button
              child: const Text('Add File'),
            ),
            
            ElevatedButton(
              onPressed: () {
                // Check if the task name is not empty before creating the task
                if (_nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar( content: Text('Task name cannot be empty. Please enter a task name.'),),
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
                  } 
                  else if(widget.parentId == ''){

                    
                    // Create a new task object with the provided details
                      //if (_dueDateController.text.isNotEmpty) {   
                      DueDateField dueDateField = createDueDateField();                 
                      newTask.updateTask(fields: [dueDateField]);
                      //}

                      newTask.printTaskDetails();

                      if(!_isRepeating){
                        widget.onTaskCreated(newTask);

                      } else if (_isRepeating){
                        List<Task> newTasks = generateRepeatingTasks(
                            originalTask: newTask,
                            dueDateController: _dueDateController,
                            endDateController: _endDateController,
                            selectedRepeatPeriod: _selectedRepeatPeriod,
                            repeatIntervalController: _repeatIntervalController,
                        );
                    
                        print(newTasks);

                        for (Task newTask in newTasks) {
                          widget.onTaskCreated(newTask);
                        }
                      }
                  }
                  
                  resetForm();
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

Widget _buildDateFields() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('End Date'),
      _buildEndDateField(),
    ],
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

Widget _buildRepeatPatternDropdown() {
  return Padding(
    padding: EdgeInsets.all(0.0), // Add padding around the entire Container
    child: Container(
      color: Colors.grey.withOpacity(0.1), // Set a very faded light blue background color
      child: Padding(
        padding: EdgeInsets.all(16.0), // Add padding around the child Column
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateFields(),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 25.0), // Add vertical padding between the two children
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
      controller: _endDateController,
      keyboardType: TextInputType.datetime,
      //decoration: InputDecoration(labelText: 'End Date'),
      onTap: () => _showEndDatePicker(),
    );
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
      controller: _dueDateController,
      keyboardType: TextInputType.datetime,
      decoration: const InputDecoration(labelText: 'Date'),
      onTap: () => _showDatePicker(),
    );
  }

  Widget _buildTimeField() {
    return TextFormField(
      controller: _dueTimeController,
      keyboardType: TextInputType.datetime,
      decoration: const InputDecoration(labelText: 'Time'),
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
        _dueDateController.text = formatDate(selectedDate);

        if (_dueTimeController.text.isEmpty) {
        _dueTimeController.text = formatTime(TimeOfDay(hour: 23, minute: 59));
        }

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
        _dueTimeController.text = formatTime(selectedTime).replaceFirstMapped(
          RegExp(r'(\d{2})(\d{2})'),
          (match) => '${match[1]}:${match[2]}',
        );

        if (_dueDateController.text.isEmpty) {
          _dueDateController.text = formatDate(DateTime.now());
        }
      });
    }
  }

  void resetForm() {
    _nameController.clear();
    _descriptionController.clear();
    _dueDateController.clear();
    _dueTimeController.clear();
    _endDateController.clear();
    _repeatIntervalController.clear();
    setState(() {
      _isRepeating = false;
      _selectedRepeatPeriod = RepeatPeriod.days;
    });
}

  DueDateField createDueDateField() {
    List<String> dateParts = _dueDateController.text.split('-');

    int year = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int day = int.parse(dateParts[2]);

    DueDateField dueDateField = DueDateField(dueDateTime:  DateTime(year, month, day, 23, 59));
    if(_dueTimeController.text.isNotEmpty){
      dueDateField.dueTime = TimeOfDay(
                        hour: int.parse(_dueTimeController.text.split(":")[0]),
                        minute: int.parse(_dueTimeController.text.split(":")[1]),
                        );
    }
      
    return dueDateField;
  }


// if (_endDateController.text.isEmpty || DateTime.parse(_endDateController.text).isBefore(DateTime.parse(_dueDateController.text))) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Please chose an end date that is in the future.'),),
//                       );
//                     } 
}
