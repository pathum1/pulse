import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pulse_track/shared/models/patient.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/surgery.dart';
import '../../../../shared/widgets/add_patient_bottom_sheet.dart';

/// Schedule Page
/// Shows surgeon's personal surgery schedule
class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<Surgery> _surgeries = []; // TODO: Connect to Firestore

  @override
  void initState() {
    super.initState();
    _loadSurgeries();
  }

  void _loadSurgeries() {
    // TODO: Load surgeries from Firestore
    // For now, using mock data for demonstration
    setState(() {
      _surgeries = _generateMockSurgeries();
    });
  }

  List<Surgery> _generateMockSurgeries() {
    final now = DateTime.now();
    return [
      Surgery(
        id: '1',
        surgeonId: 'current_user',
        surgeryTypeId: 'appendectomy',
        surgeryTypeName: 'Appendectomy',
        patientId: 'P001',
        patientName: 'John Doe',
        patientUniqueId: 'PAB1234CD',
        patientAge: '45',
        patientGender: 'Male',
        indication: 'Acute appendicitis',
        importantMedication: 'Aspirin daily',
        importantComorbidity: 'Hypertension',
        remarks: 'Patient is anxious',
        scheduledStart: DateTime(now.year, now.month, now.day, 9, 0),
        estimatedDuration: const Duration(hours: 2),
        status: 'scheduled',
        operatingRoom: 'OR-1',
        createdAt: now,
        updatedAt: now,
        createdBy: 'current_user',
        surgeonName: 'Dr. Smith',
        reminderMinutes: 30,
      ),
      Surgery(
        id: '2',
        surgeonId: 'current_user',
        surgeryTypeId: 'gallbladder',
        surgeryTypeName: 'Laparoscopic Cholecystectomy',
        patientId: 'P002',
        patientName: 'Jane Smith',
        patientUniqueId: 'PXY5678EF',
        patientAge: '52',
        patientGender: 'Female',
        indication: 'Cholelithiasis',
        importantMedication: 'None',
        importantComorbidity: 'Diabetes',
        remarks: 'First surgery',
        scheduledStart: DateTime(now.year, now.month, now.day, 14, 30),
        estimatedDuration: const Duration(hours: 1, minutes: 30),
        status: 'scheduled',
        operatingRoom: 'OR-3',
        createdAt: now,
        updatedAt: now,
        createdBy: 'current_user',
        surgeonName: 'Dr. Smith',
        reminderMinutes: 30,
      ),
    ];
  }

  List<Surgery> _getTodaysSurgeries() {
    return _surgeries.where((surgery) => surgery.isToday).toList();
  }

  @override
  Widget build(BuildContext context) {
    final todaysSurgeries = _getTodaysSurgeries();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Schedule'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSurgeries,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadSurgeries();
        },
        child: todaysSurgeries.isEmpty
            ? _buildEmptyState()
            : _buildSurgeryList(todaysSurgeries),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSurgeryBottomSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 80,
              color: AppColors.surgicalTeal,
            ),
            SizedBox(height: 16),
            Text(
              'No surgeries scheduled for today',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the + button to schedule a new surgery',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurgeryList(List<Surgery> surgeries) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: surgeries.length,
      itemBuilder: (context, index) {
        final surgery = surgeries[index];
        return _SurgeryCard(surgery: surgery);
      },
    );
  }

  void _showAddSurgeryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddSurgeryBottomSheet(),
    );
  }
}

/// Surgery card widget displaying individual surgery information
class _SurgeryCard extends StatelessWidget {
  final Surgery surgery;

  const _SurgeryCard({required this.surgery});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to surgery details
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      surgery.surgeryTypeName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(surgery.status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      surgery.statusDisplayText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    surgery.patientName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${surgery.formattedScheduledTime} - ${surgery.formattedEstimatedEndTime}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    surgery.operatingRoom,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              if (surgery.isUpcoming) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surgicalTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Starting in ${_formatDuration(surgery.timeUntilStart)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.surgicalTeal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return AppColors.surgicalTeal;
      case 'in_progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'overdue':
        return AppColors.warmCoral;
      default:
        return Colors.grey;
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }
    return '${duration.inMinutes}m';
  }
}

/// Bottom sheet for adding basic surgery details with patient search
class _AddSurgeryBottomSheet extends StatefulWidget {
  const _AddSurgeryBottomSheet();

  @override
  State<_AddSurgeryBottomSheet> createState() => _AddSurgeryBottomSheetState();
}

class _AddSurgeryBottomSheetState extends State<_AddSurgeryBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _surgeryTypeController = TextEditingController();
  final _patientSearchController = TextEditingController();
  DateTime? _selectedDate;
  Patient? _selectedPatient;
  List<Patient> _allPatients = [];
  List<Patient> _filteredPatients = [];
  bool _showPatientDropdown = false;

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _patientSearchController.addListener(_filterPatients);
  }

  @override
  void dispose() {
    _surgeryTypeController.dispose();
    _patientSearchController.dispose();
    super.dispose();
  }

  void _loadPatients() {
    // TODO: Load from Firestore
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
      Patient(
        id: 'patient3',
        uniqueId: 'PMN9012GH',
        name: 'Bob Wilson',
        age: '38',
        sex: 'Male',
        indication: 'Inguinal hernia',
        importantMedication: 'Blood thinners (Clopidogrel)',
        importantComorbidity: 'Previous cardiac stent',
        remarks: 'Athletic patient',
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
        createdBy: 'surgeon3',
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
    });
  }

  void _showAddPatientBottomSheet() {
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
                    'Schedule New Surgery',
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          onPressed: () => _showAddPatientBottomSheet(),
                          icon: const Icon(Icons.person_add, size: 18),
                          label: const Text('Add'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_showPatientDropdown) ...[
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
                  ],
                ],
              ),
              const SizedBox(height: 16),

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
              const SizedBox(height: 24),
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
                      onPressed: _canProceed() ? _proceedToDetailedForm : null,
                      child: const Text('Continue'),
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
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }


  bool _canProceed() {
    return _patientSearchController.text.trim().isNotEmpty &&
           _surgeryTypeController.text.isNotEmpty &&
           _selectedDate != null;
  }

  void _proceedToDetailedForm() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pop(context);
      // TODO: Navigate to detailed surgery creation page
      // with the basic info and selected patient
      final patientName = _selectedPatient?.name ?? 'Unknown Patient';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Surgery scheduled for $patientName'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

