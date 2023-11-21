// user_progress_screen.dart

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
              child: LineChart(
                LineChartData(
                  // ... (your other chart configuration remains unchanged)
                  minX: 0,
                  maxX:
                      _calculateMaxX(), // Adjust based on the selected interval
                  minY: -20,
                  maxY: 100, // Assuming the score is between 0 and 1
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        _getFilteredData().length,
                        (index) => FlSpot(
                          index.toDouble(),
                          _getFilteredData()[index]['scoreChange'] == 1 ? 1 : 0,
                        ),
                      ),
                      isCurved: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateMaxX() {
    // Calculate maxX based on the selected interval
    if (selectedInterval == 'Week') {
      // Assuming each week has 7 days
      return widget.progressHistory.length / 7;
    } else if (selectedInterval == 'Month') {
      // Assuming each month has about 30 days
      return widget.progressHistory.length / 30;
    }
    return widget.progressHistory.length.toDouble();
  }

  List<Map<String, dynamic>> _getFilteredData() {
    // Filter the data based on the selected interval
    if (selectedInterval == 'Week') {
      // You may need to adjust this based on your date format
      return widget.progressHistory
          .where(
            (entry) => DateTime.now().difference(entry['date']).inDays <= 7,
          )
          .toList();
    } else if (selectedInterval == 'Month') {
      // You may need to adjust this based on your date format
      return widget.progressHistory
          .where(
            (entry) => DateTime.now().difference(entry['date']).inDays <= 30,
          )
          .toList();
    }
    return widget.progressHistory;
  }
}
