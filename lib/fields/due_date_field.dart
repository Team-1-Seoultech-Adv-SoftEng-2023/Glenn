//due_date_field.dart
import 'package:flutter/material.dart';
import 'task_field.dart';

class DueDateField extends TaskField {
  DateTime _dueDateTime;

  DueDateField({
    required dueDateTime,
  })  : _dueDateTime = dueDateTime,
        super(
            name: 'Due Date',
            value: '${formatDate(dueDateTime)} ${formatTime( extractTimeOfDay(dueDateTime))}');

  
  DateTime get dueDateTime => _dueDateTime;

  set dueDateTime(DateTime value) {
    _dueDateTime = value;
    updateValue();
  }

  // Getter for date
  DateTime get dueDate => DateTime(_dueDateTime.year, _dueDateTime.month, _dueDateTime.day);

  // Setter for date
  set dueDate(DateTime value) {
    _dueDateTime = DateTime(value.year, value.month, value.day, _dueDateTime.hour, _dueDateTime.minute);
    updateValue();
  }

  // Getter for time
  TimeOfDay get dueTime => extractTimeOfDay(_dueDateTime);

  // Setter for time
  set dueTime(TimeOfDay value) {
    _dueDateTime = DateTime(_dueDateTime.year, _dueDateTime.month, _dueDateTime.day, value.hour, value.minute);
    updateValue();
  }

  void updateValue() {
    super.value = '${formatDate(_dueDateTime)} ${formatTime(extractTimeOfDay(_dueDateTime))}';
  }
}

String formatDate (DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

String formatTime (TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

TimeOfDay extractTimeOfDay(DateTime dateTime) {
  return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
}

