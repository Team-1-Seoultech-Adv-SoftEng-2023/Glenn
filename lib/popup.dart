//popup.dart
import 'package:flutter/material.dart';
import 'store.dart'; // Import your store.dart file

class CustomPopup extends StatelessWidget {
  final Widget content;

  CustomPopup({required this.content});

  @override
  Widget build(BuildContext context) {
    // Determine the image asset based on selectedOwnedItem
    String imageAsset = selectedOwnedItem.image;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Custom Paint for the speech bubble
          CustomPaint(
            painter: SpeechBubblePainter(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: content, // Original content
            ),
          ),

          // Positioned image in the bottom right corner
          Padding(
            padding: const EdgeInsets.only(right: 8.0), // Adjust the spacing
            child: Image.asset(
              imageAsset,
              width: 150, // Adjust the width as needed
              height: 150, // Adjust the height as needed
            ),
          ),

          // Close button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: 
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the popup
                },
                child: Text('Close'),
              ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for the Speech Bubble Shape
class SpeechBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..quadraticBezierTo(size.width / 2, size.height + 15, size.width / 2 + 15, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..lineTo(0, size.height)
      ..quadraticBezierTo(0, size.height + 15, size.width / 2, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
