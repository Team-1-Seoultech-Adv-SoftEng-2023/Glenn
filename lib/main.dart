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

List<Map<String, dynamic>> progressHistory = [];
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
    MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: MyApp(
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

  // Function to reload the page
  void _reloadPage() {
    final context = widget.navigatorKey.currentState?.overlay?.context;
    if (context != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MyApp(
            tasks: tasks,
            navigatorKey: widget.navigatorKey,
          ),
        ),
      );
      DefaultTabController.of(context)
          ?.animateTo(1); // Switch to the priority tab
      DefaultTabController.of(context)
          ?.animateTo(0); // Switch back to the original tab
      dueDateListViewKey.currentState?.setState(() {});
    }
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
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomPopup(
        content: generateSelfCareRecommendationContent(context, handleTaskCreated),
      );
    },
  );
}


Widget generateSelfCareRecommendationContent(BuildContext context, Function handleTaskCreated) {
    Task recommendedTask = selfCareTasks[0]; // You can customize how to choose the recommended task

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("You don't have any self-care tasks today! Would you like to add one?"),
        ListTile(
          title: Text(recommendedTask.name),
          subtitle: Text(recommendedTask.description),
          trailing: ElevatedButton(
            onPressed: () {
              // Handle the task creation when the "Add" button is clicked
              handleTaskCreated(recommendedTask);
              Navigator.pop(context); // Close the popup
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
        body: TabBarView(
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
