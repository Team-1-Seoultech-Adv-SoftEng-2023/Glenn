import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';

class CongratulationsDialog extends StatelessWidget {
  final double overallScore;

  CongratulationsDialog({required this.overallScore});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 150,
              width: 150,
              child: FlareActor(
                'assets/congratulations.flr', // Replace with your animation file path
                animation:
                    'congratulations', // Replace with your animation name
              ),
            ),
            SizedBox(height: 16),
            const Text(
              '🎉 Congratulations! 🎉',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
                'You completed the task on time. Keep up the good work!'),
            const SizedBox(height: 8),
            Text('Your score is now: $overallScore'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}
