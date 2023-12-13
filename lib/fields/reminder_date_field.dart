import 'package:flutter/material.dart';
import 'task_field.dart';

class ReminderDateField extends TaskField {
  bool _hasReminder;

  ReminderDateField({
    required bool hasReminder,
  })  : _hasReminder = hasReminder,
        super(name: 'Reminder', value: 'Reminder');

  bool get hasReminder => _hasReminder;

  set hasReminder(bool value) {
    _hasReminder = value;
    updateValue();
  }

  void updateValue() {
    super.value = _hasReminder ? 'Reminder' : 'No Reminder';
  }
}
