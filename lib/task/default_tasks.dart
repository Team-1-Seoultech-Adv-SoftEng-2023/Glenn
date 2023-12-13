import 'package:flutter/material.dart';
import 'task.dart';
import '../fields/due_date_field.dart';
import '../fields/priority_field.dart';

// Define the tasks list with sample data
final List<Task> tasks = [
  Task(
    id: '1',
    name: 'Task with Due Date and Priority',
    description: 'This task has both due date and priority',
    parentId: '',
    fields: [
      DueDateField(
        dueDateTime: DateTime(2023, 12, 12, 14, 30),
      ),
      PriorityField(priority: 2), // Medium priority
    ],
    filePaths: [
      'https://drive.google.com/file/d/1B6FtjriF8MyP0qZsXAdAxzoDPCuG4tnp/view?usp=drive_link'
    ],
  ),
  Task(
    id: '2',
    name: 'Task with a future Due Date Only',
    description: 'https://www.youtube.com/',
    parentId: '',
    fields: [
      DueDateField(dueDateTime: DateTime(2023, 12, 24, 10, 00)),
    ],
    filePaths: [],
  ),
  Task(
    id: '3',
    name: 'Task with Priority Only',
    description: 'This task has only a priority',
    parentId: '',
    fields: [
      PriorityField(priority: 3), // High priority
    ],
    filePaths: [],
  ),
  Task(
    id: '4',
    name: 'Task with No Due Date or Priority',
    description: 'This task has neither due date nor priority',
    parentId: '',
    fields: [],
  ),
  Task(
    id: '5',
    name: 'Task with Past Due Date',
    description: 'This task has a past due date',
    parentId: '',
    fields: [
      DueDateField(dueDateTime: DateTime(2023, 11, 10, 12, 00)),
    ],
    filePaths: [],
  ),
  Task(
    id: '6',
    name: 'Subtask 1',
    description: 'This is a subtask',
    parentId: '1',
    fields: [],
    filePaths: List.empty(),
  ),
  Task(
    id: '7',
    name: 'Subtask 2',
    description: 'This is a second subtask',
    parentId: '1',
    fields: [],
    filePaths: List.empty(),
  ),
  Task(
    id: '8',
    name: 'Repeating Task 1',
    description: 'This task repeats every day',
    parentId: '',
    fields: [
      DueDateField(
        dueDateTime: DateTime(2023, 12, 7, 14, 30),
      ),
    ],
    repeatingId: '8',
    filePaths: [],
  ),
  Task(
    id: '9',
    name: 'Repeating Task 2',
    description: 'This task repeats every day',
    parentId: '',
    fields: [
      DueDateField(
        dueDateTime: DateTime(2023, 12, 8, 14, 30),
      ),
    ],
    repeatingId: '8',
    filePaths: [],
  ),
  Task(
    id: '10',
    name: 'Repeating Task 3',
    description: 'This task repeats every day',
    parentId: '',
    fields: [
      DueDateField(
        dueDateTime: DateTime(2023, 12, 9, 14, 30),
      ),
    ],
    repeatingId: '8',
    filePaths: [],
  ),
  Task(
    id: '11',
    name: 'Repeating Task 4',
    description: 'This task repeats every day',
    parentId: '',
    fields: [
      DueDateField(
        dueDateTime: DateTime(2023, 12, 10, 14, 30),
      ),
    ],
    repeatingId: '8',
    filePaths: [],
  ),
  Task(
    id: '11',
    name: 'Repeating Task 4',
    description: 'This task repeats every day',
    parentId: '',
    fields: [
      DueDateField(
        dueDateTime: DateTime(2023, 12, 11, 14, 30),
      ),
    ],
    repeatingId: '8',
    filePaths: [],
  ),
  Task(
    id: '11',
    name: '12 Task',
    description: 'This task exists',
    parentId: '',
    fields: [
      DueDateField(
        dueDateTime: DateTime(2023, 12, 13, 14, 30),
      ),
    ],
    filePaths: [],
  ),
];