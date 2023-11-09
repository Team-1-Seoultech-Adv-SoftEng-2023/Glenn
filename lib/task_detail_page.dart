import 'package:flutter/material.dart';
import 'main.dart'; // Import the main.dart file
import 'task_edit_page.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;
  final List<Task> subtasks; // Add the list of subtasks

  final Function(Task) onTaskUpdated; // Add the callback
  final Function(Task) onTaskCreated; // Add the callback
  final Function(DueDateField) onUpdateDueDateTime;

  TaskDetailPage({
    required this.task,
    required this.subtasks,
    required this.onTaskUpdated,
    required this.onTaskCreated, 
    required this.onUpdateDueDateTime, // Update the constructor
  });

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late TextEditingController dateController;
  late TextEditingController timeController;

  @override
  void initState() {
    super.initState();
    if (widget.task.fields.isNotEmpty && widget.task.fields.first is DueDateField) {
      dateController = TextEditingController(text: _formatDate((widget.task.fields.first as DueDateField).dueDate));
      timeController = TextEditingController(text: _formatTime((widget.task.fields.first as DueDateField).dueTime));
    }
  }

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Detail'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final updatedTask = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditTaskPage(
                      task: widget.task,
                      onTaskUpdated: (updatedTask) {
                        // Handle the updated task here
                        // Optionally, you can update the UI or perform other actions.
                      },
                      onTaskCreated: (newTask) {
                        widget.onTaskCreated(newTask);
                      }),
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
        // You should access the task property using widget.task
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: Text(widget.task.name), // Access task using widget.task
            subtitle:
                Text(widget.task.description), // Access task using widget.task
          ),
          if (widget.task.fields.isNotEmpty)
            Container(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (widget.task.fields.first is DueDateField)
                    ListTile(
                      title: Text('Due Date'),
                      subtitle: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: dateController,
                              keyboardType: TextInputType.datetime,
                              decoration: InputDecoration(labelText: 'Date'),
                              onTap: () async {
                                DateTime? selectedDate = await showDatePicker(
                                  context: context,
                                  initialDate: (widget.task.fields.first as DueDateField).dueDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );
                                if (selectedDate != null) {
                                  setState(() {
                                    (widget.task.fields.first as DueDateField).dueDate = selectedDate;
                                    dateController.text = _formatDate(selectedDate);
                                  });
                                  // Call the callback function with the updated DueDateField
                                  widget.onUpdateDueDateTime(widget.task.fields.first as DueDateField);
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: timeController,
                              keyboardType: TextInputType.datetime,
                              decoration: InputDecoration(labelText: 'Time'),
                              onTap: () async {
                                TimeOfDay? selectedTime = await showTimePicker(
                                  context: context,
                                  initialTime: (widget.task.fields.first as DueDateField).dueTime,
                                );
                                if (selectedTime != null) {
                                  setState(() {
                                    (widget.task.fields.first as DueDateField).dueTime = selectedTime;
                                    timeController.text = _formatTime(selectedTime);
                                  });
                                  // Call the callback function with the updated DueDateField
                                  widget.onUpdateDueDateTime(widget.task.fields.first as DueDateField);
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
                      return Container(); // Skip the DueDateField as it's already displayed separately
                    }
                  }).toList(),
                ],
              ),
            ),
            if (widget.subtasks.isNotEmpty) // Check if there are subtasks
              Column(
                children: <Widget>[
                  Text('Subtasks:'),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.subtasks.length,
                    itemBuilder: (context, index) {
                      final subtask = widget.subtasks[index];
                      return ListTile(
                        title: Text(subtask.name),
                        subtitle: Text(subtask.description),
                        // Add any other subtask details you want to display
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
}