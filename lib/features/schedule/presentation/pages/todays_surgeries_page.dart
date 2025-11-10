import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../shared/models/surgery.dart';
import '../../../../shared/models/patient.dart';
import '../../../../shared/widgets/add_patient_bottom_sheet.dart';
import '../bloc/surgery_bloc.dart';
import '../bloc/surgery_event.dart';
import '../bloc/surgery_state.dart';

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
      builder: (context) => _EditSurgeryBottomSheet(surgery: surgery),
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
                  Icon(Icons.person, size: 18, color: Colors.grey.shade700),
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
                  Icon(Icons.location_on, size: 18, color: Colors.grey.shade700),
                  const SizedBox(width: 6),
                  Text(
                    surgery.operatingRoom,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.medical_services, size: 18, color: Colors.grey.shade700),
                  const SizedBox(width: 6),
                  Text(
                    surgery.surgeonName ?? 'Unassigned',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade800,
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
      builder: (context) => _EditSurgeryBottomSheet(surgery: surgery),
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
            _DetailRow('Time', '${surgery.formattedScheduledTime} - ${surgery.formattedEstimatedEndTime}'),
            _DetailRow('Surgeon', surgery.surgeonName ?? 'Not assigned'),
            _DetailRow('Operating Room', surgery.operatingRoom),
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

/// Edit Surgery Bottom Sheet
class _EditSurgeryBottomSheet extends StatefulWidget {
  final Surgery surgery;

  const _EditSurgeryBottomSheet({required this.surgery});

  @override
  State<_EditSurgeryBottomSheet> createState() => _EditSurgeryBottomSheetState();
}

class _EditSurgeryBottomSheetState extends State<_EditSurgeryBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _surgeryTypeController = TextEditingController();
  final _patientSearchController = TextEditingController();
  final _indicationController = TextEditingController();
  final _medicationController = TextEditingController();
  final _comorbidityController = TextEditingController();
  final _remarksController = TextEditingController();
  
  DateTime? _selectedDate;
  Patient? _selectedPatient;
  List<Patient> _allPatients = [];
  List<Patient> _filteredPatients = [];
  bool _showPatientDropdown = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFormWithSurgery();
    _loadPatients();
    _patientSearchController.addListener(_filterPatients);
  }

  void _initializeFormWithSurgery() {
    _surgeryTypeController.text = widget.surgery.surgeryTypeName;
    _selectedDate = widget.surgery.scheduledStart;
    _indicationController.text = widget.surgery.indication;
    _medicationController.text = widget.surgery.importantMedication;
    _comorbidityController.text = widget.surgery.importantComorbidity;
    _remarksController.text = widget.surgery.remarks;

    // Set patient info - allow free text entry
    _patientSearchController.text = widget.surgery.patientName;
  }

  @override
  void dispose() {
    _surgeryTypeController.dispose();
    _patientSearchController.dispose();
    _indicationController.dispose();
    _medicationController.dispose();
    _comorbidityController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _loadPatients() {
    setState(() {
      _allPatients = _generateMockPatients();
      _filteredPatients = _allPatients;
    });
  }

  List<Patient> _generateMockPatients() {
    final now = DateTime.now();
    return [
      Patient(
        id: 'patient1',
        uniqueId: 'PAB1234CD',
        name: 'John Doe',
        age: '45',
        sex: 'Male',
        indication: 'Acute appendicitis',
        importantMedication: 'Aspirin daily, Metformin 500mg',
        importantComorbidity: 'Hypertension, Type 2 Diabetes',
        remarks: 'Patient is anxious about surgery',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 1)),
        createdBy: 'surgeon1',
      ),
      Patient(
        id: 'patient2',
        uniqueId: 'PXY5678EF',
        name: 'Jane Smith',
        age: '52',
        sex: 'Female',
        indication: 'Cholelithiasis',
        importantMedication: 'Insulin, Warfarin',
        importantComorbidity: 'Diabetes Type 1, Atrial Fibrillation',
        remarks: 'First-time surgery',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        createdBy: 'surgeon2',
      ),
    ];
  }

  void _filterPatients() {
    final query = _patientSearchController.text.toLowerCase();
    setState(() {
      _filteredPatients = _allPatients.where((patient) {
        return patient.name.toLowerCase().contains(query) ||
               patient.uniqueId.toLowerCase().contains(query) ||
               patient.indication.toLowerCase().contains(query);
      }).toList();
      _showPatientDropdown = query.isNotEmpty && _filteredPatients.isNotEmpty;
    });
  }

  void _selectPatient(Patient patient) {
    setState(() {
      _selectedPatient = patient;
      _patientSearchController.text = patient.name;
      _showPatientDropdown = false;
      
      // Auto-fill medical information if selected from dropdown
      _indicationController.text = patient.indication;
      _medicationController.text = patient.importantMedication;
      _comorbidityController.text = patient.importantComorbidity;
      _remarksController.text = patient.remarks;
    });
  }

  void _showAddPatientBottomSheetFromEdit() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddPatientBottomSheet(
        onPatientCreated: (Patient newPatient) {
          setState(() {
            // Add patient to the local list
            _allPatients.add(newPatient);
            _filteredPatients = _allPatients;
            
            // Select the new patient
            _selectedPatient = newPatient;
            _patientSearchController.text = newPatient.name;
            _showPatientDropdown = false;
            
            // Auto-fill medical information from new patient
            _indicationController.text = newPatient.indication;
            _medicationController.text = newPatient.importantMedication;
            _comorbidityController.text = newPatient.importantComorbidity;
            _remarksController.text = newPatient.remarks;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Surgery',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Patient Search with Add New Patient button
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _patientSearchController,
                      decoration: InputDecoration(
                        labelText: 'Patient Name*',
                        hintText: 'Search for existing patient...',
                        prefixIcon: const Icon(Icons.person),
                        suffixIcon: _patientSearchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _selectedPatient = null;
                                    _patientSearchController.clear();
                                    _showPatientDropdown = false;
                                  });
                                },
                              )
                            : null,
                      ),
                      validator: (value) {
                        if (_selectedPatient == null) {
                          return 'Please select a patient';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        // Clear selected patient when typing
                        if (_selectedPatient != null) {
                          setState(() {
                            _selectedPatient = null;
                          });
                        }
                        _filterPatients();
                      },
                      onTap: () {
                        setState(() {
                          _showPatientDropdown = _filteredPatients.isNotEmpty;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddPatientBottomSheetFromEdit(),
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text('Add'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                ],
              ),
              if (_showPatientDropdown) ...{
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredPatients.length,
                    itemBuilder: (context, index) {
                      final patient = _filteredPatients[index];
                      return ListTile(
                        dense: true,
                        title: Text(patient.name),
                        subtitle: Text('${patient.uniqueId} • ${patient.indication}'),
                        onTap: () => _selectPatient(patient),
                      );
                    },
                  ),
                ),
              },
              const SizedBox(height: 16),

              // Surgery Type
              TextFormField(
                controller: _surgeryTypeController,
                decoration: const InputDecoration(
                  labelText: 'Surgery Type*',
                  hintText: 'e.g., Appendectomy, Cholecystectomy',
                  prefixIcon: Icon(Icons.medical_services),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter surgery type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date Selection
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date*',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                        : 'Select date',
                    style: TextStyle(
                      color: _selectedDate != null
                          ? Colors.black
                          : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Medical Information Section
              const Text(
                'Medical Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _indicationController,
                decoration: const InputDecoration(
                  labelText: 'Primary Indication',
                  hintText: 'Primary medical condition',
                  prefixIcon: Icon(Icons.medical_information),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _medicationController,
                decoration: const InputDecoration(
                  labelText: 'Important Medications',
                  hintText: 'Current medications',
                  prefixIcon: Icon(Icons.medication),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _comorbidityController,
                decoration: const InputDecoration(
                  labelText: 'Important Comorbidities',
                  hintText: 'Other medical conditions',
                  prefixIcon: Icon(Icons.warning),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  labelText: 'Remarks',
                  hintText: 'Additional notes',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateSurgery,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Update Surgery'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _updateSurgery() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // TODO: Update surgery in Firestore
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Surgery updated for ${_selectedPatient?.name ?? "patient"}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      });
    }
  }
}

