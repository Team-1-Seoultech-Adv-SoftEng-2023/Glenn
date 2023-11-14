import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'main.dart';

class CalendarView extends StatefulWidget {
  final List<Task> tasks;

  CalendarView({required this.tasks});

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _selectedDay;
  Map<DateTime, List<Task>> _events = {};

  @override
  void initState() {
    super.initState();

    _selectedDay = DateTime.now();

    // Prepare the events for the calendar
    _prepareEvents();
  }

  void _prepareEvents() {
    _events = {};

    for (final task in widget.tasks) {
      if (task.fields.isNotEmpty && task.fields.first is DueDateField) {
        final dueDate = (task.fields.first as DueDateField).dueDate;
        _events[dueDate] = _events[dueDate] ?? [];
        _events[dueDate]!.add(task);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2023, 1, 1),
          lastDay: DateTime.utc(2023, 12, 31),
          focusedDay: _selectedDay,
          calendarFormat: CalendarFormat.month,
          eventLoader: _getEventsForDay,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
            });
          },
        ),
        Expanded(
          child: _buildTaskList(),
        ),
      ],
    );
  }

  Widget _buildTaskList() {
    final tasksForSelectedDay = _getEventsForDay(_selectedDay);

    return ListView.builder(
      itemCount: tasksForSelectedDay.length,
      itemBuilder: (context, index) {
        final task = tasksForSelectedDay[index];
        return ListTile(
          title: Text(task.name),
          subtitle: Text(task.description),
          // Add more details as needed
        );
      },
    );
  }

  List<Task> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }
}
