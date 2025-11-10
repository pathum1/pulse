import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/patient.dart';
import '../../../../shared/models/surgery.dart';
import '../../../../shared/widgets/edit_patient_bottom_sheet.dart';
import '../../../../shared/widgets/edit_surgery_bottom_sheet.dart';
import '../../../schedule/presentation/bloc/surgery_bloc.dart';
import '../../../schedule/presentation/bloc/surgery_event.dart';
import '../../../schedule/presentation/bloc/surgery_state.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/patient_event.dart';
import '../bloc/patient_state.dart';

/// Patient Details Page - Full patient information view
class PatientDetailsPage extends StatelessWidget {
  final Patient patient;

  const PatientDetailsPage({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    // Ensure surgeries are loaded when page opens
    final surgeryBloc = context.read<SurgeryBloc>();
    if (surgeryBloc.state is! SurgeryLoaded) {
      surgeryBloc.add(const LoadAllSurgeries());
    }

    return BlocBuilder<PatientBloc, PatientState>(
      builder: (context, state) {
        // Find the updated patient from the BLoC state
        Patient currentPatient = patient;
        if (state is PatientLoaded) {
          final updatedPatient = state.patients.firstWhere(
            (p) => p.id == patient.id,
            orElse: () => patient,
          );
          currentPatient = updatedPatient;
        }

        return Scaffold(
          backgroundColor: AppColors.lightBackground,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              currentPatient.name,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.black87),
                onPressed: () => _editPatient(context, currentPatient),
              ),
            ],
          ),
          body: _buildBody(context, currentPatient),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, Patient currentPatient) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Header Card
            Card(
              color: Colors.white,
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
                        currentPatient.name.split(' ').map((n) => n[0]).join('').toUpperCase(),
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
                            currentPatient.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
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
                              'ID: ${currentPatient.uniqueId}',
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
                _buildDetailRow('Age', '${currentPatient.age} years old'),
                _buildDetailRow('Gender', currentPatient.sex),
              ],
            ),
            const SizedBox(height: 20),

            // Medical Information Section
            _buildSection(
              title: 'Medical Information',
              icon: Icons.medical_services,
              children: [
                _buildDetailRow('Primary Indication', currentPatient.indication),
                if (currentPatient.importantMedication.isNotEmpty)
                  _buildDetailRow('Important Medications', currentPatient.importantMedication),
                if (currentPatient.importantComorbidity.isNotEmpty)
                  _buildDetailRow('Comorbidities', currentPatient.importantComorbidity, isWarning: true),
                if (currentPatient.remarks.isNotEmpty)
                  _buildDetailRow('Remarks', currentPatient.remarks),
              ],
            ),
            const SizedBox(height: 20),

            // Surgery History Section
            _buildSurgeryHistorySection(context, currentPatient),
            const SizedBox(height: 20),

            // System Information Section
            _buildSection(
              title: 'System Information',
              icon: Icons.info,
              children: [
                _buildDetailRow('Created', DateFormat('MMM dd, yyyy \'at\' h:mm a').format(currentPatient.createdAt)),
                _buildDetailRow('Created By', currentPatient.createdBy),
                _buildDetailRow('Last Updated', DateFormat('MMM dd, yyyy \'at\' h:mm a').format(currentPatient.updatedAt)),
              ],
            ),
            const SizedBox(height: 40),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editPatient(context, currentPatient),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Patient'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _scheduleNewSurgery(context, currentPatient),
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
            const SizedBox(height: 12),
            // Delete Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _deletePatient(context, currentPatient),
                icon: const Icon(Icons.delete, color: AppColors.warmCoral),
                label: const Text('Delete Patient'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warmCoral,
                  side: const BorderSide(color: AppColors.warmCoral),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildSurgeryHistorySection(BuildContext context, Patient currentPatient) {
    return BlocBuilder<SurgeryBloc, SurgeryState>(
      builder: (context, state) {
        if (state is! SurgeryLoaded) {
          return const SizedBox.shrink();
        }

        // Filter surgeries for this patient and sort by date (newest first)
        final patientSurgeries = state.surgeries
            .where((surgery) => surgery.patientUniqueId == currentPatient.uniqueId)
            .toList()
          ..sort((a, b) => b.scheduledStart.compareTo(a.scheduledStart));

        return Card(
          color: Colors.white,
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
                    const Icon(Icons.history, color: AppColors.surgicalTeal),
                    const SizedBox(width: 12),
                    const Text(
                      'Surgery History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.surgicalTeal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (patientSurgeries.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No surgery history',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  ...patientSurgeries.map((surgery) => _buildSurgeryCard(context, surgery)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSurgeryCard(BuildContext context, Surgery surgery) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: AppColors.lightBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    surgery.surgeryTypeName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(surgery).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _formatStatus(surgery),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(surgery),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(surgery.scheduledStart),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.person, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    surgery.surgeonName ?? 'Unknown Surgeon',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _viewSurgeryDetails(context, surgery),
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('View Details'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.surgicalTeal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatStatus(Surgery surgery) {
    if (surgery.isPostponed && surgery.status == 'scheduled') {
      return 'Rescheduled';
    }
    return surgery.status.split('_').map((word) =>
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  Color _getStatusColor(Surgery surgery) {
    if (surgery.isPostponed && surgery.status == 'scheduled') {
      return Colors.orange;
    }
    switch (surgery.status) {
      case 'scheduled':
        return Colors.blue;
      case 'in_progress':
        return Colors.amber;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'postponed':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      color: Colors.white,
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
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
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

  void _viewSurgeryDetails(BuildContext context, Surgery surgery) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: context.read<SurgeryBloc>(),
        child: EditSurgeryBottomSheet(surgery: surgery),
      ),
    );
  }

  void _editPatient(BuildContext context, Patient currentPatient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: context.read<PatientBloc>(),
        child: EditPatientBottomSheet(patient: currentPatient),
      ),
    );
  }

  void _scheduleNewSurgery(BuildContext context, Patient currentPatient) {
    // TODO: Navigate to surgery creation with pre-selected patient
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Schedule surgery for ${currentPatient.name}')),
    );
  }

  void _deletePatient(BuildContext context, Patient currentPatient) async {
    // Check if patient is assigned to any surgeries
    final surgeryState = context.read<SurgeryBloc>().state;

    if (surgeryState is SurgeryLoaded) {
      final assignedSurgeries = surgeryState.surgeries
          .where((surgery) => surgery.patientUniqueId == currentPatient.uniqueId)
          .toList();

      if (assignedSurgeries.isNotEmpty) {
        // Patient is assigned to surgeries, cannot delete
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Cannot Delete Patient'),
            content: Text(
              '${currentPatient.name} is currently assigned to ${assignedSurgeries.length} '
              '${assignedSurgeries.length == 1 ? "surgery" : "surgeries"}.\n\n'
              'Please remove or reassign the patient from all surgeries before deleting.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
    }

    // Patient not assigned to any surgeries, proceed with deletion
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Patient'),
        content: Text(
          'Are you sure you want to delete ${currentPatient.name}?\n\n'
          'This action cannot be undone and will permanently remove all patient records.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Close the dialog
              Navigator.pop(dialogContext);

              // Delete the patient
              context.read<PatientBloc>().add(DeletePatient(currentPatient.id));

              // Navigate back to patients list
              Navigator.pop(context);

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Patient deleted successfully'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warmCoral,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}