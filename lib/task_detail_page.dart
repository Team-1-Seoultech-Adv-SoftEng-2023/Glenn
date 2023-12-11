import 'package:flutter/material.dart';
import 'package:glenn/main.dart';
import 'task_edit_page.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

import 'task/task.dart';
import 'fields/due_date_field.dart';
import 'fields/priority_field.dart';
import 'fields/self_care_field.dart';

import 'widgets/priority_widgets.dart';
import 'widgets/due_date_widgets.dart';
import 'widgets/repeating_tasks_widgets.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;
  final List<Task> subtasks;
  final List<Task> tasks;
  final Function(Task) onTaskUpdated;
  final Function(Task) onTaskCreated;
  final Function(Task) onTaskDeleted;
  final Function(DueDateField) onUpdateDueDateTime;

  const TaskDetailPage({
    Key? key,
    required this.task,
    required this.subtasks,
    required this.tasks,
    required this.onTaskUpdated,
    required this.onTaskCreated,
    required this.onTaskDeleted,
    required this.onUpdateDueDateTime,
  }) : super(key: key);

  @override
  TaskDetailPageState createState() => TaskDetailPageState();
  
}

class TaskDetailPageState extends State<TaskDetailPage> {
  List<String> attachedFiles = [];

  @override
  void initState() {
    super.initState();
    attachedFiles.addAll(widget.task.filePaths);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Detail'),
        actions: <Widget>[
         if (!widget.task.isComplete)
         IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await _showConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: Text(widget.task.name),
            subtitle: GestureDetector(
              child: Text(
                widget.task.description,
                style: TextStyle(
                  color: widget.task.getDescriptionUrl() != null
                      ? Colors.blue
                      : Colors.black,
                  decoration: widget.task.getDescriptionUrl() != null
                      ? TextDecoration.underline
                      : TextDecoration.none,
                ),
              ),
              onTap: () {
                widget.task.launchURL();
              },
            ),
          ),
          if (widget.task.fields.isNotEmpty) _buildFieldContainer(),
          if (widget.subtasks.isNotEmpty) _buildSubtasksSection(),
        ],
      ),
    );
  }


  Widget _buildDueDateField(DueDateField field) {
    return ListTile(
      title: const Text('Due Date'),
      subtitle: Row(
        children: [
          Text('Date: ${formatDate(field.dueDate)}'),
          const SizedBox(width: 8),
          Text('Time: ${formatTime(field.dueTime)}'),
        ],
      ),
    );
  }

  Widget _buildPriorityField(PriorityField priorityField) {
    return ListTile(
      title: const Text('Priority'),
      subtitle: Text(priorityField.value),
    );
  }

  Widget _buildSelfCareField(SelfCareField selfCareField) {
    return ListTile(
      title: const Text('Self Care'),
      subtitle: Text(selfCareField.value),
    );
  }
  
void _openFile(String filePath) {
  if (filePath.isNotEmpty) {
    if (filePath.startsWith('http://') || filePath.startsWith('https://')) {
      // Open URL
      launchURL(Uri.parse(filePath));
    } else {
      // Open local file
      OpenFile.open(filePath);
    }
  }
}
void launchURL(Uri uri) async {
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $uri';
  }
}

Widget _buildSubtasksSection() {
    // Show subtasks only if there are subtasks and the task is not complete
    if (widget.subtasks.isNotEmpty && !widget.task.isComplete) {
      return Column(
        children: <Widget>[
          const Text('Subtasks:'),
          ListView.builder(
            shrinkWrap: true,
            itemCount: widget.subtasks.length,
            itemBuilder: (context, index) {
              final subtask = widget.subtasks[index];
              return ListTile(
                title: Text(subtask.name),
                subtitle: Text(subtask.description),
              );
            },
          ),
        ],
      );
    } else {
      return Container(); // Empty container when no subtasks or task is complete
    }
  }
Widget _buildAttachedFilesField() {
  return ListTile(
    title: const Text('Attached Files'),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: attachedFiles.map((filePath) {
        return InkWell(
          onTap: !widget.task.isComplete
              ? () {
                  if (filePath.isNotEmpty) {
                    _openFile(filePath);
                  }
                }
              : null,
          child: Text(
            filePath.isEmpty ? 'No attached files' : filePath.split('/').last,
            style: TextStyle(
              color: widget.task.isComplete ? Colors.black : Colors.blue,
              decoration: widget.task.isComplete ? TextDecoration.none : TextDecoration.underline,
            ),
          ),
        );
      }).toList(),
    ),
  );
}

// Modify _buildFieldContainer to include _buildAttachedFilesField
Widget _buildFieldContainer() {
  return Container(
    padding: const EdgeInsets.all(10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ...widget.task.fields.map((field) {
          if (field is PriorityField) {
            return _buildPriorityField(field);
          } else if (field is DueDateField) {
            return _buildDueDateField(field);
          } else if (field is SelfCareField) {
            return _buildSelfCareField(field);
          } else {
            return ListTile(
              title: Text(field.name),
              subtitle: Text(field.value),
            );
          }
        }).toList(),
        _buildAttachedFilesField(), // Include attached files field
      ],
    ),
  );
}

Future<void> _showConfirmationDialog(BuildContext context) async {
  List<Task> repeatingTasks = [];
  Task task = widget.task;
  
  bool shouldEditTask = true;
  if (widget.task.repeatingId != ''){
    shouldEditTask = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Edit series"),
        content: const Text("Do you want to edit the series?"),
        actions: <Widget>[
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: const Text("No"),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          TextButton(
            child: const Text("Yes"),
            onPressed: () {
              repeatingTasks = widget.tasks.where((task) {return task.repeatingId == widget.task.repeatingId;}).toList();
              sortTasksByDueDate(repeatingTasks);
              task = repeatingTasks.firstWhere((task) => !task.isComplete, orElse: () => widget.task);
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
  }

  if (shouldEditTask) {
    // User confirmed, navigate to edit page
    final updatedTask = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTaskPage(
          repeatingTasks: repeatingTasks,
          task: task,
          onTaskUpdated: (updatedTask) {},
          onTaskDeleted: (deleteTask) {
            widget.onTaskDeleted(deleteTask);
          },
          onTaskCreated: (newTask) { widget.onTaskCreated(newTask);}, 
        ),
      ),
    );

    if (updatedTask != null) {
      setState(() {
        widget.task.name = updatedTask.name;
      });
    }
  }
}


List<Task> sortTasksByDueDate(List<Task> tasks) {
  // Filter out tasks with empty or null due dates
  List<Task> tasksWithDueDate = tasks.where((task) => task.getDueDate() != null).toList();

  // Sort tasks by due date
  tasksWithDueDate.sort((a, b) {
    if (a.getDueDate() != null && b.getDueDate() != null) {
      // Compare TimeOfDay instances by converting them to minutes since midnight
      final int aMinutes = a.getDueDate()!.hour * 60 + a.getDueDate()!.minute;
      final int bMinutes = b.getDueDate()!.hour * 60 + b.getDueDate()!.minute;
      return aMinutes.compareTo(bMinutes);
    } else {
      return 0;
    }
  });

  // Combine tasks with due dates and tasks without due dates
  List<Task> sortedTasks = [...tasksWithDueDate, ...tasks.where((task) => task.getDueDate() == null).toList()];

  return sortedTasks;
}
}