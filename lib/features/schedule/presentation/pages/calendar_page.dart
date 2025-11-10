import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/surgery.dart';
import '../../../../shared/widgets/add_surgery_bottom_sheet.dart';
import '../../../../shared/widgets/edit_surgery_bottom_sheet.dart';
import '../bloc/surgery_bloc.dart';
import '../bloc/surgery_event.dart';
import '../bloc/surgery_state.dart';
import '../../../patients/presentation/bloc/patient_bloc.dart';

/// Calendar Page
/// Hospital-wide surgery calendar (Homepage)
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  String? _expandedSurgeryId; // Track which surgery card is expanded

  @override
  void initState() {
    super.initState();
    // Load all surgeries when page initializes
    context.read<SurgeryBloc>().add(const LoadAllSurgeries());
  }

  List<Surgery> _getSurgeriesForDay(DateTime day, List<Surgery> allSurgeries) {
    return allSurgeries.where((surgery) {
      return isSameDay(surgery.scheduledStart, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Surgery Calendar'),
        backgroundColor: AppColors.surgicalTeal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSurgerySheet(context),
        backgroundColor: AppColors.surgicalTeal,
        child: const Icon(Icons.add, size: 28),
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
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading surgeries',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SurgeryBloc>().add(const LoadAllSurgeries());
                    },
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
          final selectedDaySurgeries = _getSurgeriesForDay(_selectedDay, allSurgeries);

          return Column(
            children: [
              // Calendar Widget
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TableCalendar(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2026, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(_selectedDay, selectedDay)) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
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
                  eventLoader: (day) => _getSurgeriesForDay(day, allSurgeries),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: AppColors.surgicalTeal.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.surgicalTeal,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: AppColors.deepIndigo,
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 3,
                    // Improved text styles for better readability
                    defaultTextStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    weekendTextStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                    selectedTextStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    todayTextStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.surgicalTeal.withOpacity(0.8),
                    ),
                    outsideTextStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonShowsNext: false,
                    titleTextStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    formatButtonTextStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    weekendStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),

              // Selected Day Surgeries List
              Expanded(
                child: Container(
                  color: Colors.grey.shade50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Text(
                              'Surgeries on ${DateFormat('MMM dd').format(_selectedDay)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (selectedDaySurgeries.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.surgicalTeal,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${selectedDaySurgeries.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: selectedDaySurgeries.isEmpty
                            ? Center(
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
                                      'No surgeries scheduled',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap + to schedule a surgery',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: selectedDaySurgeries.length,
                                itemBuilder: (context, index) {
                                  final surgery = selectedDaySurgeries[index];
                                  final isExpanded = _expandedSurgeryId == surgery.id;

                                  return Card(
                                    color: Colors.white,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    elevation: 2,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _expandedSurgeryId = isExpanded ? null : surgery.id;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Header row with icon, patient info, and status
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 24,
                                                  backgroundColor: _getStatusColor(surgery),
                                                  child: Icon(
                                                    _getStatusIcon(surgery),
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        surgery.patientName,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        '${surgery.surgeryTypeName}\n${surgery.surgeonName}',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black54,
                                                          height: 1.4,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Chip(
                                                  label: Text(
                                                    _formatStatus(surgery),
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  backgroundColor: _getStatusColor(surgery),
                                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                                ),
                                              ],
                                            ),

                                            // Expanded details section
                                            if (isExpanded) ...[
                                              const Divider(height: 32),

                                              // Patient details
                                              _buildDetailRow(Icons.person, 'Patient ID',
                                                surgery.patientUniqueId),
                                              if (surgery.patientAge != null || surgery.patientGender != null) ...[
                                                const SizedBox(height: 12),
                                                _buildDetailRow(Icons.info_outline, 'Patient Info',
                                                  '${surgery.patientAge ?? 'N/A'} • ${surgery.patientGender ?? 'N/A'}'),
                                              ],

                                              // Medical information
                                              if (surgery.indication.isNotEmpty) ...[
                                                const SizedBox(height: 12),
                                                _buildDetailRow(Icons.medical_information, 'Indication',
                                                  surgery.indication),
                                              ],
                                              if (surgery.importantMedication.isNotEmpty) ...[
                                                const SizedBox(height: 12),
                                                _buildDetailRow(Icons.medication, 'Important Medication',
                                                  surgery.importantMedication),
                                              ],
                                              if (surgery.importantComorbidity.isNotEmpty) ...[
                                                const SizedBox(height: 12),
                                                _buildDetailRow(Icons.health_and_safety, 'Important Comorbidity',
                                                  surgery.importantComorbidity),
                                              ],
                                              if (surgery.remarks.isNotEmpty) ...[
                                                const SizedBox(height: 12),
                                                _buildDetailRow(Icons.note, 'Remarks',
                                                  surgery.remarks),
                                              ],

                                              // Postponement information
                                              if (surgery.isPostponed && surgery.postponementHistory.isNotEmpty) ...[
                                                const SizedBox(height: 12),
                                                Container(
                                                  padding: const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange.shade50,
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: Colors.orange.shade200),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(Icons.update, size: 18, color: Colors.orange.shade700),
                                                          const SizedBox(width: 8),
                                                          Text(
                                                            'Rescheduled ${surgery.postponementCount} time(s)',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.w600,
                                                              color: Colors.orange.shade700,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      if (surgery.latestPostponementReason != null) ...[
                                                        const SizedBox(height: 8),
                                                        Text(
                                                          'Latest reason: ${surgery.latestPostponementReason}',
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: Colors.orange.shade900,
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                              ],

                                              const SizedBox(height: 20),
                                              // Action buttons
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: OutlinedButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          _expandedSurgeryId = null;
                                                        });
                                                      },
                                                      style: OutlinedButton.styleFrom(
                                                        foregroundColor: Colors.grey.shade700,
                                                        side: BorderSide(color: Colors.grey.shade400),
                                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                                      ),
                                                      child: const Text('Cancel'),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      onPressed: () => _showEditSurgerySheet(context, surgery),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: AppColors.surgicalTeal,
                                                        foregroundColor: Colors.white,
                                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                                      ),
                                                      child: const Text('Update'),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        _showDeleteConfirmation(context, surgery);
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.red,
                                                        foregroundColor: Colors.white,
                                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                                      ),
                                                      child: const Text('Delete'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddSurgerySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<SurgeryBloc>()),
          BlocProvider.value(value: context.read<PatientBloc>()),
        ],
        child: AddSurgeryBottomSheet(
          preselectedDate: _selectedDay,
        ),
      ),
    );
  }

  void _showEditSurgerySheet(BuildContext context, Surgery surgery) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<SurgeryBloc>()),
          BlocProvider.value(value: context.read<PatientBloc>()),
        ],
        child: EditSurgeryBottomSheet(
          surgery: surgery,
        ),
      ),
    );
  }

  String _formatStatus(Surgery surgery) {
    // Show "Rescheduled" if the surgery has been postponed
    if (surgery.isPostponed && surgery.status == 'scheduled') {
      return 'Rescheduled';
    }

    // Otherwise, convert status string to display format (e.g., "in_progress" -> "In Progress")
    return surgery.status.split('_').map((word) =>
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  Color _getStatusColor(Surgery surgery) {
    // Use orange color for rescheduled surgeries
    if (surgery.isPostponed && surgery.status == 'scheduled') {
      return Colors.orange;
    }

    switch (surgery.status) {
      case 'scheduled':
        return AppColors.deepIndigo;
      case 'in_progress':
        return AppColors.surgicalTeal;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'postponed':
        return Colors.orange;
      default:
        return AppColors.deepIndigo;
    }
  }

  IconData _getStatusIcon(Surgery surgery) {
    // Use update icon for rescheduled surgeries
    if (surgery.isPostponed && surgery.status == 'scheduled') {
      return Icons.update;
    }

    switch (surgery.status) {
      case 'scheduled':
        return Icons.schedule;
      case 'in_progress':
        return Icons.medical_services;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'postponed':
        return Icons.update;
      default:
        return Icons.schedule;
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, Surgery surgery) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Surgery'),
        content: Text(
          'Are you sure you want to delete this surgery for ${surgery.patientName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Dispatch delete event to SurgeryBloc
              context.read<SurgeryBloc>().add(DeleteSurgery(surgery.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Surgery for ${surgery.patientName} deleted'),
                  backgroundColor: Colors.green,
                ),
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
