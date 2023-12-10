import 'package:glenn/fields/due_date_field.dart';
import 'task.dart';
import 'package:flutter/material.dart';

enum RepeatPeriod { days, weeks, months, years}

DateTime incrementCurrentDate(DateTime currentDate, RepeatPeriod repeatPeriod, int customRepeat) {
  switch (repeatPeriod) {
    case RepeatPeriod.days:
      return currentDate.add(Duration(days: customRepeat));
    case RepeatPeriod.weeks:
      return currentDate.add(Duration(days: 7*customRepeat));
    case RepeatPeriod.months:
      return DateTime(currentDate.year, currentDate.month + customRepeat, currentDate.day);
    case RepeatPeriod.years:
      return DateTime(currentDate.year + customRepeat, currentDate.month, currentDate.day);
    default:
      throw ArgumentError('Invalid RepeatPeriod: $repeatPeriod');
  }
}

List<Task> generateRepeatingTasks({
  required Task originalTask,
  required TextEditingController repetitionEndDateController,
  required RepeatPeriod selectedRepeatPeriod,
  required int repeatInterval,
}) {

  List<Task> repeatingTasks = [];
  originalTask.repeatingId = UniqueKey().toString();

  DateTime currentDate = originalTask.getDueDate() ?? DateTime.now();
  List<String> dateParts = repetitionEndDateController.text.split('-');
  DateTime endDate = DateTime(
    int.parse(dateParts[0]),
    int.parse(dateParts[1]),
    int.parse(dateParts[2]),
    currentDate.hour,
    currentDate.minute,
  );

  while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
    
    Task copiedTask = Task.copyWithUniqueID(originalTask);
    DueDateField newDueDateField = DueDateField(dueDateTime: currentDate);
    copiedTask.updateTask(fields: [newDueDateField]);
    
    repeatingTasks.add(copiedTask);

    currentDate = incrementCurrentDate(currentDate, selectedRepeatPeriod, repeatInterval);
  }

  return repeatingTasks;
}

