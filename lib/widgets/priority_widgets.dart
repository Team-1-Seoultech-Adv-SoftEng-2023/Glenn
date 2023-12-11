// //priority_widgets.dart

import 'package:flutter/material.dart';
import 'package:glenn/fields/priority_field.dart';


Widget buildPriorityDropdown(int selectedPriority, ValueChanged<int?> onChanged) {
  return DropdownButtonFormField<int>(
    value: selectedPriority,
    items: List.generate(5, (index) {
      return DropdownMenuItem<int>(
        value: index,
        child: Text(PriorityField.priorityToString(index)),
      );
    }),
    onChanged: onChanged,
    decoration: const InputDecoration(labelText: 'Priority'),
  );
}