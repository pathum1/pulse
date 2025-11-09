import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../models/patient.dart';

/// Add Patient Bottom Sheet for creating new patients during surgery scheduling
class AddPatientBottomSheet extends StatefulWidget {
  final Function(Patient) onPatientCreated;
  
  const AddPatientBottomSheet({super.key, required this.onPatientCreated});

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
                decoration: const InputDecoration(
                  labelText: 'Full Name*',
                  hintText: 'Enter patient full name',
                  prefixIcon: Icon(Icons.person),
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
                      decoration: const InputDecoration(
                        labelText: 'Age*',
                        hintText: 'Years',
                        prefixIcon: Icon(Icons.cake),
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
                      decoration: const InputDecoration(
                        labelText: 'Sex*',
                        prefixIcon: Icon(Icons.wc),
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
                decoration: const InputDecoration(
                  labelText: 'Primary Indication*',
                  hintText: 'Primary medical condition',
                  prefixIcon: Icon(Icons.medical_information),
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
                decoration: const InputDecoration(
                  labelText: 'Important Medications',
                  hintText: 'Current medications (optional)',
                  prefixIcon: Icon(Icons.medication),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Important Comorbidities
              TextFormField(
                controller: _comorbidityController,
                decoration: const InputDecoration(
                  labelText: 'Important Comorbidities',
                  hintText: 'Other medical conditions (optional)',
                  prefixIcon: Icon(Icons.warning),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Remarks
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  labelText: 'Remarks',
                  hintText: 'Additional notes (optional)',
                  prefixIcon: Icon(Icons.note),
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
    );
  }

  void _createPatient() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // Create new patient object
      final patient = Patient(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
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
        createdBy: 'current_surgeon', // TODO: Get current surgeon ID
      );

      // TODO: Add patient to Firestore
      // For now, just simulate the creation
      
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pop(context);
          widget.onPatientCreated(patient);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Patient ${patient.name} added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      });
    }
  }
}