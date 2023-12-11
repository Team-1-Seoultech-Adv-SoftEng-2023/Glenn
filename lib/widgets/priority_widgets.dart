// //priority_widgets.dart

import 'package:flutter/material.dart';

import '../task/task.dart';
import '../fields/due_date_field.dart';
import '../fields/priority_field.dart';
import '../fields/self_care_field.dart';

Widget buildPriorityDropdown(int selectedPriority, ValueChanged<int?> onChanged,) {
  return DropdownButtonFormField<int>(
    value: selectedPriority,
    items: const [
         DropdownMenuItem<int>(
          value: 0,
          child: Text('None'),
        ),
        DropdownMenuItem<int>(
          value: 1,
          child: Text('Low'),
        ),
        DropdownMenuItem<int>(
          value: 2,
          child: Text('Medium'),
        ),
        DropdownMenuItem<int>(
          value: 3,
          child: Text('High'),
        ),
        DropdownMenuItem<int>(
          value: 4,
          child: Text('Critical'),
        ),
      ],
    onChanged: onChanged,
    decoration: const InputDecoration(labelText: 'Priority'),
  );
}