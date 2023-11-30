import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'main.dart';

class UserProgressScreen extends StatefulWidget {
  final double overallScore;
  final List<Map<String, dynamic>> progressHistory;

  const UserProgressScreen({super.key, 
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
        title: const Text('User Progress'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Overall Score: $overallScore',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Progress History',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
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
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: _calculateMaxX(),
                  minY: _calculateMinY(),
                  maxY: _calculateMaxY(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        _getFilteredData().length,
                        (index) {
                          final data = _getFilteredData()[index];
                          final date = data['date'];
                          final xValue = _getXValue(date) - 1;
                          return FlSpot(
                            xValue,
                            data['scoreChange'].toDouble(),
                          );
                        },
                      ),
                      isCurved: false,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
    if (selectedInterval == 'Week') {
      return _getDayLabel(value);
    } else if (selectedInterval == 'Month') {
      return _getMonthLabel(value);
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

  double _calculateMaxX() {
    return selectedInterval == 'Week' ? 6.0 : 11.0;
  }

  double _calculateMinY() {
    if (widget.progressHistory.isEmpty) {
      return 0.0; // Default value when there is no completed task
    }

    int minScore = widget.progressHistory
        .map<int>((entry) => entry['scoreChange'])
        .reduce((min, score) => min < score ? min : score);

    return minScore.toDouble() - 5;
  }

  double _calculateMaxY() {
    if (widget.progressHistory.isEmpty) {
      return 10.0; // Default value when there is no completed task
    }

    int maxScore = widget.progressHistory
        .map<int>((entry) => entry['scoreChange'])
        .reduce((max, score) => max > score ? max : score);

    return maxScore.toDouble() + 5;
  }

  List<Map<String, dynamic>> _getFilteredData() {
    final currentDate = DateTime.now();

    List<Map<String, dynamic>> result;

    if (selectedInterval == 'Week') {
      result = _groupAndCalculateDailyScores(7)
          .where((entry) => currentDate.difference(entry['date']).inDays <= 7)
          .toList();
    } else if (selectedInterval == 'Month') {
      result = _groupAndCalculateDailyScores(30)
          .where((entry) => currentDate.difference(entry['date']).inDays <= 30)
          .toList();
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

    print(result);

    return result;
  }
}
