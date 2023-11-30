//task.dart
import '../fields/task_field.dart';
import '../fields/priority_field.dart';
import '../fields/due_date_field.dart';
import 'package:url_launcher/url_launcher.dart';

class Task {
  final String id;
  String name;
  String description;
  final String parentId;
  final List<TaskField> fields;
  bool isComplete;
  bool isCompletedOnTime; // Add this property
  List<String> filePaths;
  DateTime? reminderDate;

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
    this.filePaths = const [],
    this.reminderDate,
  });

  Task.copy(Task original)
      : id = original.id,
        name = original.name,
        description = original.description,
        parentId = original.parentId,
        fields = List.from(original.fields),
        isComplete = original.isComplete,
        isCompletedOnTime = original.isCompletedOnTime,
        reminderDate = original.reminderDate,
        filePaths = original.filePaths;

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
