// self_care_popup.dart

import 'package:flutter/material.dart';
import '../task/task.dart';

class SelfCarePopup extends StatelessWidget {
  final List<Task> selfCareTasks;
  final Function(Task) onTaskCreated; // Add this line

  SelfCarePopup(
      {required this.selfCareTasks,
      required this.onTaskCreated}); // Update the constructor

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "It looks like you need to practice more self-care! Would you like to add one to your todo list this week?",
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 16),
          Column(
            children: selfCareTasks.map((task) {
              return SelfCareTaskItem(
                  task: task,
                  onTaskCreated:
                      onTaskCreated); // Pass the callback to SelfCareTaskItem
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class SelfCareTaskItem extends StatelessWidget {
  final Task task;
  final Function(Task) onTaskCreated; // Add this line

  SelfCareTaskItem(
      {required this.task,
      required this.onTaskCreated}); // Update the constructor

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(task.name),
      subtitle: ElevatedButton(
        onPressed: () {
          // Call the onTaskCreated callback to add the task to the main list
          onTaskCreated(task);
          // Close the modal bottom sheet
          Navigator.of(context).pop();
        },
        child: Text("Add"),
      ),
    );
  }
}
