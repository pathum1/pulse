import 'package:flutter/material.dart';

/// Simple test main - no Firebase
void main() {
  runApp(const SimpleTestApp());
}

class SimpleTestApp extends StatelessWidget {
  const SimpleTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pulse Track Test',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pulse Track - Simple Test'),
          backgroundColor: const Color(0xFF009CA6),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.medical_services,
                size: 64,
                color: Color(0xFF009CA6),
              ),
              SizedBox(height: 16),
              Text(
                'Pulse Track',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F3C7E),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'App is working!',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}