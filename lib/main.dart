import 'package:flutter/material.dart';
import 'task_detail_page.dart'; // Import the task_detail_page.dart file
import 'task_creation_page.dart'; // Import the task_creation_page.dart file
import 'completed_tasks_page.dart'; // Import the CompletedTasksPage widget
import 'calendar_view.dart';
import 'user_progress_screen.dart';

// import task and utilities
import 'task/task.dart';
import 'task/task_list.dart';
import 'task/task_sorter.dart';

// import fields
import 'fields/task_field.dart';
import 'fields/priority_field.dart';
import 'fields/due_date_field.dart';

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
    description: 'This task has only a due date',
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
  runApp(MyApp(tasks: tasks));
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
      tasks.add(newTask); // Add the newly created task to the global tasks list
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Task List'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Due Date'),
                Tab(text: 'Priority'),
                Tab(text: 'Calendar'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  height: 135, // Set the desired height for the drawer header
                  child: DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Text('Menu', style: TextStyle(fontSize: 20)),
                  ),
                ),
                ListTile(
                  title: Text('Progress'),
                  onTap: () {
                    navigatorKey.currentState?.pop(); // Close the drawer
                    navigatorKey.currentState?.push(
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
                  title: Text('Store'),
                  onTap: () {
                    // Handle menu item 2 click
                    navigatorKey.currentState?.pop(); // Close the drawer
                  },
                ),
                // Add more menu items as needed
              ],
            ),
          ),
          body: TabBarView(
            children: [
              TaskList(
                tasks: TaskSorter.sortByDueDate(widget.tasks),
                updateTaskCompletionStatus: _updateTaskCompletionStatus,
                onTaskUpdated: (updatedTask) {
                  // Handle the updated task here
                  // Optionally, you can update the UI or perform other actions.
                },
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
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              // Navigate to the TaskCreationPage and pass the callback function
              final newTask = await navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (context) =>
                      TaskCreationPage(onTaskCreated: handleTaskCreated),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
