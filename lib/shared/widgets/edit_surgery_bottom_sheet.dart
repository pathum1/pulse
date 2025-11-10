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

class EditSurgeryBottomSheet extends StatefulWidget {
  final Surgery surgery;

  const EditSurgeryBottomSheet({super.key, required this.surgery});

  @override
  State<EditSurgeryBottomSheet> createState() => _EditSurgeryBottomSheetState();
}

class _EditSurgeryBottomSheetState extends State<EditSurgeryBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _surgeryTypeController = TextEditingController();
  final _patientSearchController = TextEditingController();
  final _indicationController = TextEditingController();
  final _medicationController = TextEditingController();
  final _comorbidityController = TextEditingController();
  final _remarksController = TextEditingController();

  DateTime? _selectedDate;
  Patient? _selectedPatient;
  List<Patient> _filteredPatients = [];
  bool _showSuggestions = false;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();

    // Initialize with existing surgery data
    _surgeryTypeController.text = widget.surgery.surgeryTypeName;
    _patientSearchController.text = widget.surgery.patientName;
    _indicationController.text = widget.surgery.indication;
    _medicationController.text = widget.surgery.importantMedication;
    _comorbidityController.text = widget.surgery.importantComorbidity;
    _remarksController.text = widget.surgery.remarks;
    _selectedDate = widget.surgery.scheduledStart;

    // Create a Patient object from surgery data
    _selectedPatient = Patient(
      id: widget.surgery.patientId,
      uniqueId: widget.surgery.patientUniqueId,
      name: widget.surgery.patientName,
      age: '',
      sex: '',
      indication: widget.surgery.indication,
      importantMedication: widget.surgery.importantMedication,
      importantComorbidity: widget.surgery.importantComorbidity,
      remarks: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: widget.surgery.createdBy,
    );

    // Load patients for autocomplete
    context.read<PatientBloc>().add(const LoadAllPatients());

    // Listen to patient search
    _patientSearchController.addListener(_onPatientSearchChanged);
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

      // Auto-fill medical information from selected patient
      _indicationController.text = patient.indication;
      _medicationController.text = patient.importantMedication;
      _comorbidityController.text = patient.importantComorbidity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SurgeryBloc, SurgeryState>(
          listener: (context, state) {
            if (state is SurgeryOperationInProgress) {
              setState(() {
                _isUpdating = true;
              });
            } else if (state is SurgeryLoaded && _isUpdating) {
              // Close the sheet and show success message
              // Reset the flag first to prevent multiple closures
              setState(() {
                _isUpdating = false;
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Surgery updated successfully'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            } else if (state is SurgeryError) {
              setState(() {
                _isUpdating = false;
              });
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
                      'Edit Surgery',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Patient Name Field with Autocomplete
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _patientSearchController,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Patient Name*',
                        labelStyle: TextStyle(color: Colors.grey.shade700),
                        hintText: 'Enter or search patient name',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        helperText: 'Select from existing or enter a new name',
                        helperStyle: TextStyle(color: Colors.grey.shade600),
                        prefixIcon: Icon(Icons.person, color: Colors.grey.shade700),
                        filled: true,
                        fillColor: Colors.grey.shade50,
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
                      validator: (v) => v?.trim().isEmpty ?? true ? 'Patient name is required' : null,
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
                              title: Text(
                                patient.name,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Text(
                                patient.uniqueId,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                              onTap: () => _onPatientSelected(patient),
                            );
                          },
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Surgery Type
                TextFormField(
                  controller: _surgeryTypeController,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Surgery Type*',
                    labelStyle: TextStyle(color: Colors.grey.shade700),
                    prefixIcon: Icon(Icons.medical_services, color: Colors.grey.shade700),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Date Picker
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date*',
                      labelStyle: TextStyle(color: Colors.grey.shade700),
                      prefixIcon: Icon(Icons.calendar_today, color: Colors.grey.shade700),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    child: Text(
                      _selectedDate != null
                          ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                          : 'Select date',
                      style: TextStyle(
                        color: _selectedDate != null ? Colors.black87 : Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Indication
                TextFormField(
                  controller: _indicationController,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Primary Indication',
                    labelStyle: TextStyle(color: Colors.grey.shade700),
                    hintText: 'Primary medical condition',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: Icon(Icons.medical_information, color: Colors.grey.shade700),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Important Medications
                TextFormField(
                  controller: _medicationController,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Important Medications',
                    labelStyle: TextStyle(color: Colors.grey.shade700),
                    hintText: 'Current medications (optional)',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: Icon(Icons.medication, color: Colors.grey.shade700),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Important Comorbidities
                TextFormField(
                  controller: _comorbidityController,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Important Comorbidities',
                    labelStyle: TextStyle(color: Colors.grey.shade700),
                    hintText: 'Other medical conditions (optional)',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: Icon(Icons.warning, color: Colors.grey.shade700),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Remarks
                TextFormField(
                  controller: _remarksController,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Remarks',
                    labelStyle: TextStyle(color: Colors.grey.shade700),
                    hintText: 'Additional notes (optional)',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: Icon(Icons.note, color: Colors.grey.shade700),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  maxLines: 2,
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
                            onPressed: isLoading ? null : _updateSurgery,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Update Surgery'),
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

  void _updateSurgery() async {
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

      Patient? patientToUse = _selectedPatient;

      // If patient not selected from dropdown, create a new patient automatically
      if (patientToUse == null || patientToUse.name != _patientSearchController.text.trim()) {
        final patientName = _patientSearchController.text.trim();

        // Create patient directly in repository and wait for the result
        try {
          final repository = context.read<PatientBloc>().repository;

          // Create new patient object with medical information from form
          final newPatient = Patient(
            id: '', // Will be generated by Firestore
            uniqueId: '', // Will be auto-generated by repository
            name: patientName,
            age: '',
            sex: '',
            indication: _indicationController.text.trim(),
            importantMedication: _medicationController.text.trim(),
            importantComorbidity: _comorbidityController.text.trim(),
            remarks: 'Auto-created during surgery editing',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            createdBy: currentUser.uid,
          );

          // Create patient and WAIT for Firestore to return the created patient with ID
          patientToUse = await repository.createPatient(newPatient);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create patient: $e'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      // Update surgery with only date (no time specified - keep original time)
      final scheduledDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        widget.surgery.scheduledStart.hour,
        widget.surgery.scheduledStart.minute,
      );

      // Create updated surgery with modified fields
      final updatedSurgery = Surgery(
        id: widget.surgery.id,
        surgeonId: widget.surgery.surgeonId,
        surgeryTypeId: widget.surgery.surgeryTypeId,
        surgeryTypeName: _surgeryTypeController.text,
        patientId: patientToUse.id,
        patientName: patientToUse.name,
        patientUniqueId: patientToUse.uniqueId,
        indication: _indicationController.text.trim(),
        importantMedication: _medicationController.text.trim(),
        importantComorbidity: _comorbidityController.text.trim(),
        remarks: _remarksController.text.trim(),
        scheduledStart: scheduledDateTime,
        estimatedDuration: widget.surgery.estimatedDuration,
        status: widget.surgery.status,
        operatingRoom: widget.surgery.operatingRoom,
        complications: widget.surgery.complications,
        surgeonName: widget.surgery.surgeonName,
        reminderMinutes: widget.surgery.reminderMinutes,
        postponementHistory: widget.surgery.postponementHistory,
        auditHistory: widget.surgery.auditHistory,
        isEmergency: widget.surgery.isEmergency,
        isPostponed: widget.surgery.isPostponed,
        createdAt: widget.surgery.createdAt,
        updatedAt: DateTime.now(),
        createdBy: widget.surgery.createdBy,
      );

      // Dispatch update event to BLoC
      context.read<SurgeryBloc>().add(UpdateSurgery(updatedSurgery));
    }
  }
}
