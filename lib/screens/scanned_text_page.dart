import 'package:flutter/material.dart';

class ScannedTextPage extends StatelessWidget {
  final String scannedText;

  ScannedTextPage({required this.scannedText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanned Text'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(scannedText),
        ),
      ),
    );
  }
}
