import '../fields/task_field.dart';
import '../fields/priority_field.dart';
import '../fields/due_date_field.dart';

class Task {
  final String id;
  String name;
  String description;
  final String parentId;
  final List<TaskField> fields;
  bool isComplete;
  bool isCompletedOnTime; // Add this property

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.parentId,
    required this.fields,
    this.isComplete = false,
    this.isCompletedOnTime = true, // Initialize as incomplete
  });

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

  void updateTask({
    required String name,
    required String description,
    List<TaskField> fields = const [],
    bool isComplete = false,
  }) {
    this.name = name;
    this.description = description;
    this.fields.clear();
    this.fields.addAll(fields);
    this.isComplete = isComplete;
  }
}
