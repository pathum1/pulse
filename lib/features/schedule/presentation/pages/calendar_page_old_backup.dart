import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/surgery.dart';
import '../../../../shared/models/patient.dart';
import '../../../../shared/widgets/add_patient_bottom_sheet.dart';

/// Calendar Page
/// Hospital-wide surgery calendar (Homepage)
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final ValueNotifier<List<Surgery>> _selectedSurgeries;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<Surgery> _allSurgeries = [];

  @override
  void initState() {
    super.initState();
    _selectedSurgeries = ValueNotifier(_getSurgeriesForDay(_selectedDay));
    _loadSurgeries();
  }

  @override
  void dispose() {
    _selectedSurgeries.dispose();
    super.dispose();
  }

  void _loadSurgeries() {
    setState(() {
      _allSurgeries = _generateMockSurgeries();
    });
    _selectedSurgeries.value = _getSurgeriesForDay(_selectedDay);
  }

  List<Surgery> _generateMockSurgeries() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      Surgery(
        id: '1',
        surgeonId: 'surgeon1',
        surgeryTypeId: 'appendectomy',
        surgeryTypeName: 'Appendectomy',
        patientId: 'patient1',
        patientName: 'John Doe',
        patientUniqueId: 'PAB1234CD',
        patientAge: '45',
        patientGender: 'Male',
        indication: 'Acute appendicitis',
        importantMedication: 'Aspirin daily',
        importantComorbidity: 'Hypertension',
        remarks: 'Patient is anxious',
        scheduledStart: today.add(const Duration(hours: 9)),
        estimatedDuration: const Duration(hours: 2),
        status: 'scheduled',
        operatingRoom: 'OR-1',
        createdAt: now,
        updatedAt: now,
        createdBy: 'surgeon1',
        surgeonName: 'Dr. Smith',
        reminderMinutes: 30,
      ),
      Surgery(
        id: '2',
        surgeonId: 'surgeon2',
        surgeryTypeId: 'cholecystectomy',
        surgeryTypeName: 'Laparoscopic Cholecystectomy',
        patientId: 'patient2',
        patientName: 'Jane Smith',
        patientUniqueId: 'PXY5678EF',
        patientAge: '52',
        patientGender: 'Female',
        indication: 'Cholelithiasis',
        importantMedication: 'None',
        importantComorbidity: 'Diabetes',
        remarks: 'First surgery',
        scheduledStart: today.add(const Duration(hours: 14, minutes: 30)),
        estimatedDuration: const Duration(hours: 1, minutes: 30),
        status: 'scheduled',
        operatingRoom: 'OR-3',
        createdAt: now,
        updatedAt: now,
        createdBy: 'surgeon2',
        surgeonName: 'Dr. Johnson',
        reminderMinutes: 30,
        isPostponed: true,
        originalScheduledStart: today.add(const Duration(hours: 10)),
        postponementHistory: [
          PostponementHistory(
            originalDate: today.add(const Duration(hours: 10)),
            newDate: today.add(const Duration(hours: 14, minutes: 30)),
            reason: 'Emergency surgery took priority',
            postponedAt: now.subtract(const Duration(hours: 2)),
            postponedBy: 'surgeon2',
          ),
        ],
      ),
    ];
  }

  List<Surgery> _getSurgeriesForDay(DateTime day) {
    return _allSurgeries.where((surgery) {
      return surgery.scheduledStart.year == day.year &&
             surgery.scheduledStart.month == day.month &&
             surgery.scheduledStart.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Surgery Calendar'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showRollbackDialog,
            tooltip: 'Calendar Rollback',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSurgeries,
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar<Surgery>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getSurgeriesForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              todayDecoration: BoxDecoration(
                color: AppColors.surgicalTeal.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppColors.surgicalTeal,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: AppColors.warmCoral,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
            ),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _selectedSurgeries.value = _getSurgeriesForDay(selectedDay);
                _showDaySurgeriesDialog(selectedDay);
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const Divider(),
          Expanded(
            child: ValueListenableBuilder<List<Surgery>>(
              valueListenable: _selectedSurgeries,
              builder: (context, surgeries, _) {
                return _buildSurgeriesList(surgeries);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSurgeryBottomSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSurgeriesList(List<Surgery> surgeries) {
    if (surgeries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No surgeries scheduled', style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text('for ${DateFormat('MMM dd, yyyy').format(_selectedDay)}', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: surgeries.length,
      itemBuilder: (context, index) {
        final surgery = surgeries[index];
        return _SurgeryCalendarCard(surgery: surgery, onTap: () => _showSurgeryDetailsDialog(surgery));
      },
    );
  }

  void _showDaySurgeriesDialog(DateTime date) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Surgeries - ${DateFormat('MMM dd, yyyy').format(date)}'),
        content: Text('${_getSurgeriesForDay(date).length} surgeries scheduled'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showAddSurgeryBottomSheet(context, preselectedDate: date);
            },
            child: const Text('Add Surgery'),
          ),
        ],
      ),
    );
  }

  void _showSurgeryDetailsDialog(Surgery surgery) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(surgery.surgeryTypeName),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Patient: ${surgery.patientName} (${surgery.patientUniqueId})'),
              Text('Time: ${surgery.formattedScheduledTime}'),
              Text('Surgeon: ${surgery.surgeonName}'),
              Text('OR: ${surgery.operatingRoom}'),
              if (surgery.hasPostponementIndicator) ...[
                const SizedBox(height: 8),
                const Text('RESCHEDULED', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showAddSurgeryBottomSheet(BuildContext context, {DateTime? preselectedDate}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddSurgeryBottomSheet(
        preselectedDate: preselectedDate,
        onSurgeryCreated: _addSurgery,
      ),
    );
  }

  void _addSurgery(Surgery surgery) {
    setState(() {
      _allSurgeries.add(surgery);
    });
    _selectedSurgeries.value = _getSurgeriesForDay(_selectedDay);
  }

  void _showRollbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calendar Rollback'),
        content: const Text('Rollback feature coming soon'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }
}

class _SurgeryCalendarCard extends StatelessWidget {
  final Surgery surgery;
  final VoidCallback onTap;

  const _SurgeryCalendarCard({required this.surgery, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surgicalTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  surgery.formattedScheduledTime,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.surgicalTeal),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(surgery.surgeryTypeName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                        if (surgery.hasPostponementIndicator)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                            child: const Text('RESCHEDULED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('${surgery.patientName} (${surgery.patientUniqueId})', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    Text('${surgery.surgeonName} • ${surgery.operatingRoom}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddSurgeryBottomSheet extends StatefulWidget {
  final DateTime? preselectedDate;
  final Function(Surgery) onSurgeryCreated;

  const AddSurgeryBottomSheet({super.key, this.preselectedDate, required this.onSurgeryCreated});

  @override
  State<AddSurgeryBottomSheet> createState() => _AddSurgeryBottomSheetState();
}

class _AddSurgeryBottomSheetState extends State<AddSurgeryBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _surgeryTypeController = TextEditingController();
  final _patientNameController = TextEditingController();
  final _orController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.preselectedDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _surgeryTypeController.dispose();
    _patientNameController.dispose();
    _orController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 24, left: 24, right: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                  const Text('Schedule New Surgery', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _patientNameController,
                decoration: const InputDecoration(labelText: 'Patient Name*', prefixIcon: Icon(Icons.person)),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _surgeryTypeController,
                decoration: const InputDecoration(labelText: 'Surgery Type*', prefixIcon: Icon(Icons.medical_services)),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _orController,
                decoration: const InputDecoration(labelText: 'Operating Room*', prefixIcon: Icon(Icons.meeting_room)),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Date*', prefixIcon: Icon(Icons.calendar_today)),
                        child: Text(_selectedDate != null ? DateFormat('MMM dd, yyyy').format(_selectedDate!) : 'Select date'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _selectTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Time*', prefixIcon: Icon(Icons.access_time)),
                        child: Text(_selectedTime.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createSurgery,
                      child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Create Surgery'),
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
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(context: context, initialTime: _selectedTime);
    if (time != null) setState(() => _selectedTime = time);
  }

  void _createSurgery() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final scheduledDateTime = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _selectedTime.hour, _selectedTime.minute);
      final now = DateTime.now();

      final surgery = Surgery(
        id: 'temp_${now.millisecondsSinceEpoch}',
        surgeonId: 'current',
        surgeryTypeId: 'type',
        surgeryTypeName: _surgeryTypeController.text,
        patientId: 'patient',
        patientName: _patientNameController.text,
        patientUniqueId: 'PXX0000XX',
        indication: '',
        importantMedication: '',
        importantComorbidity: '',
        remarks: '',
        scheduledStart: scheduledDateTime,
        estimatedDuration: const Duration(hours: 2),
        status: 'scheduled',
        operatingRoom: _orController.text,
        createdAt: now,
        updatedAt: now,
        createdBy: 'current',
        surgeonName: 'Dr. Current',
        reminderMinutes: 30,
      );

      widget.onSurgeryCreated(surgery);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Surgery scheduled for ${_patientNameController.text}'), backgroundColor: Colors.green),
        );
      }
    }
  }
}
