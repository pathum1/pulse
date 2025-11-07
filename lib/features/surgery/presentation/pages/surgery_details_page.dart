import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Surgery Details Page
/// Shows detailed information about a specific surgery
class SurgeryDetailsPage extends StatelessWidget {
  final String surgeryId;
  
  const SurgeryDetailsPage({
    super.key,
    required this.surgeryId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Surgery Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.medical_services,
              size: 80,
              color: AppColors.surgicalTeal,
            ),
            const SizedBox(height: 16),
            const Text(
              'Surgery Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Surgery ID: $surgeryId',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}