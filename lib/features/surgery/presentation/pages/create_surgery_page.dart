import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Create Surgery Page
/// Form for scheduling a new surgery
class CreateSurgeryPage extends StatelessWidget {
  const CreateSurgeryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Surgery'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle,
              size: 80,
              color: AppColors.surgicalTeal,
            ),
            SizedBox(height: 16),
            Text(
              'Schedule New Surgery',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Surgery scheduling form will appear here',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}