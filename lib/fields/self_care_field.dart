import '../main.dart';

class SelfCareField extends TaskField {
  String _selfCareActivity;

  SelfCareField({
    required String selfCareActivity,
  })  : _selfCareActivity = selfCareActivity,
        super(name: 'Self Care', value: selfCareActivity);

  String get selfCareActivity => _selfCareActivity;

  set selfCareActivity(String value) {
    _selfCareActivity = value;
    updateValue();
  }

  void updateValue() {
    super.value = _selfCareActivity;
  }
}
