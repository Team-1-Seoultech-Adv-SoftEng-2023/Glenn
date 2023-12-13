//due_date_widgets.dart

import 'package:flutter/material.dart';
import 'package:glenn/fields/due_date_field.dart';

Widget buildDueDateTimeField(
    BuildContext context,
    TextEditingController dateController,
    TextEditingController timeController) {
  return ListTile(
    title: const Text('Due Date'),
    subtitle: Row(
      children: [
        Expanded(
          child: buildDateField(dateController, () async {
            DateTime? selectedDate =
                await showDatePickerAndUpdate(context, dateController);

            if (selectedDate != null) {
              updateDueDateController(
                  selectedDate, dateController, timeController);
            }
          }),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: buildTimeField(timeController, () {
            showTimePickerAndUpdate(context, timeController, dateController);
          }),
        ),
      ],
    ),
  );
}

Widget buildDateField(TextEditingController dateController, VoidCallback onTap) {
  return TextFormField(
    controller: dateController,
    keyboardType: TextInputType.datetime,
    decoration: const InputDecoration(labelText: 'Date'),
    onTap: onTap,
  );
}

Widget buildTimeField(TextEditingController timeController, VoidCallback onTap) {
  return TextFormField(
    controller: timeController,
    keyboardType: TextInputType.datetime,
    decoration: const InputDecoration(labelText: 'Time'),
    onTap: onTap,
  );
}

Widget buildEndDateField(BuildContext context, TextEditingController endDateController, TextEditingController dueDateController) {
  return TextFormField(
    controller: endDateController,
    keyboardType: TextInputType.datetime,
    decoration: const InputDecoration(labelText: 'End Date'),
    onTap: () async {
      DateTime? selectedDate = await showEndDatePickerAndUpdate(context, endDateController, dueDateController);

      if (selectedDate != null) {
        endDateController.text = formatDate(selectedDate);
      }
    },
  );
}


Future<DateTime?> showEndDatePickerAndUpdate(
  BuildContext context, TextEditingController dueDateController, TextEditingController endDateController) async {
  
  DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
  );

  return selectedDate;
}

Future<DateTime?> showDatePickerAndUpdate(BuildContext context, TextEditingController dueDateController) async {
  DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: dueDateController.text.isNotEmpty
        ? DateTime.parse(dueDateController.text)
        : DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
  );

  if (selectedDate != null) {
    return selectedDate;
  }
  return null;
}

Future<void> showTimePickerAndUpdate(BuildContext context, TextEditingController dueTimeController, TextEditingController dueDateController) async {
  TimeOfDay? selectedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );
  if (selectedTime != null) {
    updateDueTimeController(selectedTime, dueTimeController, dueDateController);
  }
}

void updateDueDateController(DateTime selectedDate, TextEditingController dueDateController, TextEditingController dueTimeController) {
  dueDateController.text = formatDate(selectedDate);

  if (dueTimeController.text.isEmpty) {
    dueTimeController.text = formatTime(const TimeOfDay(hour: 23, minute: 59));
  }
}

void updateDueTimeController(TimeOfDay selectedTime, TextEditingController dueTimeController, TextEditingController dueDateController) {
  dueTimeController.text = formatTime(selectedTime);

  if (dueDateController.text.isEmpty) {
    dueDateController.text = formatDate(DateTime.now());
  }
}

bool isValidDate(String dateText) {
  RegExp dateRegExp = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  if (!dateRegExp.hasMatch(dateText)) {
    return false; // Invalid format
  }

  List<int?> dateComponents = dateText.split('-').map(int.tryParse).toList();

  if (dateComponents.contains(null)) {
    return false; // Non-numeric component
  }

  int? year = dateComponents[0];
  int? month = dateComponents[1];
  int? day = dateComponents[2];

  if (year! < 1990) {
    return false; // Year is too early
  }

  if (month! < 1 || month > 12) {
    return false; // Invalid month
  }

  if (day! < 1 || day > DateTime(year, month + 1, 0).day) {
    return false; // Invalid day
  }

  return true; 
}

bool isValidTime(String timeText) {
    RegExp timeRegExp = RegExp(r'(\d{2}:\d{2})');
  
    if (!timeRegExp.hasMatch(timeText)) {
      return false;
    }

    Match match = timeRegExp.firstMatch(timeText)!;
    String matchedTime = match.group(1)!;
    print(matchedTime);

    List<int?> timeComponents = timeText.split(':').map(int.tryParse).toList();

    if (timeComponents.contains(null)) {
      return false; // Non-numeric component
    }

    int? hour = timeComponents[0];
    int? min = timeComponents[1];

    if (hour! > 24 || hour < 0) {
      return false; 
    }

    if (min! < 0 || min > 59) {
      return false; 
    }

    return true; 
}