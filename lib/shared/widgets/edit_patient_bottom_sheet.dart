import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../models/patient.dart';
import '../../features/patients/presentation/bloc/patient_bloc.dart';
import '../../features/patients/presentation/bloc/patient_event.dart';
import '../../features/patients/presentation/bloc/patient_state.dart';

/// Edit Patient Bottom Sheet
/// Allows editing existing patient information
class EditPatientBottomSheet extends StatefulWidget {
  final Patient patient;

  const EditPatientBottomSheet({super.key, required this.patient});

  @override
  State<EditPatientBottomSheet> createState() => _EditPatientBottomSheetState();
}

class _EditPatientBottomSheetState extends State<EditPatientBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _indicationController;
  late final TextEditingController _medicationController;
  late final TextEditingController _comorbidityController;
  late final TextEditingController _remarksController;

  late String _selectedSex;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing patient data
    _nameController = TextEditingController(text: widget.patient.name);
    _ageController = TextEditingController(text: widget.patient.age);
    _indicationController = TextEditingController(text: widget.patient.indication);
    _medicationController = TextEditingController(text: widget.patient.importantMedication);
    _comorbidityController = TextEditingController(text: widget.patient.importantComorbidity);
    _remarksController = TextEditingController(text: widget.patient.remarks);
    _selectedSex = widget.patient.sex.isNotEmpty ? widget.patient.sex : 'Male';
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<PatientBloc, PatientState>(
      listener: (context, state) {
        if (state is PatientOperationInProgress) {
          setState(() {
            _isUpdating = true;
          });
        } else if (state is PatientLoaded && _isUpdating) {
          // Close the sheet and show success message
          setState(() {
            _isUpdating = false;
          });

          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Patient updated successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else if (state is PatientError) {
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
                      'Edit Patient',
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

                // Patient ID Display (Read-only)
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
                              'Patient ID (Read-only)',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.surgicalTeal,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              widget.patient.uniqueId,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.surgicalTeal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Personal Information Section
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Name
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.black87),
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
                        style: const TextStyle(color: Colors.black87),
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
                        style: const TextStyle(color: Colors.black87),
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
                const SizedBox(height: 20),

                // Medical Information Section
                const Text(
                  'Medical Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Indication
                TextFormField(
                  controller: _indicationController,
                  style: const TextStyle(color: Colors.black87),
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
                  style: const TextStyle(color: Colors.black87),
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
                  style: const TextStyle(color: Colors.black87),
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
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Remarks',
                    labelStyle: TextStyle(color: Colors.grey.shade700),
                    hintText: 'Additional notes (optional)',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: Icon(Icons.note, color: Colors.grey.shade700),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Action Buttons
                BlocBuilder<PatientBloc, PatientState>(
                  builder: (context, state) {
                    final isLoading = state is PatientOperationInProgress;

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
                            onPressed: isLoading ? null : _updatePatient,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Update Patient'),
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

  void _updatePatient() async {
    if (_formKey.currentState?.validate() ?? false) {
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

      // Create updated patient object
      final updatedPatient = Patient(
        id: widget.patient.id,
        uniqueId: widget.patient.uniqueId, // Keep same ID
        name: _nameController.text.trim(),
        age: _ageController.text.trim(),
        sex: _selectedSex,
        indication: _indicationController.text.trim(),
        importantMedication: _medicationController.text.trim(),
        importantComorbidity: _comorbidityController.text.trim(),
        remarks: _remarksController.text.trim(),
        createdAt: widget.patient.createdAt,
        updatedAt: DateTime.now(),
        createdBy: widget.patient.createdBy,
      );

      // Dispatch update event to BLoC
      context.read<PatientBloc>().add(UpdatePatient(updatedPatient));
    }
  }
}
