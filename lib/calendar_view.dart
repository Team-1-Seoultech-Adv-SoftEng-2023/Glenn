import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'task/task.dart';
import 'fields/due_date_field.dart';

class CalendarView extends StatefulWidget {
  final List<Task> tasks;

  const CalendarView({super.key, required this.tasks});

  @override
  CalendarViewState createState() => CalendarViewState();
}

class CalendarViewState extends State<CalendarView> {
  late DateTime _selectedDay;
  Map<DateTime, List<Task>> _events = {};
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _prepareEvents();
  }

  void _prepareEvents() {
    _events = {};

    for (final task in widget.tasks) {
      if (task.fields.isNotEmpty && task.fields.first is DueDateField) {
        final dueDate = (task.fields.first as DueDateField).dueDate;
        final formattedDueDate =
            DateTime(dueDate.year, dueDate.month, dueDate.day);

        // Check if the task is complete
        if (task.isComplete != true) {
          _events[formattedDueDate] = _events[formattedDueDate] ?? [];
          _events[formattedDueDate]!.add(task);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Align to the top right
          children: [
            const Spacer(), // Add a Spacer to push the following widgets to the right
            // The Select View text and DropdownButton
            Row(
              children: [
                const Text('Select View:'),
                const SizedBox(width: 10),
                DropdownButton<CalendarFormat>(
                  value: _calendarFormat,
                  items: const [
                    DropdownMenuItem(
                      value: CalendarFormat.month,
                      child: Text('Month'),
                    ),
                    DropdownMenuItem(
                      value: CalendarFormat.week,
                      child: Text('Week'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _calendarFormat = value!;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        TableCalendar(
          firstDay: DateTime.utc(2023, 1, 1),
          lastDay: DateTime.utc(2025, 12, 31),
          focusedDay: _selectedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
          availableCalendarFormats: const {
            CalendarFormat.month: 'Month',
            CalendarFormat.week: 'Week',
          },
          eventLoader: _getEventsForDay,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false, // Hide the two-weeks/format button
            titleCentered: true,
          ),
          calendarStyle: const CalendarStyle(
            weekendTextStyle:
                TextStyle(color: Colors.red), // Set the color for weekend days
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekendStyle: TextStyle(
                color:
                    Colors.red), // Set the color for weekend days in the header
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder:
                (BuildContext context, DateTime date, List<dynamic> events) {
              return Stack(
                children: [
                  if (events.isNotEmpty)
                    Positioned(
                      right: 1,
                      bottom: 1,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 68, 255, 77),
                        ),
                        width: 20.0,
                        height: 20.0,
                        child: Center(
                          child: Text(
                            '${events.length}',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 150, 17, 17),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              // Set the focusedDay to the selected day
              //focusedDay = selectedDay;
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
        final taskTime = _formatTime((task.fields.first as DueDateField)
            .dueTime); // Modify this based on your data structure;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text('${index + 1}. ${task.name}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8), // Space before description
                Text(task.description),
                const SizedBox(height: 8), // Additional space
                Text('Time: $taskTime'),
              ],
            ),
            // Add more details as needed
          ),
        );
      },
    );
  }

  List<Task> _getEventsForDay(DateTime day) {
    var newday = DateTime(day.year, day.month, day.day);
    return _events[newday] ?? [];
  }
}

String _formatTime(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
