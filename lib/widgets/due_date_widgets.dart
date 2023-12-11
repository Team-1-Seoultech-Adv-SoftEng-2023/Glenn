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

Widget buildDateField(TextEditingController controller, VoidCallback onTap) {
  return TextFormField(
    controller: controller,
    keyboardType: TextInputType.datetime,
    decoration: const InputDecoration(labelText: 'Date'),
    onTap: onTap,
  );
}

Widget buildTimeField(TextEditingController controller, VoidCallback onTap) {
  return TextFormField(
    controller: controller,
    keyboardType: TextInputType.datetime,
    decoration: const InputDecoration(labelText: 'Time'),
    onTap: onTap,
  );
}

Widget buildEndDateField(TextEditingController controller, VoidCallback onTap) {
  return TextFormField(
    controller: controller,
    keyboardType: TextInputType.datetime,
    onTap: onTap,
  );
}

Future<void> showEndDatePicker(
  BuildContext context,
  TextEditingController dueDateController,
  TextEditingController repetitionEndDateController,
) async {
  DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: dueDateController.text.isNotEmpty
        ? DateTime.parse(dueDateController.text)
        : DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2101),
  );

  if (selectedDate != null) {
    repetitionEndDateController.text = formatDate(selectedDate);
  }
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

Future<DateTime?> showDatePickerAndUpdate(BuildContext context, TextEditingController dueDateController) async {
  DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: dueDateController.text.isNotEmpty
        ? DateTime.parse(dueDateController.text)
        : DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2101),
  );

  if (selectedDate != null) {
    return selectedDate;
  }
  return null;
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

