
// //preating_tasks_widget.dart

// import 'package:flutter/material.dart';

// import '../task/task.dart';
// import '../fields/due_date_field.dart';
// import '../fields/priority_field.dart';
// import '../fields/self_care_field.dart';


//  Widget buildRepeatTaskField(bool isRepeating, ValueChanged<bool> onChanged,) {
//     return CheckboxListTile(
//       title: const Text('Repeat Task'),
//       value: isRepeating,
//       onChanged: onChanged,
//     );
//   }

//   Widget buildRepeatPatternDropdown(RepeatPeriod selectedRepeatPeriod, 
//         ValueChanged<RepeatPeriod?> onChanged, Widget endDateField, Widget repeatIntervalDropdown,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.all(0.0),
//       child: Container(
//         // ... your existing code for the repeat pattern dropdown
//       ),
//     );
//   }

//    Widget buildRepeatIntervalDropdown(RepeatPeriod selectedRepeatPeriod, ValueChanged<RepeatPeriod?> onChanged, TextEditingController repeatIntervalController,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Repeats every...'),
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.only(
//                     right: 15.0,
//                     left: 100.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(
//                       width: 50,
//                       child: TextFormField(
//                         controller: repeatIntervalController,
//                         keyboardType: TextInputType.number,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   DropdownButton<RepeatPeriod>(
//                     value: selectedRepeatPeriod,
//                     onChanged: onChanged,
//                     items: RepeatPeriod.values
//                         .map<DropdownMenuItem<RepeatPeriod>>(
//                           (RepeatPeriod value) => DropdownMenuItem<RepeatPeriod>(
//                             value: value,
//                             child: Text(value.toString().split('.').last),
//                           ),
//                         )
//                         .toList(),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }