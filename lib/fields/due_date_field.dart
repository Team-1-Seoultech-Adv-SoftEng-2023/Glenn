//due_date_field.dart
import 'package:flutter/material.dart';
import 'task_field.dart';

class DueDateField extends TaskField {
  DateTime _dueDate;
  TimeOfDay _dueTime;

  DueDateField({
    required DateTime dueDate,
    required TimeOfDay dueTime,
  })  : _dueDate = dueDate,
        _dueTime = dueTime,
        super(
            name: 'Due Date',
            value: '${formatDate(dueDate)} ${formatTime(dueTime)}');

  DateTime get dueDate => _dueDate;
  set dueDate(DateTime value) {
    _dueDate = value;
    updateValue();
  }

  TimeOfDay get dueTime => _dueTime;
  set dueTime(TimeOfDay value) {
    _dueTime = value;
    updateValue();
  }

  void updateValue() {
    super.value = '${formatDate(_dueDate)} ${formatTime(_dueTime)}';
  }
}

String formatDate (DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

String formatTime (TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}${time.minute.toString().padLeft(2, '0')}';
}
