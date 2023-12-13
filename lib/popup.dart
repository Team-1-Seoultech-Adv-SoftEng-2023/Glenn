import 'package:flutter/material.dart';

class CustomPopup extends StatelessWidget {
  final Widget content;

  CustomPopup({required this.content});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: content,
    );
  }
}
