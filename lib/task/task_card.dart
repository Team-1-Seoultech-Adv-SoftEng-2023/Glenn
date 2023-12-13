import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'task.dart';
import '../main.dart';
import '../task_detail_page.dart';

import '../fields/due_date_field.dart';
import '../popup.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final Function(DueDateField) onUpdateDueDateTime;
  final Function(Task, bool) updateTaskCompletionStatus;

  final List<Task> allTasks;
  final Function(Task) onTaskUpdated; // Add the callback
  final Function(Task) onTaskCreated;
  final Function(Task) onTaskDeleted; // Add the callback

  const TaskCard(
      {super.key,
      required this.task,
      required this.allTasks,
      required this.onTaskUpdated,
      required this.onTaskCreated,
      required this.onTaskDeleted,
      required this.onUpdateDueDateTime,
      this.updateTaskCompletionStatus = _dummyFunction});

  @override
  TaskCardState createState() => TaskCardState();
}

void _dummyFunction(Task task, bool isComplete) {
  // This is a placeholder function that does nothing.
}

class TaskCardState extends State<TaskCard> {
  @override
  void initState() {
    super.initState();
  }

  void _showCongratulationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomPopup(
          content: Column(
            children: [
              const Text('🎉 Congratulations! 🎉'),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                      'You completed the task on time. Keep up the good work!'),
                  const SizedBox(height: 8),
                  Text('Your score is now: $overallScore'),
                ],
              ),
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMotivationalSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'You missed the deadline, but don\'t give up! Keep pushing forward.'),
            const SizedBox(height: 8),
            Text('Your score is now: $overallScore'),
          ],
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  bool _isCompletedOnTime(Task task) {
    // Get the current date and time
    DateTime now = DateTime.now();

    // Get the due date and time of the task
    DateTime dueDate = task.getDueDate() ?? DateTime.now();

    // Check if the task is completed before the due date
    return now.isBefore(dueDate.add(const Duration(days: 1)));
  }

  Future<void> _showConfirmationDialog(BuildContext context, bool value) async {
    bool shouldUpdateTask = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomPopup(
          content: Column(
            children: [
              const Text("Do you want to mark this task as complete?"),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: const Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                    child: const Text("Confirm"),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              )
            ],
          ),
        );
      },
    );

    if (shouldUpdateTask) {
      widget.updateTaskCompletionStatus(widget.task, value);

      if (widget.task.isComplete) {
        //incompleteTasks.removeWhere((element) => element == task);

        // Check if the task was completed on time
        bool completedOnTime = _isCompletedOnTime(widget.task);

        // Add entry to progress history
        DateTime completionDate = DateTime.now();
        int scoreChange = completedOnTime ? 1 : -1;

        progressHistory.add({
          'date': completionDate,
          'scoreChange': scoreChange,
        });

        if (kDebugMode) {
          print(progressHistory);
        }

        // Update overall score
        overallScore += scoreChange;

        // Update task's completion on time status
        widget.task.isCompletedOnTime = completedOnTime;
      }

      // Check if the task was completed on time
      bool completedOnTime = widget.task.isCompletedOnTime;

      // Show congratulatory or motivational message
      if (completedOnTime) {
        _showCongratulationsDialog(context);
      } else {
        _showMotivationalSnackbar(context);
      }
    }
  }

  Widget _buildPriorityBlock(int priority) {
    Color blockColor;
    String priorityText;

    switch (priority) {
      case 0:
        blockColor = Colors.blue;
        priorityText = 'None';
        break;
      case 1:
        blockColor = Colors.green;
        priorityText = 'Low';
        break;
      case 2:
        blockColor = Colors.yellow;
        priorityText = 'Medium';
        break;
      case 3:
        blockColor = Colors.orange;
        priorityText = 'High';
        break;
      case 4:
        blockColor = Colors.red;
        priorityText = 'Critical';
        break;
      default:
        blockColor = Colors.grey;
        priorityText = 'Unknown';
    }

    return Container(
      margin: const EdgeInsets.only(top: 8, right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: blockColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        priorityText,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

//...

//...

  @override
  Widget build(BuildContext context) {
    // Function to find child tasks for the current task
    List<Task> getChildTasks() {
      return widget.allTasks
          .where((t) => t.parentId == widget.task.id)
          .toList();
    }

    bool isParentTaskComplete = widget.task.isComplete;

    return Card(
      margin: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () async {
          // Pass the callback function to TaskDetailPage
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TaskDetailPage(
                tasks: widget.allTasks,
                task: widget.task,
                onTaskUpdated: (updatedTask) {
                  // Handle the updated task here
                  // Optionally, you can update the UI or perform other actions.
                },
                onTaskDeleted: widget.onTaskDeleted,
                onTaskCreated: widget.onTaskCreated,
                subtasks: getChildTasks(),
                onUpdateDueDateTime: widget.onUpdateDueDateTime,
              ),
            ),
          );
        },
        child: Stack(
          children: [
            // Title and subtitle in a column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display task name and checkbox in a row
                Row(
                  children: [
                    // Conditionally render the checkbox based on the parent task's completion status
                    if (!isParentTaskComplete)
                      Checkbox(
                        value: widget.task.isComplete,
                        onChanged: (value) {
                          _showConfirmationDialog(context, value!);
                        },
                      ),
                    Flexible(
                      child: ListTile(
                        title: Text(widget.task.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.task.fields.isNotEmpty &&
                                widget.task.fields
                                    .any((field) => field is DueDateField))
                              // Display the Due Date in a more concise format
                              Row(
                                children: [
                                  const Text('Due: '),
                                  Text(
                                      '${formatDate((widget.task.fields.firstWhere((field) => field is DueDateField) as DueDateField).dueDate)}'),
                                  const SizedBox(width: 8),
                                  Text(
                                      '${formatTime((widget.task.fields.firstWhere((field) => field is DueDateField) as DueDateField).dueTime)}'),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Display child tasks under the main task
                if (getChildTasks().isNotEmpty && !isParentTaskComplete)
                  Column(
                    children: <Widget>[
                      const Text('Sub Tasks:'),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: getChildTasks().length,
                        itemBuilder: (context, index) {
                          return TaskCard(
                            task: getChildTasks()[index],
                            allTasks: widget.allTasks,
                            onTaskUpdated: (updatedTask) {
                              // Handle the updated task here
                              // Optionally, you can update the UI or perform other actions.
                            },
                            onTaskDeleted: widget.onTaskDeleted,
                            onTaskCreated: widget.onTaskCreated,
                            onUpdateDueDateTime: widget.onUpdateDueDateTime,
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),

            Positioned(
              top: 0,
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Display priority block
                  if (widget.task.hasPriority)
                    _buildPriorityBlock(widget.task.getPriority()!),

                  // Display the symbol if repeatingId is not an empty string
                  if (widget.task.repeatingId.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(
                          right: 16, top: 8), // Add some left padding
                      child: Icon(
                        Icons.repeat, // You can use a different icon as needed
                        size: 20, // Set the size of the icon
                        color: Colors.grey, // Set the color of the icon
                      ),
                    ),
                  // Display the symbol if is self care is not an empty string
                  if (widget.task.isSelfCare)
                    const Padding(
                      padding: const EdgeInsets.only(
                          right: 16, top: 8), // Add some left padding
                      child: Icon(
                        Icons
                            .wb_sunny, // You can use a different icon as needed
                        size: 20, // Set the size of the icon
                        color: Colors.grey, // Set the color of the icon
                      ),
                    ),
                    if (widget.task.isComplete)
                    const Padding(
                      padding: const EdgeInsets.only(
                          right: 16, top: 30), // Add some left padding
                      child: Icon(
                        Icons
                            .check_box, // You can use a different icon as needed
                        size: 20, // Set the size of the icon
                        color: Color.fromARGB(255, 125, 192, 109), // Set the color of the icon
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
