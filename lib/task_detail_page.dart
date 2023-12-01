import 'package:flutter/material.dart';
import 'task_edit_page.dart';
import 'package:file_picker/file_picker.dart';

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

  TaskDetailPage({
    Key? key,
    required this.task,
    required this.subtasks,
    required this.onTaskUpdated,
    required this.onTaskCreated,
    required this.onTaskDeleted,
    required this.onUpdateDueDateTime,
  }) : super(key: key);

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
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
          if (widget.task.fields.isNotEmpty)
            _buildFieldContainer(),
          if (widget.subtasks.isNotEmpty)
            Column(
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
            ),
          if (attachedFiles.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Attached Files:'),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: attachedFiles.length,
                  itemBuilder: (context, index) {
                    final filePath = attachedFiles[index];
                    return ListTile(
                      title: InkWell(
                        child: Text(filePath.isEmpty
                            ? 'No attached files'
                            : filePath.split('/').last),
                        onTap: () {
                          _openFile(filePath);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _openFile(String filePath) {
    print('Opening file: $filePath');
    // Implement logic to open the file using appropriate plugins
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String filePath = result.files.single.path!;
      setState(() {
        attachedFiles.add(filePath);
      });
    }
  }

  Widget _buildDueDateField(DueDateField field) {
    return ListTile(
      title: Text('Due Date'),
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
      title: Text('Priority'),
      subtitle: Text(priorityField.value),
    );
  }

  Widget _buildSelfCareField(SelfCareField selfCareField) {
    return ListTile(
      title: Text('Self Care'),
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
            if (field is DueDateField) {
              return _buildDueDateField(field);
            } else if (field is PriorityField) {
              return _buildPriorityField(field);
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
}
