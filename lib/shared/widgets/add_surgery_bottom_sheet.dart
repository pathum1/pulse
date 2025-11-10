import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/surgery.dart';
import '../models/patient.dart';
import '../../features/schedule/presentation/bloc/surgery_bloc.dart';
import '../../features/schedule/presentation/bloc/surgery_event.dart';
import '../../features/schedule/presentation/bloc/surgery_state.dart';
import '../../features/patients/presentation/bloc/patient_bloc.dart';
import '../../features/patients/presentation/bloc/patient_event.dart';
import '../../features/patients/presentation/bloc/patient_state.dart';
import './add_patient_bottom_sheet.dart';

class AddSurgeryBottomSheet extends StatefulWidget {
  final DateTime? preselectedDate;

  const AddSurgeryBottomSheet({super.key, this.preselectedDate});

  @override
  State<AddSurgeryBottomSheet> createState() => _AddSurgeryBottomSheetState();
}

class _AddSurgeryBottomSheetState extends State<AddSurgeryBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _surgeryTypeController = TextEditingController();
  final _patientSearchController = TextEditingController();

  DateTime? _selectedDate;
  Patient? _selectedPatient;
  List<Patient> _filteredPatients = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.preselectedDate ?? DateTime.now();

    // Load patients for autocomplete
    context.read<PatientBloc>().add(const LoadAllPatients());

    // Listen to patient search
    _patientSearchController.addListener(_onPatientSearchChanged);
  }

  @override
  void dispose() {
    _surgeryTypeController.dispose();
    _patientSearchController.dispose();
    super.dispose();
  }

  void _onPatientSearchChanged() {
    final query = _patientSearchController.text;
    if (query.isEmpty) {
      setState(() {
        _showSuggestions = false;
        _filteredPatients = [];
      });
    } else {
      context.read<PatientBloc>().add(SearchPatients(query));
      setState(() {
        _showSuggestions = true;
      });
    }
  }

  void _onPatientSelected(Patient patient) {
    setState(() {
      _selectedPatient = patient;
      _patientSearchController.text = patient.displayName;
      _showSuggestions = false;
    });
  }

  Future<void> _openAddPatientSheet() async {
    final result = await showModalBottomSheet<Patient>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: context.read<PatientBloc>(),
        child: const AddPatientBottomSheet(),
      ),
    );

    if (result != null) {
      _onPatientSelected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SurgeryBloc, SurgeryState>(
          listener: (context, state) {
            if (state is SurgeryOperationSuccess) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is SurgeryError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        BlocListener<PatientBloc, PatientState>(
          listener: (context, state) {
            if (state is PatientLoaded) {
              setState(() {
                _filteredPatients = state.filteredPatients;
              });
            } else if (state is PatientOperationSuccess && state.createdPatient != null) {
              // Auto-select newly created patient
              _onPatientSelected(state.createdPatient!);
            }
          },
        ),
      ],
      child: Container(
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Schedule New Surgery',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Patient Name Field with Autocomplete and Add Button
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _patientSearchController,
                            decoration: InputDecoration(
                              labelText: 'Patient Name*',
                              prefixIcon: const Icon(Icons.person),
                              suffixIcon: _patientSearchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _patientSearchController.clear();
                                        setState(() {
                                          _selectedPatient = null;
                                          _showSuggestions = false;
                                        });
                                      },
                                    )
                                  : null,
                            ),
                            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                          ),

                          // Autocomplete suggestions
                          if (_showSuggestions && _filteredPatients.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _filteredPatients.length,
                                itemBuilder: (context, index) {
                                  final patient = _filteredPatients[index];
                                  return ListTile(
                                    dense: true,
                                    leading: CircleAvatar(
                                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                      child: Text(
                                        patient.name.isNotEmpty ? patient.name[0].toUpperCase() : 'P',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(patient.name),
                                    subtitle: Text(patient.uniqueId),
                                    onTap: () => _onPatientSelected(patient),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Add Patient Button
                    IconButton.filled(
                      onPressed: _openAddPatientSheet,
                      icon: const Icon(Icons.add),
                      tooltip: 'Add New Patient',
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Surgery Type
                TextFormField(
                  controller: _surgeryTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Surgery Type*',
                    prefixIcon: Icon(Icons.medical_services),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Date Picker (no time)
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
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                BlocBuilder<SurgeryBloc, SurgeryState>(
                  builder: (context, state) {
                    final isLoading = state is SurgeryOperationInProgress;

                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isLoading ? null : () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _createSurgery,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Create Surgery'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _createSurgery() {
    if (_formKey.currentState!.validate()) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not authenticated'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create surgery with only date (no time specified - defaults to start of day)
      final scheduledDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        8, // Default to 8 AM
        0,
      );

      final surgery = Surgery(
        id: '', // Will be generated by Firestore
        surgeonId: currentUser.uid,
        surgeryTypeId: 'custom', // Can be enhanced later with surgery types
        surgeryTypeName: _surgeryTypeController.text,
        patientId: _selectedPatient?.id ?? '',
        patientName: _selectedPatient?.name ?? _patientSearchController.text,
        patientUniqueId: _selectedPatient?.uniqueId ?? '',
        indication: _selectedPatient?.indication ?? '',
        importantMedication: _selectedPatient?.importantMedication ?? '',
        importantComorbidity: _selectedPatient?.importantComorbidity ?? '',
        remarks: '',
        scheduledStart: scheduledDateTime,
        estimatedDuration: const Duration(hours: 2),
        status: 'scheduled',
        operatingRoom: 'OR-1', // Default operating room
        complications: const [],
        surgeonName: currentUser.displayName ?? currentUser.email ?? 'Unknown',
        reminderMinutes: 30,
        postponementHistory: const [],
        auditHistory: const [],
        isEmergency: false,
        isPostponed: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: currentUser.uid,
      );

      // Dispatch create event to BLoC
      context.read<SurgeryBloc>().add(CreateSurgery(surgery));
    }
  }
}
