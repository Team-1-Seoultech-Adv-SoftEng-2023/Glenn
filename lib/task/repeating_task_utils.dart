import 'package:flutter/foundation.dart';
import 'package:glenn/fields/due_date_field.dart';
import 'task.dart';
import 'package:flutter/material.dart';

enum RepeatPeriod { days, weeks, months, years }

DateTime incrementCurrentDate(
  DateTime currentDate, RepeatPeriod repeatPeriod, int customRepeat) {
  switch (repeatPeriod) {
    case RepeatPeriod.days:
      return currentDate.add(Duration(days: customRepeat));
    case RepeatPeriod.weeks:
      return currentDate.add(Duration(days: 7 * customRepeat));
    case RepeatPeriod.months:
      return DateTime(
          currentDate.year, currentDate.month + customRepeat, currentDate.day);
    case RepeatPeriod.years:
      return DateTime(
          currentDate.year + customRepeat, currentDate.month, currentDate.day);
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
  TimeOfDay dueTime = originalTask.getDueTime() ?? TimeOfDay.now();

  List<String> dateParts = repetitionEndDateController.text.split('-');
  DateTime endDate = DateTime(
    int.parse(dateParts[0]),
    int.parse(dateParts[1]),
    int.parse(dateParts[2]),
    dueTime.hour,
    dueTime.minute,
  );

  if (kDebugMode) {
    print(endDate);
  }

  while (
      currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
    Task copiedTask = Task.copyWithUniqueID(originalTask);
    DueDateField newDueDateField = DueDateField(dueDateTime: currentDate);
    newDueDateField.dueTime = dueTime;
    copiedTask.updateTask(fields: [newDueDateField]);
    repeatingTasks.add(copiedTask);
    currentDate =
        incrementCurrentDate(currentDate, selectedRepeatPeriod, repeatInterval);
  }
  return repeatingTasks;
}

void calculateRepeatingInterval(
    List<Task> repeatingTasks,
    TextEditingController repeatIntervalController,
    RepeatPeriod selectedRepeatPeriod) {
  List<DateTime> dueDates = [];
  for (Task task in repeatingTasks) {
    if (task.hasDueDate) {
      DateTime? dueDate = task.getDueDate();
      if (dueDate != null) {
        dueDates.add(dueDate);
      }
    }
  }
  dueDates.sort();

  // Calculate the repeating interval
  if (dueDates.length >= 2) {
    // Calculate the customRepeat
    int customRepeat = dueDates[1].difference(dueDates[0]).inDays;

    // Calculate the repeatPeriod
    RepeatPeriod repeatPeriod;
    if (customRepeat % 365 == 0) {
      repeatPeriod = RepeatPeriod.years;
      customRepeat = customRepeat ~/ 365;
    } else if (customRepeat % 30 == 0) {
      repeatPeriod = RepeatPeriod.months;
      customRepeat = customRepeat ~/ 30;
    } else if (customRepeat % 7 == 0) {
      repeatPeriod = RepeatPeriod.weeks;
      customRepeat = customRepeat ~/ 7;
    } else {
      repeatPeriod = RepeatPeriod.days;
    }

    // Set the values
    selectedRepeatPeriod = repeatPeriod;
    repeatIntervalController.text = customRepeat.toString();
  }
}

String getEndDateFormatted(List<Task> repeatingTasks) {
  if (repeatingTasks.isNotEmpty) {
    Task lastTask = repeatingTasks.lastWhere(
      (task) => !task.isComplete,
      orElse: () => repeatingTasks.first,
    );
    return formatDate(lastTask.getDueDate()!);
  } else {
    return '';
  }
}
