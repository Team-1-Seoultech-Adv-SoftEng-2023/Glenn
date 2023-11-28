import 'task_field.dart';

enum RepeatPeriod { Daily, Weekly, Monthly, Yearly, Custom }

class RepeatingTaskField extends TaskField {
  RepeatPeriod _repeatPeriod;
  int _customRepeatDays;

  RepeatingTaskField({
    required RepeatPeriod repeatPeriod,
    int customRepeatDays = 1,
  })  : _repeatPeriod = repeatPeriod,
        _customRepeatDays = customRepeatDays,
        super(name: 'Repeating Task', value: '') {
    updateValue();
  }

  RepeatPeriod get repeatPeriod => _repeatPeriod;
  set repeatPeriod(RepeatPeriod value) {
    _repeatPeriod = value;
    updateValue();
  }

  int get customRepeatDays => _customRepeatDays;
  set customRepeatDays(int value) {
    _customRepeatDays = value;
    updateValue();
  }

  void updateValue() {
    super.value = _formatRepeatPeriod(_repeatPeriod, _customRepeatDays);
  }

  String _formatRepeatPeriod(RepeatPeriod repeatPeriod, int customRepeatDays) {
    switch (repeatPeriod) {
      case RepeatPeriod.Daily:
        return 'Daily';
      case RepeatPeriod.Weekly:
        return 'Weekly';
      case RepeatPeriod.Monthly:
        return 'Monthly';
      case RepeatPeriod.Yearly:
        return 'Yearly';
      case RepeatPeriod.Custom:
        return 'Every $_customRepeatDays days';
      default:
        return 'Unknown';
    }
  }
}

