import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'task_edit_page.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

import 'task/task.dart';
import 'fields/due_date_field.dart';
import 'fields/priority_field.dart';
import 'fields/self_care_field.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;
  final List<Task> subtasks;
  final Function(Task) onTaskUpdated;
  final Function(Task) onTaskCreated;
  final Function(Task) onTaskDeleted;
  final Function(DueDateField) onUpdateDueDateTime;

  const TaskDetailPage({
    Key? key,
    required this.task,
    required this.subtasks,
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
              final updatedTask = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditTaskPage(
                    task: widget.task,
                    onTaskUpdated: (updatedTask) {},
                    onTaskDeleted: (deleteTask) {
                      widget.onTaskDeleted(deleteTask);
                    },
                    onTaskCreated: (newTask) {
                      widget.onTaskCreated(newTask);
                    },
                  ),
                ),
              );
              if (updatedTask != null) {
                setState(() {
                  widget.task.name = updatedTask.name;
                });
              }
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
          _buildAttachedFilesSection(),
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
        ],
      ),
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

Widget _buildAttachedFilesSection() {
  // Show attached files only if there are files
  if (attachedFiles.isEmpty) {
    return const ListTile(
      title: Text('No attached files'),
    );
  } else {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Attached Files:'),
        const SizedBox(height: 8), // Add space for separation
        ListView.builder(
          shrinkWrap: true,
          itemCount: attachedFiles.length,
          itemBuilder: (context, index) {
            final filePath = attachedFiles[index];
            return ListTile(
              title: InkWell(
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
              ),
            );
          },
        ),
      ],
    );
  }
}


}