import '../main.dart';

class TaskSorter {
  static List<Task> sortByDueDate(List<Task> tasks) {
    return tasks
        .where((task) => !task.isComplete && task.hasDueDate)
        .toList()
          ..sort((a, b) {
            final aDueDate = a.getDueDate();
            final bDueDate = b.getDueDate();

            if (aDueDate != null && bDueDate != null) {
              return aDueDate.compareTo(bDueDate);
            } else if (aDueDate != null) {
              return -1; // b has no due date, so a comes first
            } else if (bDueDate != null) {
              return 1; // a has no due date, so b comes first
            } else {
              return 0; // Both have no due date
            }
          });
  }


  static List<Task> sortByPriority(List<Task> tasks) {
    return tasks
        .where((task) => !task.isComplete && task.hasPriority)
        .toList()
          ..sort((a, b) {
            final aPriority = a.getPriority();
            final bPriority = b.getPriority();

            if (aPriority != null && bPriority != null) {
              return bPriority.compareTo(aPriority);
            } else if (aPriority != null) {
              return -1; // b has no priority, so a comes first
            } else if (bPriority != null) {
              return 1; // a has no priority, so b comes first
            } else {
              return 0; // Both have no priority
            }
          });
  }

  static List<Task> getIncompleteTasks(List<Task> tasks) {
    return tasks.where((task) => !task.isComplete).toList();
  }
}
