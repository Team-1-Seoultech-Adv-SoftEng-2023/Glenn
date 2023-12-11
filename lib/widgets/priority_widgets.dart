// //priority_widgets.dart

import 'package:flutter/material.dart';

//  Widget buildRepeatTaskField(bool isRepeating, ValueChanged<bool> onChanged,) {
//     return CheckboxListTile(
//       title: const Text('Repeat Task'),
//       value: isRepeating,
//       onChanged: onChanged,
//     );
//   }

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