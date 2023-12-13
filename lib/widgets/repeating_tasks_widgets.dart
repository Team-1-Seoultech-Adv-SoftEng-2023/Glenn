// repeating_tasks_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glenn/fields/due_date_field.dart';
import 'package:glenn/task/repeating_task_utils.dart';
import 'package:glenn/widgets/due_date_widgets.dart';


Widget buildRepeatTaskField({
  required bool isRepeating,
  required TextEditingController dueDateController,
  required TextEditingController dueTimeController,
  required TextEditingController repetitionEndDateController,
  required TextEditingController repeatIntervalController,
  required RepeatPeriod selectedRepeatPeriod,
  required BuildContext context,
  required ValueChanged<RepeatPeriod?> onRepeatPeriodChanged,
  required ValueChanged<bool?> onRepeatingCheckboxChanged,
}) {
  if (isRepeating) {
    initializeRepeatTaskValues(
      dueDateController: dueDateController,
      dueTimeController: dueTimeController,
      repeatIntervalController: repeatIntervalController,
      repetitionEndDateController: repetitionEndDateController,
    );
  }

  return Column(
    children: [
      CheckboxListTile(
        title: const Text('Repeat Task'),
        value: isRepeating,
        onChanged: onRepeatingCheckboxChanged,
      ),
      if (isRepeating)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            color: Colors.grey.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('End Date'),
                    buildEndDateField(context, repetitionEndDateController, dueDateController),
                  ],
                ),
                const SizedBox(height: 25.0),
                buildRepeatIntervalDropdown(
                  selectedRepeatPeriod: selectedRepeatPeriod,
                  onChanged: onRepeatPeriodChanged,
                  repeatIntervalController: repeatIntervalController,
                ),
              ],
            ),
          ),
        ),
    ],
  );
}


Widget buildRepeatIntervalDropdown({
  required RepeatPeriod selectedRepeatPeriod,
  required ValueChanged<RepeatPeriod?> onChanged,
  required TextEditingController repeatIntervalController,
}) {  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Repeats every...'),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                right: 15.0,
                left: 100.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 50,
                    child: TextFormField(
                      controller: repeatIntervalController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^[1-99]\d*')),
                        // Ensures that only digits are allowed
                        FilteringTextInputFormatter.deny(RegExp(r'^-')),
                        // Denies input with a minus sign
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButton<RepeatPeriod>(
                  value: selectedRepeatPeriod,
                  onChanged: onChanged,
                  items: RepeatPeriod.values
                      .map<DropdownMenuItem<RepeatPeriod>>(
                        (RepeatPeriod value) => DropdownMenuItem<RepeatPeriod>(
                          value: value,
                          child: Text(value.toString().split('.').last),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

void initializeRepeatTaskValues({
  required TextEditingController dueDateController,
  required TextEditingController dueTimeController,
  required TextEditingController repeatIntervalController,
  required TextEditingController repetitionEndDateController,
}) {
  if (dueDateController.text.isEmpty) {
    dueDateController.text = formatDate(DateTime.now());
  }
  if (dueTimeController.text.isEmpty) {
    dueTimeController.text = formatTime(const TimeOfDay(hour: 23, minute: 59));
  }
  if (repeatIntervalController.text.isEmpty) {
    repeatIntervalController.text = '1';
  }
  if (repetitionEndDateController.text.isEmpty) {
    String tmp = dueDateController.text;
    repetitionEndDateController.text = tmp;
  }
}
