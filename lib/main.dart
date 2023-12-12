//main.dart
//import main pages
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'task_creation_page.dart'; // Import the task_creation_page.dart file
import 'completed_tasks_page.dart'; // Import the CompletedTasksPage widget
import 'calendar_view.dart';
import 'user_progress_screen.dart';
import 'due_date_list.dart';
import 'store.dart';
import 'user_provider.dart';
import 'package:provider/provider.dart';

// import task and utilities
import 'task/task.dart';
import 'task/task_list.dart';
import 'task/task_sorter.dart';

// import fields
import 'fields/priority_field.dart';
import 'fields/due_date_field.dart';
import 'fields/self_care_field.dart';
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
        dueDateTime: DateTime(2023, 12, 16, 14, 30),
      ),
      PriorityField(priority: 2), // Medium priority
    ],
    filePaths: [
      'https://drive.google.com/file/d/1B6FtjriF8MyP0qZsXAdAxzoDPCuG4tnp/view?usp=drive_link'
    ],
  ),
  Task(
    id: '2',
    name: 'Task with a future Due Date Only',
    description: 'https://www.youtube.com/',
    parentId: '',
    fields: [
      DueDateField(dueDateTime: DateTime(2023, 12, 24, 10, 00)),
    ],
    filePaths: [],
  ),
  Task(
    id: '3',
    name: 'Task with Priority Only',
    description: 'This task has only a priority',
    parentId: '',
    fields: [
      PriorityField(priority: 3), // High priority
    ],
    filePaths: [],
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
      DueDateField(dueDateTime: DateTime(2023, 11, 18, 12, 00)),
    ],
    filePaths: [],
  ),
  Task(
    id: '6',
    name: 'Subtask 1',
    description: 'This is a subtask',
    parentId: '1',
    fields: [],
    filePaths: List.empty(),
  ),
  Task(
    id: '7',
    name: 'Subtask 2',
    description: 'This is a second subtask',
    parentId: '1',
    fields: [],
    filePaths: List.empty(),
  ),
  Task(
    id: '8',
    name: 'Repeating Task 1',
    description: 'This task repeats every day',
    parentId: '',
    fields: [
      DueDateField(
        dueDateTime: DateTime(2023, 12, 17, 14, 30),
      ),
    ],
    repeatingId: '8',
    filePaths: [],
  ),
  Task(
    id: '9',
    name: 'Repeating Task 2',
    description: 'This task repeats every day',
    parentId: '',
    fields: [
      DueDateField(
        dueDateTime: DateTime(2023, 12, 8, 14, 30),
      ),
    ],
    repeatingId: '8',
    filePaths: [],
  ),
  Task(
    id: '10',
    name: 'Repeating Task 3',
    description: 'This task repeats every day',
    parentId: '',
    fields: [
      DueDateField(
        dueDateTime: DateTime(2023, 12, 9, 14, 30),
      ),
    ],
    repeatingId: '8',
    filePaths: [],
  ),
  Task(
    id: '11',
    name: 'Repeating Task 4',
    description: 'This task repeats every day',
    parentId: '',
    fields: [
      DueDateField(
        dueDateTime: DateTime(2023, 12, 10, 14, 30),
      ),
    ],
    repeatingId: '8',
    filePaths: [],
  ),
  Task(
    id: '100',
    name: 'Completed Task 1',
    description: 'This is the 1st completed task',
    parentId: '100',
    fields: [
      DueDateField(
        dueDateTime: DateTime(2023, 12, 13, 14, 30),
      ),
    ],
    filePaths: List.empty(),
    isComplete: true,
  ),
  Task(
    id: '101',
    name: 'Completed Task 2',
    description: 'This is the 2nd completed task',
    parentId: '191',
    fields: [
      DueDateField(
        dueDateTime: DateTime(2023, 11, 17, 14, 30),
      ),
    ],
    filePaths: List.empty(),
    isComplete: true,
  ),
  Task(
    id: '102',
    name: 'Completed Task 3',
    description: 'This is the 3rd completed task',
    parentId: '102',
    fields: [
      DueDateField(
        dueDateTime: DateTime(2023, 11, 12, 14, 30),
      ),
    ],
    filePaths: List.empty(),
    isComplete: true,
  ),
];

//List<Map<String, dynamic>> progressHistory = [];
List<Map<String, dynamic>> progressHistory = [
  {
    'date': DateTime(2023, 8, 15),
    'scoreChange': -1,
  },
  {
    'date': DateTime(2023, 9, 5),
    'scoreChange': 1,
  },
  {
    'date': DateTime(2023, 9, 15),
    'scoreChange': 1,
  },
  {
    'date': DateTime(2023, 10, 16),
    'scoreChange': 1,
  },
  {
    'date': DateTime(2023, 10, 5),
    'scoreChange': -1,
  },
  {
    'date': DateTime(2023, 10, 20),
    'scoreChange': 1,
  },
  {
    'date': DateTime(2023, 11, 5),
    'scoreChange': 1,
  },
  {
    'date': DateTime(2023, 11, 12),
    'scoreChange': 1,
  },
  {
    'date': DateTime(2023, 11, 17),
    'scoreChange': 1,
  },
  {
    'date': DateTime(2023, 12, 13),
    'scoreChange': 1,
  },
];

double overallScore = 6.0;

extension IterableExtensions<E> on Iterable<E> {
  E? get firstOrNull {
    return isEmpty ? null : first;
  }
}

void main() {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MyApp(
        tasks: tasks,
        navigatorKey: navigatorKey,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final List<Task> tasks;
  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalKey<StorePageState> storePageKey;

  MyApp({
    Key? key,
    required this.tasks,
    required this.navigatorKey,
  })  : storePageKey = GlobalKey<StorePageState>(),
        super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  List<Task> incompleteTasks = [];

  // Callback function to update overallScore
  void updateOverallScore(double newScore) {
    setState(() {
      overallScore = newScore;
    });
  }

  // Callback function to handle newly created tasks
  void handleTaskCreated(Task newTask) {
    setState(() {
      if (kDebugMode) {
        print('New task created: $newTask');
      }

      tasks.add(newTask);

      newTask.printTaskDetails();

      incompleteTasks = tasks.where((task) => !task.isComplete).toList();

      final bool isNewTaskSelfCare =
          newTask.fields.any((field) => field is SelfCareField);

      final bool hasSelfCareTasksForToday = tasks.any((task) {
        if (task.hasDueDate) {
          final today = DateTime.now();
          final taskDueDate = task.getDueDate()!;
          return taskDueDate.year == today.year &&
              taskDueDate.month == today.month &&
              taskDueDate.day == today.day;
        }
        return false;
      });

      if (!isNewTaskSelfCare && !hasSelfCareTasksForToday) {
        //TODO Throws errors!
        //_showSelfCareRecommendationPopup(context);
      }
    });
  }

  void handleTaskDeleted(Task deleteTask) {
    setState(() {
      tasks.remove(deleteTask); // Remove the task from the global task list
    });
  }

  //Define the callback function to handle task updates
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

      if (kDebugMode) {
        print("Updated");
      }
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

    // Create a new self-care task
    Task selfCareTask = Task.copy(selfCareTasks[randomIndex]);

    // Set the due date of the self-care task to today
    selfCareTask.fields.add(DueDateField(
        dueDateTime: DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, 23, 59)));

    return [selfCareTask];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: widget.navigatorKey,
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
                const SizedBox(
                  height: 135, // Set the desired height for the drawer header
                  child: DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Text('Menu', style: TextStyle(fontSize: 20)),
                  ),
                ),
                ListTile(
                  title: const Text('Progress'),
                  onTap: () {
                    widget.navigatorKey.currentState?.pop(); // Close the drawer
                    widget.navigatorKey.currentState?.push(
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
                  title: const Text('Store'),
                  onTap: () {
                    // Handle menu item 2 click
                    widget.navigatorKey.currentState?.pop(); // Close the drawer
                    widget.navigatorKey.currentState?.push(
                      MaterialPageRoute(
                        builder: (context) => StorePage(
                          overallScore: overallScore,
                          updateOverallScore: updateOverallScore,
                          storePageKey:
                              widget.storePageKey, // Pass the callback function
                        ),
                      ),
                    );
                  },
                ),
                // Add more menu items as needed
              ],
            ),
          ),
          body: Stack(
            children: [
              TabBarView(
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
                ],
              ),
              // Positioned widget for the image
              Positioned(
                bottom: 16.0,
                left: 16.0,
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    // Access the selectedOwnedItem from the UserProvider
                    final StoreItem? selectedOwnedItem =
                        userProvider.selectedOwnedItem;

                    // Check if there is a selectedOwnedItem
                    if (selectedOwnedItem != null) {
                      return Container(
                        width: 56.0,
                        height: 56.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 218, 218, 218),
                        ),
                        child: Center(
                          child: Image.asset(
                            selectedOwnedItem.image,
                            width: 96.0,
                            height: 96.0,
                          ),
                        ),
                      );
                    } else {
                      // If no selectedOwnedItem, return an empty container
                      return Container();
                    }
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (widget.navigatorKey.currentState != null) {
                widget.navigatorKey.currentState!.push(
                  MaterialPageRoute(
                    builder: (context) => TaskCreationPage(
                      onTaskCreated: handleTaskCreated,
                    ),
                  ),
                );
              }
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
