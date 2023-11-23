import 'task_field.dart';

class PriorityField extends TaskField {
  int _priority;

  PriorityField({
    required int priority,
  })  : assert(priority >= 0 && priority <= 4, 'Priority must be between 0 and 4'),
        _priority = priority,
        super(name: 'Priority', value: _priorityToString(priority));

  int get priority => _priority;

  set priority(int value) {
    assert(value >= 0 && value <= 4, 'Priority must be between 0 and 4');
    _priority = value;
    updateValue();
  }

  void updateValue() {
    super.value = _priorityToString(_priority);
  }

  static String _priorityToString(int priority) {
    switch (priority) {
      case 0:
        return 'None';
      case 1:
        return 'Low';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      case 4:
        return 'Critical';
      default:
        return 'Unknown';
    }
  }

  // Add this method
  static int _stringToPriority(String priorityString) {
    switch (priorityString.toLowerCase()) {
      case 'none':
        return 0;
      case 'low':
        return 1;
      case 'medium':
        return 2;
      case 'high':
        return 3;
      case 'critical':
        return 4;
      default:
        return 0; // Default to 'None' if the string is not recognized
    }
  }
}
