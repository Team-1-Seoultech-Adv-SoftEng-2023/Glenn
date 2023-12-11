//due_date_widgets.dart

import 'package:flutter/material.dart';

import '../task/task.dart';
import '../fields/due_date_field.dart';
import '../fields/priority_field.dart';
import '../fields/self_care_field.dart';

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

Widget buildEndDateField(TextEditingController controller, VoidCallback onTap,) {
  return TextFormField(
    controller: controller,
    keyboardType: TextInputType.datetime,
    onTap: onTap,
  );
}
