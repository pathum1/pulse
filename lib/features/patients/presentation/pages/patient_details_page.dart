import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/patient.dart';

/// Patient Details Page - Full patient information view
class PatientDetailsPage extends StatelessWidget {
  final Patient patient;

  const PatientDetailsPage({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(patient.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editPatient(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Header Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.surgicalTeal,
                      radius: 32,
                      child: Text(
                        patient.name.split(' ').map((n) => n[0]).join('').toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surgicalTeal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'ID: ${patient.uniqueId}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.surgicalTeal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Personal Information Section
            _buildSection(
              title: 'Personal Information',
              icon: Icons.person,
              children: [
                _buildDetailRow('Age', '${patient.age} years old'),
                _buildDetailRow('Gender', patient.sex),
              ],
            ),
            const SizedBox(height: 20),

            // Medical Information Section
            _buildSection(
              title: 'Medical Information',
              icon: Icons.medical_services,
              children: [
                _buildDetailRow('Primary Indication', patient.indication),
                if (patient.importantMedication.isNotEmpty)
                  _buildDetailRow('Important Medications', patient.importantMedication),
                if (patient.importantComorbidity.isNotEmpty)
                  _buildDetailRow('Comorbidities', patient.importantComorbidity, isWarning: true),
                if (patient.remarks.isNotEmpty)
                  _buildDetailRow('Remarks', patient.remarks),
              ],
            ),
            const SizedBox(height: 20),

            // System Information Section
            _buildSection(
              title: 'System Information',
              icon: Icons.info,
              children: [
                _buildDetailRow('Created', DateFormat('MMM dd, yyyy \'at\' h:mm a').format(patient.createdAt)),
                _buildDetailRow('Created By', patient.createdBy),
                _buildDetailRow('Last Updated', DateFormat('MMM dd, yyyy \'at\' h:mm a').format(patient.updatedAt)),
              ],
            ),
            const SizedBox(height: 40),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editPatient(context),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Patient'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _scheduleNewSurgery(context),
                    icon: const Icon(Icons.medical_services),
                    label: const Text('Schedule Surgery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surgicalTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.surgicalTeal),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.surgicalTeal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: isWarning ? AppColors.warmCoral : Colors.black87,
                fontWeight: isWarning ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editPatient(BuildContext context) {
    // TODO: Navigate to edit patient page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit patient functionality will be implemented')),
    );
  }

  void _scheduleNewSurgery(BuildContext context) {
    // TODO: Navigate to surgery creation with pre-selected patient
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Schedule surgery for ${patient.name}')),
    );
  }
}