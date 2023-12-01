//import '../fields/task_field.dart';
import 'package:glenn/fields/due_date_field.dart';

import 'task.dart';
import 'package:flutter/material.dart';

enum RepeatPeriod { days, weeks, months, years}

// Delete the following???
// class RepeatingTaskField extends TaskField {
//   RepeatPeriod _repeatPeriod;
//   int _customRepeat;
//   DateTime _startDate;
//   DateTime _endDate;
//  
//   RepeatingTaskField({
//     required RepeatPeriod repeatPeriod,
//     required int customRepeat,
//     required DateTime startDate,
//     required DateTime endDate,
//   })  : _repeatPeriod = repeatPeriod,
//         _customRepeat = customRepeat,
//         _startDate = startDate,
//         _endDate = endDate,
//         super(name: 'Repeating Task', 
//               value: '') {
//     updateValue();
//   }
//
//   RepeatPeriod get repeatPeriod => _repeatPeriod;
//   set repeatPeriod(RepeatPeriod value) {
//     _repeatPeriod = value;
//     updateValue();
//   }
//
//   int get customRepeatDays => _customRepeat;
//   set customRepeatDays(int value) {
//     _customRepeat = value;
//     updateValue();
//   }
//
//   DateTime get startDate => _startDate;
//   set startDate(DateTime value) {
//     _startDate = value;
//     updateValue();
//   }
//
//   DateTime get endDate => _endDate;
//   set endDate(DateTime value) {
//     _endDate = value;
//     updateValue();
//   }
//
//   void updateValue() {
//     super.value = _formatRepeatPeriod(_repeatPeriod, _customRepeat);
//   }
// }

// String _formatRepeatPeriod(RepeatPeriod repeatPeriod, int customRepeatDays) {
//     switch (repeatPeriod) {
//       case RepeatPeriod.days:
//         return 'Daily';
//       case RepeatPeriod.weeks:
//         return 'Weekly';
//       case RepeatPeriod.months:
//         return 'Monthly';
//       case RepeatPeriod.years:
//         return 'Yearly';
//       default:
//         return 'Unknown';
//     }
// }

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

