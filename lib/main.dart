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
import 'popup.dart';

// import task and utilities
import 'task/task.dart';
import 'task/task_list.dart';
import 'task/task_sorter.dart';
import 'task/default_tasks.dart';

// import fields
import 'fields/priority_field.dart';
import 'fields/due_date_field.dart';
import 'fields/self_care_field.dart';
import 'task/self_care_tasks.dart';
import 'self_care_popup.dart';
import 'dart:math'; // Import the dart:math library for Random

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

double overallScore = 10.0;

extension IterableExtensions<E> on Iterable<E> {
  E? get firstOrNull {
    return isEmpty ? null : first;
  }
}

GlobalKey<DueDateListViewState> dueDateListViewKey =
    GlobalKey<DueDateListViewState>();

void main() {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MaterialApp(
        home: MyApp(
          tasks: tasks,
          navigatorKey: navigatorKey,
        ),
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

class MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  GlobalKey<DueDateListViewState> dueDateListViewKey =
      GlobalKey<DueDateListViewState>();

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
        if (task.hasDueDate && task.isSelfCare) {
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
        print("recommending task");
        _showSelfCareRecommendationPopup(context);
      } else {
        print("no self care recommendation");
        print(isNewTaskSelfCare);
        print(hasSelfCareTasksForToday);
      }

      // Reload the page when a new task is created
      _reloadPage();
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

  void _handleTabChange() {
    if (_tabController.index == 1) {
      // Handle tab change to Priority tab
    } else if (_tabController.index == 0) {
      // Handle tab change to Due Date tab
      // _reloadPage();
    }
  }

  void _reloadPage() {
    setState(() {
      _tabController.index = 1; // Switch to the Priority tab
      _tabController.index = 0; // Switch back to the Due Date tab
      dueDateListViewKey.currentState?.setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
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
    showDialog(
      context: widget.navigatorKey.currentState?.overlay?.context ?? context,
      builder: (BuildContext context) {
        return CustomPopup(
          content:
              generateSelfCareRecommendationContent(context, handleTaskCreated),
        );
      },
    );
  }

  Widget generateSelfCareRecommendationContent(
      BuildContext context, Function handleTaskCreated) {
    Task recommendedTask =
        selfCareTasks[Random().nextInt(selfCareTasks.length)];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
            "You don't have any self-care tasks today! Would you like to add one?"),
        ListTile(
          title: Text(recommendedTask.name),
          subtitle: Text(recommendedTask.description),
          trailing: ElevatedButton(
            onPressed: () {
              // Handle the task creation when the "Add" button is clicked
              Navigator.pop(context); // Close the popup

              // Create a new task with the due date set to midnight of the current day
              DateTime now = DateTime.now();
              DateTime midnight = DateTime(now.year, now.month, now.day, 0, 0);
              Task newTask = Task.copyWithUniqueID(recommendedTask);
              newTask.updateTask(
                fields: [
                  DueDateField(
                      dueDateTime: midnight), // Set due date to current day
                  ...recommendedTask
                      .fields, // Add other fields from the recommended task
                ],
              );

              handleTaskCreated(newTask);
            },
            child: Text('Add'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: widget.navigatorKey,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Task List'),
          bottom: TabBar(
            controller: _tabController,
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
              controller: _tabController,
              children: [
                DueDateListView(
                  key: dueDateListViewKey,
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
    );
  }
}
