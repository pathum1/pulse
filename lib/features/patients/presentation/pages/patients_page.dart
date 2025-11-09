import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/patient.dart';
import 'patient_details_page.dart';

/// Patients Page
/// Manages patient records with search and editing capabilities
class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Patient> _allPatients = []; // TODO: Connect to Firestore
  List<Patient> _filteredPatients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _searchController.addListener(_filterPatients);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadPatients() {
    // TODO: Load patients from Firestore
    // For now, using mock data for demonstration
    setState(() {
      _allPatients = _generateMockPatients();
      _filteredPatients = _allPatients;
      _isLoading = false;
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
        remarks: 'Patient is anxious about surgery. Has history of allergic reactions.',
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
        remarks: 'First-time surgery. Very cooperative patient.',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        createdBy: 'surgeon2',
        modifiedBy: 'surgeon1',
      ),
      Patient(
        id: 'patient3',
        uniqueId: 'PMN9012GH',
        name: 'Bob Wilson',
        age: '38',
        sex: 'Male',
        indication: 'Inguinal hernia',
        importantMedication: 'Blood thinners (Clopidogrel)',
        importantComorbidity: 'Previous cardiac stent',
        remarks: 'Athletic patient. Wants to return to sports quickly.',
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
        createdBy: 'surgeon3',
      ),
      Patient(
        id: 'patient4',
        uniqueId: 'PQR3456IJ',
        name: 'Alice Johnson',
        age: '65',
        sex: 'Female',
        indication: 'Gallbladder stones',
        importantMedication: 'ACE inhibitors, Statins',
        importantComorbidity: 'Hypertension, High cholesterol',
        remarks: 'Elderly patient. Requires special monitoring.',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        createdBy: 'surgeon1',
      ),
    ];
  }

  void _filterPatients() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPatients = _allPatients.where((patient) {
        return patient.name.toLowerCase().contains(query) ||
               patient.uniqueId.toLowerCase().contains(query) ||
               patient.indication.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Records'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPatients,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchBar(),
                _buildPatientStats(),
                Expanded(child: _buildPatientsList()),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPatientBottomSheet(context),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name, ID, or indication...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterPatients();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildPatientStats() {
    final totalPatients = _allPatients.length;
    final adults = _allPatients.where((p) => int.tryParse(p.age) != null && int.parse(p.age) >= 18).length;
    final nonAdults = totalPatients - adults;
    final males = _allPatients.where((p) => p.sex.toLowerCase() == 'male').length;
    final females = _allPatients.where((p) => p.sex.toLowerCase() == 'female').length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surgicalTeal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surgicalTeal.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Total: ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: '$totalPatients patient${totalPatients != 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.surgicalTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$adults',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                      const TextSpan(
                        text: ' adults',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const TextSpan(text: ' • '),
                      TextSpan(
                        text: '$nonAdults',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                      const TextSpan(
                        text: ' children',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$males',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo,
                      ),
                    ),
                    const TextSpan(
                      text: ' male',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const TextSpan(text: ' • '),
                    TextSpan(
                      text: '$females',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.pink,
                      ),
                    ),
                    const TextSpan(
                      text: ' female',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientsList() {
    if (_filteredPatients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchController.text.isNotEmpty ? Icons.search_off : Icons.person_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty
                  ? 'No patients found'
                  : 'No patient records',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Try adjusting your search terms'
                  : 'Tap + to add the first patient',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredPatients.length,
      itemBuilder: (context, index) {
        final patient = _filteredPatients[index];
        return _PatientCard(
          patient: patient,
          onTap: () => _navigateToPatientDetails(patient),
          onEdit: () => _editPatient(patient),
        );
      },
    );
  }

  void _navigateToPatientDetails(Patient patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailsPage(patient: patient),
      ),
    );
  }

  void _showAddPatientBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddPatientBottomSheet(),
    );
  }

  void _editPatient(Patient patient) {
    // TODO: Navigate to edit patient page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit patient functionality will be implemented')),
    );
  }

  void _deletePatient(Patient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Patient'),
        content: Text('Are you sure you want to delete ${patient.name}\'s record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Delete patient from Firestore
              setState(() {
                _allPatients.removeWhere((p) => p.id == patient.id);
                _filterPatients();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${patient.name} deleted')),
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


/// Patient card widget
class _PatientCard extends StatelessWidget {
  final Patient patient;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _PatientCard({
    required this.patient,
    required this.onTap,
    required this.onEdit,
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
          child: Row(
            children: [
              // Patient avatar
              CircleAvatar(
                backgroundColor: AppColors.surgicalTeal,
                radius: 24,
                child: Text(
                  patient.name.split(' ').map((n) => n[0]).join('').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Patient basic info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${patient.uniqueId}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.surgicalTeal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Age and Gender
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${patient.age}y',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    patient.sex,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Information row widget
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Patient details dialog

/// Add patient bottom sheet with complete form
class _AddPatientBottomSheet extends StatefulWidget {
  const _AddPatientBottomSheet();

  @override
  State<_AddPatientBottomSheet> createState() => _AddPatientBottomSheetState();
}

class _AddPatientBottomSheetState extends State<_AddPatientBottomSheet> {
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
    setState(() {
      _generatedPatientId = Patient.generateUniqueId();
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

              // Personal Information Section
              const Text(
                'Personal Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

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
              const SizedBox(height: 20),

              // Medical Information Section
              const Text(
                'Medical Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

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

      // TODO: Implement patient creation with Firestore
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

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
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