import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'task_creation_page.dart';
import 'task/task.dart';
import 'package:permission_handler/permission_handler.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;
  final Function(Task) onTaskUpdated;
  final Function(Task) onTaskCreated;
  final Function(Task) onTaskDeleted;

  const EditTaskPage({
    Key? key,
    required this.task,
    required this.onTaskUpdated,
    required this.onTaskCreated,
    required this.onTaskDeleted,
  }) : super(key: key);

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.task.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Function to handle task deletion
  void _deleteTask() {
    // Call the onTaskDeleted callback to notify the parent widget about the deletion
    widget.onTaskDeleted(widget.task);
    // Navigate back to the previous screen
    Navigator.pop(context);
  }

 // Function to handle file attachment
void _attachFile() async {
  // Check storage permission before proceeding
  var status = await Permission.storage.status;

  if (status.isDenied) {
    // Here just ask for the permission for the first time
    await Permission.storage.request();

    // Check again and go to app settings if permission is still denied
    if (await Permission.storage.isDenied) {
      await openAppSettings();
      return; // Return to avoid proceeding with file selection
    }
  } else if (status.isPermanentlyDenied) {
    // Open app settings for the user to manually enable permission
    await openAppSettings();
    return; // Return to avoid proceeding with file selection
  }

  // Permission is granted, proceed with file selection
  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result != null && mounted) {
    String filePath = result.files.single.path!;
    // Add logic to handle the file path as needed
    // For example, you can update the task's file paths list
    setState(() {
      widget.task.filePaths.add(filePath);
    });
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'add_sub_task') {
                // Navigate to the TaskCreationPage and assign the parent ID
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TaskCreationPage(
                      onTaskCreated: widget.onTaskCreated,
                      parentId: widget.task.id,
                    ),
                  ),
                );
              } else if (value == 'attach_file') {
                // Call the function to handle file attachment
                _attachFile();
              } else if (value == 'delete_task') {
                // Call the function to handle task deletion
                _deleteTask();
              }
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'add_sub_task',
                  child: Text('Add Sub-Task'),
                ),
                const PopupMenuItem<String>(
                  value: 'attach_file',
                  child: Text('Attach File'),
                ),
                const PopupMenuItem<String>(
                  value: 'delete_task',
                  child: Text('Delete'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Task Name'),
            ),
            ElevatedButton(
              onPressed: () {
                // Update the task's name when the button is pressed
                setState(() {
                  widget.task.name = _nameController.text;
                });
                // Return the updated task to the previous page
                Navigator.pop(context, widget.task);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
