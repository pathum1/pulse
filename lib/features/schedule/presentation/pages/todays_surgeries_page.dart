import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../shared/models/surgery.dart';
import '../../../../shared/widgets/edit_surgery_bottom_sheet.dart';
import '../bloc/surgery_bloc.dart';
import '../bloc/surgery_event.dart';
import '../bloc/surgery_state.dart';
import '../../../patients/presentation/bloc/patient_bloc.dart';

/// Today's Surgeries Page
/// Shows my surgeries scheduled for today
class TodaysSurgeriesPage extends StatefulWidget {
  const TodaysSurgeriesPage({super.key});

  @override
  State<TodaysSurgeriesPage> createState() => _TodaysSurgeriesPageState();
}

class _TodaysSurgeriesPageState extends State<TodaysSurgeriesPage> {
  @override
  void initState() {
    super.initState();
    // Load today's surgeries when page initializes
    context.read<SurgeryBloc>().add(const LoadTodaysSurgeries());
  }

  void _loadTodaysSurgeries() {
    context.read<SurgeryBloc>().add(const LoadTodaysSurgeries());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('My Surgeries (${DateFormat('MMM dd').format(DateTime.now())})'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTodaysSurgeries,
          ),
        ],
      ),
      body: BlocBuilder<SurgeryBloc, SurgeryState>(
        builder: (context, state) {
          if (state is SurgeryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SurgeryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 72, color: Colors.red.shade400),
                  const SizedBox(height: 20),
                  Text(
                    'Error loading surgeries',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTodaysSurgeries,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Extract surgeries from both SurgeryLoaded and SurgeryOperationSuccess states
          final allSurgeries = state is SurgeryLoaded
              ? state.surgeries
              : (state is SurgeryOperationSuccess ? state.surgeries : <Surgery>[]);

          // Filter for current user's surgeries only
          final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
          final mySurgeries = allSurgeries.where((s) => s.surgeonId == currentUserId).toList();

          return _buildSurgeriesList(mySurgeries);
        },
      ),
    );
  }

  Widget _buildSurgeriesList(List<Surgery> mySurgeries) {
    if (mySurgeries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 72,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              'No surgeries assigned to you today',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // Sort surgeries by scheduled time
    final sortedSurgeries = List<Surgery>.from(mySurgeries)
      ..sort((a, b) => a.scheduledStart.compareTo(b.scheduledStart));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedSurgeries.length,
      itemBuilder: (context, index) {
        final surgery = sortedSurgeries[index];
        return _TodaysSurgeryCard(
          surgery: surgery,
          onTap: () => _showSurgeryDetailsDialog(surgery),
          onStatusUpdate: _updateSurgeryStatus,
        );
      },
    );
  }

  void _showSurgeryDetailsDialog(Surgery surgery) {
    showDialog(
      context: context,
      builder: (context) => _TodaysSurgeryDetailsDialog(
        surgery: surgery,
        onEdit: () => _editSurgery(surgery),
        onStatusUpdate: (status) => _updateSurgeryStatus(surgery, status),
      ),
    );
  }

  void _editSurgery(Surgery surgery) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<SurgeryBloc>()),
          BlocProvider.value(value: context.read<PatientBloc>()),
        ],
        child: EditSurgeryBottomSheet(surgery: surgery),
      ),
    );
  }

  void _updateSurgeryStatus(Surgery surgery, String newStatus) {
    // Update surgery status via BLoC
    final updatedSurgery = surgery.copyWith(
      status: newStatus,
      actualStart: newStatus == 'in_progress' ? DateTime.now() : surgery.actualStart,
      actualEnd: newStatus == 'completed' ? DateTime.now() : surgery.actualEnd,
      updatedAt: DateTime.now(),
    );

    context.read<SurgeryBloc>().add(UpdateSurgery(updatedSurgery));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Surgery status updated to ${newStatus.replaceAll('_', ' ')}')),
    );
  }
}

/// Today's surgery card widget (simplified - removes status tags except rescheduled)
class _TodaysSurgeryCard extends StatelessWidget {
  final Surgery surgery;
  final VoidCallback onTap;
  final Function(Surgery, String) onStatusUpdate;

  const _TodaysSurgeryCard({
    required this.surgery,
    required this.onTap,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      surgery.surgeryTypeName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  // Removed _StatusChip - no status display
                  PopupMenuButton<String>(
                    onSelected: (action) => _handleMenuAction(context, surgery, action),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${surgery.patientName} (${surgery.patientUniqueId})',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  // Only show rescheduled tag
                  if (surgery.hasPostponementIndicator)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'RESCHEDULED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.medical_services, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    surgery.surgeonName ?? 'Unassigned',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),
                  const Spacer(),
                  if (surgery.modifiedBy != null && surgery.modifiedBy != surgery.createdBy)
                    Text(
                      'Modified by ${surgery.modifiedBy}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
              // Removed "running for x time" indicator
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, Surgery surgery, String action) {
    switch (action) {
      case 'edit':
        _editSurgery(context, surgery);
        break;
      case 'delete':
        _deleteSurgery(context, surgery);
        break;
    }
  }

  void _editSurgery(BuildContext context, Surgery surgery) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<SurgeryBloc>()),
          BlocProvider.value(value: context.read<PatientBloc>()),
        ],
        child: EditSurgeryBottomSheet(surgery: surgery),
      ),
    );
  }

  void _deleteSurgery(BuildContext context, Surgery surgery) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Surgery'),
        content: Text('Are you sure you want to delete this ${surgery.surgeryTypeName} for ${surgery.patientName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Delete surgery from Firestore
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Surgery for ${surgery.patientName} deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Today's surgery details dialog
class _TodaysSurgeryDetailsDialog extends StatelessWidget {
  final Surgery surgery;
  final VoidCallback onEdit;
  final Function(String) onStatusUpdate;

  const _TodaysSurgeryDetailsDialog({
    required this.surgery,
    required this.onEdit,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(surgery.surgeryTypeName),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _DetailRow('Patient', '${surgery.patientName} (${surgery.patientUniqueId})'),
            _DetailRow('Surgeon', surgery.surgeonName ?? 'Not assigned'),
            _DetailRow('Created by', surgery.createdBy),
            if (surgery.modifiedBy != null && surgery.modifiedBy != surgery.createdBy)
              _DetailRow('Modified by', surgery.modifiedBy!),
            const Divider(),
            _DetailRow('Indication', surgery.indication),
            if (surgery.importantMedication.isNotEmpty)
              _DetailRow('Important Medication', surgery.importantMedication),
            if (surgery.importantComorbidity.isNotEmpty)
              _DetailRow('Comorbidities', surgery.importantComorbidity),
            if (surgery.remarks.isNotEmpty)
              _DetailRow('Remarks', surgery.remarks),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onEdit();
          },
          child: const Text('Edit'),
        ),
      ],
    );
  }
}

/// Helper widget for detail rows
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
