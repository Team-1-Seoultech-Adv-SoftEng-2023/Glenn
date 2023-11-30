import 'package:intl/intl.dart';
import 'task_field.dart';
import 'package:glenn/task/task.dart';
import 'package:flutter/material.dart';

enum RepeatPeriod { Daily, Weekly, Monthly, Yearly, Custom }

class RepeatingTaskField extends TaskField {
  RepeatPeriod _repeatPeriod;
  int _customRepeatDays;
  DateTime _startDate;
  DateTime _endDate;
  
  RepeatingTaskField({
    required RepeatPeriod repeatPeriod,
    int customRepeatDays = 1,
    required DateTime startDate,
    required DateTime endDate,
  })  : _repeatPeriod = repeatPeriod,
        _customRepeatDays = customRepeatDays,
        _startDate = startDate,
        _endDate = endDate,
        super(name: 'Repeating Task', 
              value: '') {
    updateValue();
  }

  RepeatPeriod get repeatPeriod => _repeatPeriod;
  set repeatPeriod(RepeatPeriod value) {
    _repeatPeriod = value;
    updateValue();
  }

  int get customRepeatDays => _customRepeatDays;
  set customRepeatDays(int value) {
    _customRepeatDays = value;
    updateValue();
  }

  void updateValue() {
    super.value = _formatRepeatPeriod(_repeatPeriod, _customRepeatDays);
  }

  String _formatRepeatPeriod(RepeatPeriod repeatPeriod, int customRepeatDays) {
    switch (repeatPeriod) {
      case RepeatPeriod.Daily:
        return 'Daily';
      case RepeatPeriod.Weekly:
        return 'Weekly';
      case RepeatPeriod.Monthly:
        return 'Monthly';
      case RepeatPeriod.Yearly:
        return 'Yearly';
      case RepeatPeriod.Custom:
        return 'Every $_customRepeatDays days';
      default:
        return 'Unknown';
    }
  }

  List<Task> generateRepeatingTasks() {
    List<Task> repeatingTasks = [];
    DateTime currentDate = _startDate;

    while (currentDate.isBefore(_endDate) || currentDate.isAtSameMomentAs(_endDate)) {
      String taskId = UniqueKey().toString(); // Generate a unique ID for each task
      String taskName = 'Task for ${DateFormat('yyyy-MM-dd').format(currentDate)}';
      
      // Create a new task
      Task task = Task(
        id: taskId,
        name: taskName,
        description: '',
        parentId: '', // You may need to adjust this based on your application logic
        fields: [], // Add any additional fields you need for each task
        isComplete: false, // You can adjust this based on your requirements
        isCompletedOnTime: true,
      );

      repeatingTasks.add(task);

      // Increment the current date based on the repeat period
      switch (_repeatPeriod) {
        case RepeatPeriod.Daily:
          currentDate = currentDate.add(Duration(days: 1));
          break;
        case RepeatPeriod.Weekly:
          currentDate = currentDate.add(Duration(days: 7));
          break;
        case RepeatPeriod.Monthly:
          currentDate = DateTime(currentDate.year, currentDate.month + 1, currentDate.day);
          break;
        case RepeatPeriod.Yearly:
          currentDate = DateTime(currentDate.year + 1, currentDate.month, currentDate.day);
          break;
        case RepeatPeriod.Custom:
          currentDate = currentDate.add(Duration(days: _customRepeatDays));
          break;
        default:
          // Handle unknown repeat period
          break;
      }
    }

    return repeatingTasks;
  }
}

