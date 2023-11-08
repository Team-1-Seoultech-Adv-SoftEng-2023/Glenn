import 'package:flutter/material.dart';
import 'main.dart'; // Import the main.dart file

class TaskDetailPage extends StatefulWidget {
  final Task task;
  final Function(DueDateField) onUpdateDueDateTime;

  TaskDetailPage({required this.task, required this.onUpdateDueDateTime});

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Detail'),
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