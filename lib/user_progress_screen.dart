import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class UserProgressScreen extends StatefulWidget {
  final double overallScore;
  final List<Map<String, dynamic>> progressHistory;

  UserProgressScreen({
    required this.overallScore,
    required this.progressHistory,
  });

  @override
  _UserProgressScreenState createState() => _UserProgressScreenState();
}

class _UserProgressScreenState extends State<UserProgressScreen> {
  String selectedInterval = 'Week'; // Default interval

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Progress'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Overall Score: ${widget.overallScore}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Progress History',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedInterval,
              onChanged: (value) {
                setState(() {
                  selectedInterval = value!;
                });
              },
              items: ['Week', 'Month']
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
            ),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  minY: _calculateMinY(),
                  maxY: _calculateMaxY(),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 30,
                    )),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Text(_getXAxisLabel(value.toInt()));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: List.generate(
                    _getFilteredData().length,
                    (index) {
                      final data = _getFilteredData()[index];
                      final date = data['date'];
                      final xValue = _getXValue(date).toInt();

                      return BarChartGroupData(
                        x: xValue, // Convert xValue to double
                        barRods: [
                          BarChartRodData(
                            toY: data['scoreChange'].toDouble(),
                            color: data['scoreChange'] >= 0
                                ? Colors.blue
                                : Colors.red,
                            width: 16,
                          ),
                        ],
                      );
                    },
                  ),
                  groupsSpace: 10, // Adjust this value as needed
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: const Color.fromARGB(255, 237, 238, 240),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getXValue(DateTime date) {
    if (selectedInterval == 'Week') {
      return date.weekday.toDouble();
    } else if (selectedInterval == 'Month') {
      return date.month.toDouble();
    }
    return 0; // Default value
  }

  String _getXAxisLabel(int value) {
    print(value);
    if (selectedInterval == 'Week') {
      return _getDayLabel(value - 1);
    } else if (selectedInterval == 'Month') {
      return _getMonthLabel(value - 1);
    }
    return value.toString();
  }

  String _getDayLabel(int value) {
    //DateTime date = DateTime.now().subtract(Duration(days: value - 1));
    final List<String> dayData = [
      "Mon",
      "Tue",
      "Wed",
      "Thur",
      "Fri",
      "Sat",
      "Sun"
    ];

    return dayData[value];
    //return DateFormat('E').format(date);
  }

  String _getMonthLabel(int value) {
    final List<String> monthData = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "June",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return monthData[value];
    //return DateFormat('MMM').format(DateTime(2023, value, 1));
  }

  double _calculateMinY() {
    if (_getFilteredData().isEmpty) {
      return 0.0; // Default value when there is no completed task
    }

    int minScore = _getFilteredData()
        .map<int>((entry) => entry['scoreChange'])
        .reduce((min, score) => min < score ? min : score);

    // Offset negative values by -3
    return minScore >= 0 ? 0.0 : minScore.toDouble() - 1;
  }

  double _calculateMaxY() {
    if (widget.progressHistory.isEmpty) {
      return 10.0; // Default value when there is no completed task
    }

    int maxScore = widget.progressHistory
        .map<int>((entry) => entry['scoreChange'])
        .reduce((max, score) => max > score ? max : score);

    return maxScore.toDouble() + 3;
  }

  List<Map<String, dynamic>> _getFilteredData() {
    final currentDate = DateTime.now();
    List<Map<String, dynamic>> result;

    if (selectedInterval == 'Week') {
      // Calculate the start and end dates for the current week
      final startOfWeek =
          currentDate.subtract(Duration(days: currentDate.weekday - 1));
      final endOfWeek = currentDate
          .add(Duration(days: DateTime.sunday - currentDate.weekday + 1));

      final numberOfDays = 7;

      result = List.generate(numberOfDays, (index) {
        final currentDay = startOfWeek.add(Duration(days: index));
        return {
          'date': currentDay,
          'scoreChange': _groupAndCalculateDailyScores(numberOfDays)
              .where((entry) => entry['date'].day == currentDay.day)
              .map<int>((entry) => entry['scoreChange'])
              .fold(0, (previous, score) => previous + score),
        };
      }).toList();
    } else if (selectedInterval == 'Month') {
      // Filter tasks for each month in the current year
      result = List.generate(12, (index) {
        final startOfMonth = DateTime(currentDate.year, index + 1, 1);

        return {
          'date': startOfMonth,
          'scoreChange': _groupAndCalculateMonthlyScores(currentDate.year)
              .where((entry) => entry['date'].month == index + 1)
              .map<int>((entry) => entry['scoreChange'])
              .fold(0, (previous, score) => previous + score),
        };
      });
    } else {
      result = widget.progressHistory;
    }

    return result;
  }

  List<Map<String, dynamic>> _groupAndCalculateDailyScores(int days) {
    final currentDate = DateTime.now();
    final filteredData = widget.progressHistory
        .where((entry) => currentDate.difference(entry['date']).inDays <= days)
        .toList();

    final groupedData = <DateTime, num>{};
    for (var entry in filteredData) {
      final date = entry['date'];
      final truncatedDate = DateTime(date.year, date.month, date.day);
      groupedData[truncatedDate] =
          (groupedData[truncatedDate] ?? 0) + entry['scoreChange'];
    }

    final result = <Map<String, dynamic>>[];
    for (var entry in groupedData.entries) {
      result.add({
        'date': entry.key,
        'scoreChange': entry.value,
      });
    }

    return result;
  }

  List<Map<String, dynamic>> _groupAndCalculateMonthlyScores(int year) {
    final currentDate = DateTime.now();
    final filteredData = widget.progressHistory
        .where((entry) => currentDate.difference(entry['date']).inDays <= 365)
        .toList();

    final groupedData = <DateTime, num>{};
    for (var entry in filteredData) {
      final date = entry['date'];
      final truncatedDate = DateTime(date.year, date.month);
      groupedData[truncatedDate] =
          (groupedData[truncatedDate] ?? 0) + entry['scoreChange'];
    }

    final result = <Map<String, dynamic>>[];
    for (var entry in groupedData.entries) {
      result.add({
        'date': entry.key,
        'scoreChange': entry.value,
      });
    }

    return result;
  }
}
