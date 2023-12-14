import 'package:flutter/material.dart';
import 'task.dart';
import '../fields/due_date_field.dart';
import '../fields/priority_field.dart';

// Define the tasks list with sample data
final List<Task> tasks = [
  Task(
    id: '1',
    name: 'Buy Groceries',
    description: 'This task has both due date and priority',
    parentId: '',
    fields: [
      DueDateField(
        dueDateTime: DateTime(2023, 12, 14, 14, 30),
      ),
      PriorityField(priority: 2), // Medium priority
    ],
    filePaths: [
      'https://drive.google.com/file/d/1B6FtjriF8MyP0qZsXAdAxzoDPCuG4tnp/view?usp=drive_link'
    ],
  ),
  Task(
    id: '2',
    name: 'Watch this funny video!',
    description: 'https://www.youtube.com/',
    parentId: '',
    fields: [
      DueDateField(dueDateTime: DateTime(2023, 12, 14, 10, 00)),
    ],
    filePaths: [],
  ),
  Task(
    id: '3',
    name: 'Pay Bills!',
    description: 'This task has only a priority',
    parentId: '',
    fields: [
      PriorityField(priority: 3), // High priority
    ],
    filePaths: [],
  ),
  Task(
    id: '4',
    name: 'Project Assignment!',
    description: 'This task has neither due date nor priority',
    parentId: '',
    fields: [
      DueDateField(dueDateTime: DateTime(2023, 12, 18, 10, 00)),
    ],
  ),
  Task(
    id: '400',
    name: 'Complete Report!',
    description: 'write in docs',
    parentId: '4',
    fields: [
      DueDateField(dueDateTime: DateTime(2023, 12, 18, 10, 00)),
    ],
  ),
  Task(
    id: '401',
    name: 'Write Code!',
    description: 'This task has neither due date nor priority',
    parentId: '4',
    fields: [
      DueDateField(dueDateTime: DateTime(2023, 12, 18, 10, 00)),
    ],
  ),
  Task(
    id: '5',
    name: 'Take out the trash',
    description: 'This task has a past due date',
    parentId: '',
    fields: [
      DueDateField(dueDateTime: DateTime(2023, 11, 10, 12, 00)),
    ],
    filePaths: [],
  ),
  Task(
    id: '6',
    name: 'Buy Milk',
    description: 'This is a subtask',
    parentId: '1',
    fields: [],
    filePaths: List.empty(),
  ),
  Task(
    id: '7',
    name: 'Get Eggs',
    description: 'This is a second subtask',
    parentId: '1',
    fields: [],
    filePaths: List.empty(),
  ),
  Task(
    id: '10',
    name: 'Repeating Task',
    description: 'This task repeats',
    parentId: '',
    fields: [
      DueDateField(
        dueDateTime: DateTime(2023, 12, 13, 14, 30),
      ), PriorityField(priority: 1),
    ],
    repeatingId: '10',
    filePaths: [],
  ),
  Task(
    id: '11',
    name: 'Repeating Task',
    description: 'This task repeats',
    parentId: '',
    fields: [
      DueDateField(
        dueDateTime: DateTime(2023, 12, 14, 14, 30),
      ), PriorityField(priority: 1),
    ],
    repeatingId: '10',
    filePaths: [],
  ),
  Task(
    id: '11',
    name: 'Repeating Task',
    description: 'This task repeats',
    parentId: '',
    fields: [
      DueDateField(
        dueDateTime: DateTime(2023, 12, 15, 14, 30),
      ), PriorityField(priority: 1),
    ],
    repeatingId: '10',
    filePaths: [],
  ),
];