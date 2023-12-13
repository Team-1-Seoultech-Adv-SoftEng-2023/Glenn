//due_date_field.dart
import 'package:flutter/material.dart';
import 'package:glenn/task/task.dart';
import 'task_field.dart';

class DueDateField extends TaskField {
  DateTime _dueDateTime;

  DueDateField({
    required dueDateTime,
  })  : _dueDateTime = dueDateTime,
        super(
            name: 'Due Date',
            value:
                '${formatDate(dueDateTime)} ${formatTime(extractTimeOfDay(dueDateTime))}');

  DateTime get dueDateTime => _dueDateTime;

  set dueDateTime(DateTime value) {
    _dueDateTime = value;
    updateValue();
  }

  // Getter for date
  DateTime get dueDate =>
      DateTime(_dueDateTime.year, _dueDateTime.month, _dueDateTime.day);

  // Setter for date
  set dueDate(DateTime value) {
    _dueDateTime = DateTime(value.year, value.month, value.day,
        _dueDateTime.hour, _dueDateTime.minute);
    updateValue();
  }

  // Getter for time
  TimeOfDay get dueTime => extractTimeOfDay(_dueDateTime);

  // Setter for time
  set dueTime(TimeOfDay value) {
    _dueDateTime = DateTime(_dueDateTime.year, _dueDateTime.month,
        _dueDateTime.day, value.hour, value.minute);
    updateValue();
  }

  void updateValue() {
    super.value =
        '${formatDate(_dueDateTime)} ${formatTime(extractTimeOfDay(_dueDateTime))}';
  }
}

String formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

String formatTime(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

TimeOfDay extractTimeOfDay(DateTime dateTime) {
  return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
}

List<Task> sortTasksByDueDate(List<Task> tasks) {
  // Filter out tasks with empty or null due dates
  List<Task> tasksWithDueDate = tasks.where((task) => task.getDueDate() != null).toList();

  // Sort tasks by due date
  tasksWithDueDate.sort((a, b) {
    if (a.getDueDate() != null && b.getDueDate() != null) {
      // Compare TimeOfDay instances by converting them to minutes since midnight
      final int aMinutes = a.getDueDate()!.hour * 60 + a.getDueDate()!.minute;
      final int bMinutes = b.getDueDate()!.hour * 60 + b.getDueDate()!.minute;
      return aMinutes.compareTo(bMinutes);
    } else {
      return 0;
    }
  });

  // Combine tasks with due dates and tasks without due dates
  List<Task> sortedTasks = [...tasksWithDueDate, ...tasks.where((task) => task.getDueDate() == null).toList()];

  return sortedTasks;
}

DueDateField createDueDateField(
      TextEditingController dueDateController,
      TextEditingController dueTimeController) {
    
    DateTime dueDate = formatDateController(dueDateController.text);

    DueDateField dueDateField = DueDateField(dueDateTime: dueDate);
    dueDateField.dueTime = formatTimeController(dueTimeController.text);

    return dueDateField;
  }

  DateTime formatDateController (String dateText){

    DateTime date = DateTime.now();
    if (dateText.isNotEmpty){
      List<String> dateParts = dateText.split('-');
      int year = int.parse(dateParts[0]);
      int month = int.parse(dateParts[1]);
      int day = int.parse(dateParts[2]);

      date = DateTime(year, month, day, 23, 59);
    }

    return date;
  }

  TimeOfDay formatTimeController (String timeText){

    TimeOfDay time = const TimeOfDay(hour: 23, minute: 59);
    if (timeText.isNotEmpty) {
      List<int> timeParts = timeText.split(":").map((part) => int.tryParse(part) ?? 0).toList();
      time = TimeOfDay(hour: timeParts[0], minute: timeParts[1]);
    }

    return time;
  }