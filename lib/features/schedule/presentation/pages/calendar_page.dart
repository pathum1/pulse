import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/surgery.dart';
import '../../../../shared/widgets/add_surgery_bottom_sheet.dart';
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
      appBar: AppBar(
        title: const Text('Surgery Calendar'),
        backgroundColor: AppColors.surgicalTeal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSurgerySheet(context),
        backgroundColor: AppColors.surgicalTeal,
        icon: const Icon(Icons.add),
        label: const Text('Schedule Surgery'),
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
                        child: Text(
                          'Surgeries on ${DateFormat('MMM dd, yyyy').format(_selectedDay)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
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
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap + to schedule a surgery',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey.shade700,
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
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    elevation: 2,
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      leading: CircleAvatar(
                                        radius: 24,
                                        backgroundColor: _getStatusColor(surgery.status),
                                        child: Icon(
                                          _getStatusIcon(surgery.status),
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      title: Text(
                                        surgery.patientName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${surgery.surgeryTypeName}\n${surgery.surgeonName}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade800,
                                          height: 1.4,
                                        ),
                                      ),
                                      trailing: Chip(
                                        label: Text(
                                          _formatStatus(surgery.status),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        backgroundColor: _getStatusColor(surgery.status),
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                      ),
                                      isThreeLine: true,
                                      onTap: () {
                                        // TODO: Navigate to surgery details
                                      },
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

  String _formatStatus(String status) {
    // Convert status string to display format (e.g., "in_progress" -> "In Progress")
    return status.split('_').map((word) =>
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  Color _getStatusColor(String status) {
    switch (status) {
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

  IconData _getStatusIcon(String status) {
    switch (status) {
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
}
