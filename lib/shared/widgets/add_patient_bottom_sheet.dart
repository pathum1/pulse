import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../models/patient.dart';
import '../../features/patients/presentation/bloc/patient_bloc.dart';
import '../../features/patients/presentation/bloc/patient_event.dart';
import '../../features/patients/presentation/bloc/patient_state.dart';

/// Add Patient Bottom Sheet for creating new patients during surgery scheduling
class AddPatientBottomSheet extends StatefulWidget {
  final Function(Patient)? onPatientCreated; // Now optional

  const AddPatientBottomSheet({super.key, this.onPatientCreated});

  @override
  State<AddPatientBottomSheet> createState() => _AddPatientBottomSheetState();
}

class _AddPatientBottomSheetState extends State<AddPatientBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _indicationController = TextEditingController();
  final _medicationController = TextEditingController();
  final _comorbidityController = TextEditingController();
  final _remarksController = TextEditingController();
  
  String _selectedSex = 'Male';
  bool _isLoading = false;
  String _generatedPatientId = '';

  @override
  void initState() {
    super.initState();
    _generatePatientId();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _indicationController.dispose();
    _medicationController.dispose();
    _comorbidityController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _generatePatientId() {
    // Simple patient ID generation (format: PXX####XX)
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    
    setState(() {
      _generatedPatientId = 'P${letters[(random ~/ 1000) % 26]}${letters[(random ~/ 100) % 26]}'
          '${numbers[(random ~/ 10000) % 10]}${numbers[(random ~/ 1000) % 10]}'
          '${numbers[(random ~/ 100) % 10]}${numbers[(random ~/ 10) % 10]}'
          '${letters[(random ~/ 10) % 26]}${letters[random % 26]}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PatientBloc, PatientState>(
      listener: (context, state) {
        if (state is PatientOperationSuccess && state.createdPatient != null) {
          // Return the created patient
          Navigator.pop(context, state.createdPatient);

          // Call callback if provided
          widget.onPatientCreated?.call(state.createdPatient!);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is PatientError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
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
                    'Add New Patient',
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

              // Auto-generated Patient ID Display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surgicalTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.badge, color: AppColors.surgicalTeal),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Patient ID (Auto-generated)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.surgicalTeal,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _generatedPatientId,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.surgicalTeal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: AppColors.surgicalTeal),
                      onPressed: _generatePatientId,
                      tooltip: 'Generate new ID',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Name
              TextFormField(
                controller: _nameController,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  labelText: 'Full Name*',
                  labelStyle: TextStyle(color: Colors.grey.shade700),
                  hintText: 'Enter patient full name',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.person, color: Colors.grey.shade700),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter patient name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Age and Sex
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Age*',
                        labelStyle: TextStyle(color: Colors.grey.shade700),
                        hintText: 'Years',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: Icon(Icons.cake, color: Colors.grey.shade700),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter age';
                        }
                        if (int.tryParse(value!) == null) {
                          return 'Invalid age';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedSex,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Sex*',
                        labelStyle: TextStyle(color: Colors.grey.shade700),
                        prefixIcon: Icon(Icons.wc, color: Colors.grey.shade700),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Male', child: Text('Male')),
                        DropdownMenuItem(value: 'Female', child: Text('Female')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedSex = value!;
                        });
                      },
                    ),
                  ),
                ],
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
                  labelText: 'Primary Indication*',
                  labelStyle: TextStyle(color: Colors.grey.shade700),
                  hintText: 'Primary medical condition',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.medical_information, color: Colors.grey.shade700),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter primary indication';
                  }
                  return null;
                },
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
                      onPressed: _isLoading ? null : _createPatient,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Add Patient'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  void _createPatient() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not authenticated'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create new patient object
      final patient = Patient(
        id: '', // Will be generated by Firestore
        uniqueId: _generatedPatientId,
        name: _nameController.text,
        age: _ageController.text,
        sex: _selectedSex,
        indication: _indicationController.text,
        importantMedication: _medicationController.text,
        importantComorbidity: _comorbidityController.text,
        remarks: _remarksController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: currentUser.uid,
      );

      // Dispatch create event to PatientBloc
      context.read<PatientBloc>().add(CreatePatient(patient));
    }
  }
}