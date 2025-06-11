import 'package:flutter/material.dart';
import 'dart:html' as html;

void main() => runApp(Hey());

class Hey extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: _rickRoll,
            child: Text(
              'Click Me!',
              style: TextStyle(fontSize: 50.0),
            ),
          ),
        ),
      ),
    );
  }

  void _rickRoll() {
    const String url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
    html.window.open(url, '_blank');
  }
}
