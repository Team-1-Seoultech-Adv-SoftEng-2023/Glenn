//main.dart
//import main pages
import 'package:flutter/material.dart';
import 'task_detail_page.dart'; // Import the task_detail_page.dart file
import 'task_creation_page.dart'; // Import the task_creation_page.dart file
import 'completed_tasks_page.dart'; // Import the CompletedTasksPage widget
import 'calendar_view.dart';
import 'user_progress_screen.dart';
import 'due_date_list.dart';

// import task and utilities
import 'task/task.dart';
import 'task/task_list.dart';
import 'task/task_sorter.dart';
import 'task/collapsible_task_list.dart';

// import fields
import 'fields/task_field.dart';
import 'fields/priority_field.dart';
import 'fields/due_date_field.dart';
import 'fields/self_care_field.dart';
import 'task/task_sorter.dart';
import 'task/self_care_tasks.dart';
import 'self_care_popup.dart';
import 'dart:math'; // Import the dart:math library for Random

// Define the tasks list with sample data
final List<Task> tasks = [
  Task(
    id: '1',
    name: 'Task with Due Date and Priority',
    description: 'This task has both due date and priority',
    parentId: '',
    fields: [
      DueDateField(
        dueDate: DateTime(2023, 11, 22),
        dueTime: TimeOfDay(hour: 14, minute: 30),
      ),
      PriorityField(priority: 2), // Medium priority
    ],
  ),
  Task(
    id: '2',
    name: 'Task with Due Date Only',
    description: 'https://www.youtube.com/',
    parentId: '',
    fields: [
      DueDateField(
        dueDate: DateTime(2023, 11, 24),
        dueTime: TimeOfDay(hour: 10, minute: 0),
      ),
    ],
  ),
  Task(
    id: '3',
    name: 'Task with Priority Only',
    description: 'This task has only a priority',
    parentId: '',
    fields: [
      PriorityField(priority: 3), // High priority
    ],
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
      DueDateField(
        dueDate: DateTime(2023, 11, 10),
        dueTime: const TimeOfDay(hour: 12, minute: 0),
      ),
    ],
  ),
];

List<Map<String, dynamic>> progressHistory = [];
double overallScore = 0.0;

extension IterableExtensions<E> on Iterable<E> {
  E? get firstOrNull {
    return isEmpty ? null : first;
  }
}

void main() {
  runApp(MaterialApp(
    home: MyApp(tasks: tasks),
  ));
}

class MyApp extends StatefulWidget {
  final List<Task> tasks;

  const MyApp({super.key, required this.tasks});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  List<Task> incompleteTasks = [];

  // Callback function to handle newly created tasks
  void handleTaskCreated(Task newTask) {
    setState(() {
      // Handle the result from the TaskCreationPage if needed
      if (newTask != null) {
        print('New task created: $newTask');

        // Refresh the main page after creating a new task
        Navigator.pop(context); // Pop the screen to refresh
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyApp(tasks: tasks),
          ),
        );
      }
      tasks.add(newTask); // Add the newly created task to the global tasks list

      // Check if the newly created task is a self-care task
      final bool isNewTaskSelfCare =
          newTask.fields.any((field) => field is SelfCareField);

      // Check if there are existing self-care tasks for the current day
      final bool hasSelfCareTasksForToday = tasks.any((task) {
        // Filter tasks with a due date for today
        if (task.hasDueDate) {
          final today = DateTime.now();
          final taskDueDate = task.getDueDate()!;
          return taskDueDate.year == today.year &&
              taskDueDate.month == today.month &&
              taskDueDate.day == today.day;
        }
        return false;
      });

      // If the new task is a self-care task and there are no existing self-care tasks for today, show the popup
      if (isNewTaskSelfCare && !hasSelfCareTasksForToday) {
        _showSelfCareRecommendationPopup(context);
      }
    });
  }

  void handleTaskDeleted(Task deleteTask) {
    setState(() {
      tasks.remove(deleteTask); // Remove the task from the global task list
    });
  }

  // Define the callback function to handle task updates
  void handleTaskUpdated(Task updatedTask) {
    setState(() {
      // Update the task in the tasks list
      final index = tasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        tasks[index] = updatedTask;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Filter the initial list of tasks to show only incomplete tasks
    incompleteTasks = widget.tasks.where((task) => !task.isComplete).toList();
  }

  void _updateTaskCompletionStatus(Task task, bool isComplete) {
    setState(() {
      task.isComplete = isComplete;

      print("Updated");
    });
  }

  void _showSelfCareRecommendationPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SelfCarePopup(
          selfCareTasks: generateSelfCareTasks(),
          onTaskCreated:
              handleTaskCreated, // Pass the handleTaskCreated function
        );
      },
    );
  }

  List<Task> generateSelfCareTasks() {
    final Random random = Random();
    final int randomIndex = random.nextInt(selfCareTasks.length);
    return [selfCareTasks[randomIndex]];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Task List'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Due Date'),
                Tab(text: 'Priority'),
                Tab(text: 'Calendar'),
                Tab(text: 'Completed'),
                Tab(text: 'Progress')
              ],
            ),
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Text('Menu'),
                ),
                ListTile(
                  title: Text('User Progress'),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProgressScreen(
                          overallScore: overallScore,
                          progressHistory: progressHistory,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text('Item 2'),
                  onTap: () {
                    // Handle menu item 2 click
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                // Add more menu items as needed
              ],
            ),
          ),
          body: TabBarView(
            children: [
              DueDateListView(
                tasks: widget.tasks,
                updateTaskCompletionStatus: _updateTaskCompletionStatus,
                onTaskUpdated: handleTaskUpdated,
                onTaskCreated: handleTaskCreated,
                onTaskDeleted: handleTaskDeleted,
              ),

              TaskList(
                tasks: TaskSorter.sortByPriority(widget.tasks),
                updateTaskCompletionStatus: _updateTaskCompletionStatus,
                onTaskUpdated: (updatedTask) {
                  // Handle the updated task here
                  // Optionally, you can update the UI or perform other actions.
                },
                onTaskCreated: handleTaskCreated,
                onTaskDeleted: handleTaskDeleted,
              ),
              CalendarView(tasks: widget.tasks), // Added CalendarView
              CompletedTasksPage(
                tasks: widget.tasks,
                onTaskCreated: handleTaskCreated,
                onTaskUpdated: handleTaskUpdated,
                onTaskDeleted: handleTaskDeleted,
              ),
              UserProgressScreen(
                  overallScore: overallScore, progressHistory: progressHistory),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              // Navigate to the TaskCreationPage
              final newTask = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskCreationPage(
                    onTaskCreated: handleTaskCreated,
                  ),
                ),
              );

              // Handle the result from the TaskCreationPage if needed
              if (newTask != null) {
                print('New task created: $newTask');
              }
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
