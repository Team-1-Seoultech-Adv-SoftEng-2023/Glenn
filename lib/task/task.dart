//task.dart
import '../fields/task_field.dart';
import '../fields/priority_field.dart';
import '../fields/due_date_field.dart';
import '../fields/self_care_field.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class Task {
  final String id;
  String name;
  String description;
  final String parentId;
  String repeatingId;
  final List<TaskField> fields;
  bool isComplete;
  bool isCompletedOnTime; // Add this property
  List<String> filePaths;
  DateTime? reminderDate;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.parentId,
    required this.fields,
    this.repeatingId = '',
    this.isComplete = false,
    this.isCompletedOnTime = true, // Initialize as incomplete
    this.filePaths = const [],
    this.reminderDate,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
  
  Task.copy(Task original)
      : id = original.id,
        name = original.name,
        description = original.description,
        parentId = original.parentId,
        repeatingId = original.repeatingId,
        fields = List.from(original.fields),
        isComplete = original.isComplete,
        isCompletedOnTime = original.isCompletedOnTime,
        reminderDate = original.reminderDate,
        filePaths = original.filePaths;

  factory Task.copyWithUniqueID(Task original) {
    final String newId = UniqueKey().toString();
    return Task(
      id: newId,
      name: original.name,
      description: original.description,
      parentId: original.parentId,
      repeatingId: original.repeatingId,
      fields: List.from(original.fields),
      isComplete: original.isComplete,
      isCompletedOnTime: original.isCompletedOnTime,
      reminderDate: original.reminderDate,
      filePaths: List.from(original.filePaths),
    );
  }

// Method to launch URL if the description contains one
  void launchURL() async {
    final String? url = getDescriptionUrl();
    if (url != null) {
      final Uri uri = Uri.parse(url);
      await launchUrl(uri);
    }
  }

  // Method to extract the URL from the description
  String? getDescriptionUrl() {
    final RegExp urlRegExp = RegExp(r'http[s]?:\/\/[^\s]+');
    final Match? match = urlRegExp.firstMatch(description);

    if (match != null) {
      return match.group(0);
    }

    return null;
  }

  int? getPriority() {
    final priorityField = fields.firstWhere(
      (field) => field is PriorityField,
      orElse: () => PriorityField(priority: -1), // Default if not found
    ) as PriorityField;

    return priorityField.priority;
  }

  bool get hasPriority {
    return fields.any((field) => field is PriorityField);
  }

  bool get hasDueDate {
    return fields.any((field) => field is DueDateField);
  }

  DateTime? getDueDate() {
    final dueDateField = fields.whereType<DueDateField>().firstOrNull;

    if (dueDateField != null) {
      return dueDateField.dueDate;
    } else {
      // Return null if no due date field is found
      return null;
    }
  }

  TimeOfDay? getDueTime() {
    final dueDateField = fields.whereType<DueDateField>().firstOrNull;

    if (dueDateField != null) {
      final DateTime dueDate = dueDateField.dueDate;
      return TimeOfDay(hour: dueDate.hour, minute: dueDate.minute);
    } else {
      return null;
    }
  }


  void updateTask({
    String? name,
    String? description,
    List<TaskField>? fields,
    bool? isComplete,
    String? repeatingId,
    List<String>? filePaths,
    DateTime? reminderDate,
  }) {
    this.name = name ?? this.name;
    this.description = description ?? this.description;
    fields?.forEach((updatedField) {
      // Check if a field of the same type already exists
      final existingFieldIndex =
          this.fields.indexWhere((field) => field.runtimeType == updatedField.runtimeType);
      if (existingFieldIndex != -1) {
        // If the field of the same type exists, replace it with the updated field
        this.fields[existingFieldIndex] = updatedField;
      } else {
        // If the field of the same type doesn't exist, add the updated field
        this.fields.add(updatedField);
      }
    });
    this.isComplete = isComplete ?? this.isComplete;
    this.repeatingId = repeatingId ?? this.repeatingId;
    this.filePaths = filePaths ?? this.filePaths;
    this.reminderDate = reminderDate ?? this.reminderDate;
  }

  void setDueDate(DateTime newDueDate, TimeOfDay newDueTime) {
    // Check if the task has a due date field
    if (hasDueDate) {
      // Find the DueDateField in the fields list
      final dueDateFieldIndex = fields.indexWhere((field) => field is DueDateField);
      if (dueDateFieldIndex != -1) {
        // Update the due date and time in the existing DueDateField
        final dueDateField = fields[dueDateFieldIndex] as DueDateField;
        dueDateField.dueDateTime = DateTime(
          newDueDate.year,
          newDueDate.month,
          newDueDate.day,
          newDueTime.hour,
          newDueTime.minute,
        );
        dueDateField.updateValue();
      }
    } else {
      // If the task doesn't have a due date field, create a new one
      final dueDateField = DueDateField(dueDateTime: DateTime(
        newDueDate.year,
        newDueDate.month,
        newDueDate.day,
        newDueTime.hour,
        newDueTime.minute,
      ));
      this.fields.add(dueDateField);
    }
  }


  void printTaskDetails() {
    print('Task ID: $id');
    print('Name: $name');
    print('Description: $description');
    print('Parent ID: $parentId');
    print('Repeating ID: $repeatingId');
    print('Is Complete: $isComplete');
    print('Is Completed On Time: $isCompletedOnTime');
    print('File Paths: $filePaths');
    print('Reminder Date: $reminderDate');
    print('Fields:');
    for (var field in fields) {
      if (field is DueDateField) {
        print('  Due Date: ${field.value}, Due Date Time: ${field.dueDate} ${field.dueTime}');
      } else if (field is PriorityField) {
        print('  Priority: ${field.value}');
      } else if (field is SelfCareField) {
        print('  Self Care Activity: ${field.value}');
      } else {
        print('  Field Name: ${field.name}, Field Value: ${field.value}');
      }
    }
  }

}
