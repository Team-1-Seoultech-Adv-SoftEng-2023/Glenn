import 'package:flutter/material.dart';
// Import the main.dart file
import 'task_edit_page.dart';
import 'package:file_picker/file_picker.dart';

import 'task/task.dart';

import 'fields/due_date_field.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;
  final List<Task> subtasks; // Add the list of subtasks

  final Function(Task) onTaskUpdated; // Add the callback
  final Function(Task) onTaskCreated; // Add the callback
  final Function(Task) onTaskDeleted; // Add the callback
  final Function(DueDateField) onUpdateDueDateTime;

  const TaskDetailPage({
    super.key,
    required this.task,
    required this.subtasks,
    required this.onTaskUpdated,
    required this.onTaskCreated,
    required this.onTaskDeleted,
    required this.onUpdateDueDateTime, // Update the constructor
  });

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late TextEditingController dateController;
  late TextEditingController timeController;

  List<String> attachedFiles = []; // New list to store attached file paths

  @override
  void initState() {
    super.initState();
    if (widget.task.fields.isNotEmpty &&
        widget.task.fields.first is DueDateField) {
      dateController = TextEditingController(
          text:
              _formatDate((widget.task.fields.first as DueDateField).dueDate));
      timeController = TextEditingController(
          text:
              _formatTime((widget.task.fields.first as DueDateField).dueTime));
    }

    // Populate attachedFiles with initial values from the task
    attachedFiles.addAll(widget.task.filePaths);
  }

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Task Detail'),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () async {
            final updatedTask = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditTaskPage(
                  task: widget.task,
                  onTaskUpdated: (updatedTask) {
                    // Handle the updated task here
                    // Optionally, you can update the UI or perform other actions.
                  },
                  onTaskDeleted: (deleteTask) {
                    widget.onTaskDeleted(deleteTask);
                  },
                  onTaskCreated: (newTask) {
                    widget.onTaskCreated(newTask);
                  },
                ),
              ),
            );
            if (updatedTask != null) {
              // Update the task with the updated task received from EditTaskPage
              setState(() {
                widget.task.name = updatedTask.name;
                // Update other task properties as needed
              });
            }
          },
        ),
      ],
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          title: Text(widget.task.name),
          subtitle: Text(widget.task.description),
        ),
        if (widget.task.fields.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (widget.task.fields.first is DueDateField)
                  ListTile(
                    title: const Text('Due Date'),
                    subtitle: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: dateController,
                            keyboardType: TextInputType.datetime,
                            decoration:
                                const InputDecoration(labelText: 'Date'),
                            onTap: () async {
                              DateTime? selectedDate = await showDatePicker(
                                context: context,
                                initialDate:
                                    (widget.task.fields.first as DueDateField)
                                        .dueDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (selectedDate != null) {
                                setState(() {
                                  (widget.task.fields.first as DueDateField)
                                      .dueDate = selectedDate;
                                  dateController.text =
                                      _formatDate(selectedDate);
                                });
                                // Call the callback function with the updated DueDateField
                                widget.onUpdateDueDateTime(
                                    widget.task.fields.first as DueDateField);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: timeController,
                            keyboardType: TextInputType.datetime,
                            decoration:
                                const InputDecoration(labelText: 'Time'),
                            onTap: () async {
                              TimeOfDay? selectedTime = await showTimePicker(
                                context: context,
                                initialTime:
                                    (widget.task.fields.first as DueDateField)
                                        .dueTime,
                              );
                              if (selectedTime != null) {
                                setState(() {
                                  (widget.task.fields.first as DueDateField)
                                      .dueTime = selectedTime;
                                  timeController.text =
                                      _formatTime(selectedTime);
                                });
                                // Call the callback function with the updated DueDateField
                                widget.onUpdateDueDateTime(
                                    widget.task.fields.first as DueDateField);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ...widget.task.fields.map((field) {
                  if (field is! DueDateField) {
                    return ListTile(
                      title: Text(field.name),
                      subtitle: Text(field.value),
                    );
                  } else {
                    return Container();
                  }
                }).toList(),
              ],
            ),
          ),
        if (widget.subtasks.isNotEmpty)
          Column(
            children: <Widget>[
              const Text('Subtasks:'),
              ListView.builder(
                shrinkWrap: true,
                itemCount: widget.subtasks.length,
                itemBuilder: (context, index) {
                  final subtask = widget.subtasks[index];
                  return ListTile(
                    title: Text(subtask.name),
                    subtitle: Text(subtask.description),
                  );
                },
              ),
            ],
          ),
        if (attachedFiles.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Attached Files:'),
              // List view to display attached files
              ListView.builder(
                shrinkWrap: true,
                itemCount: attachedFiles.length,
                itemBuilder: (context, index) {
                  final filePath = attachedFiles[index];
                  return ListTile(
                    title: InkWell(
                      // Display either "No attached files" or the file name
                      child: Text(filePath.isEmpty
                          ? 'No attached files'
                          : filePath.split('/').last), // Display only the file name
                      onTap: () {
                        // Open the attached file
                        _openFile(filePath);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
      ],
    ),
  );
}



  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

    // Function to open the attached file
  void _openFile(String filePath) async {
    // Implement the logic to open the file based on the file path
    // For example, you can use plugins like url_launcher or open_file to open files
    // You'll need to check the file type and use the appropriate method to open it
    // For simplicity, let's print a message for now
    print('Opening file: $filePath');
  }
  
  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String filePath = result.files.single.path!;
      // Add logic to handle the file path as needed

      // Update the attachedFiles list
      setState(() {
        attachedFiles.add(filePath);
      });
    }
  }
}