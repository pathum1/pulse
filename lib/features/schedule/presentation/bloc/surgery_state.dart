import 'package:equatable/equatable.dart';
import '../../../../shared/models/surgery.dart';

abstract class SurgeryState extends Equatable {
  const SurgeryState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any surgeries are loaded
class SurgeryInitial extends SurgeryState {
  const SurgeryInitial();
}

/// Loading surgeries from Firestore
class SurgeryLoading extends SurgeryState {
  const SurgeryLoading();
}

/// Surgeries successfully loaded
class SurgeryLoaded extends SurgeryState {
  final List<Surgery> surgeries;
  final DateTime? filterDate; // null means all surgeries

  const SurgeryLoaded({
    required this.surgeries,
    this.filterDate,
  });

  @override
  List<Object?> get props => [surgeries, filterDate];

  /// Get surgeries for a specific date
  List<Surgery> getSurgeriesForDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return surgeries.where((surgery) {
      final surgeryDate = DateTime(
        surgery.scheduledStart.year,
        surgery.scheduledStart.month,
        surgery.scheduledStart.day,
      );
      return surgeryDate == targetDate;
    }).toList();
  }

  /// Get today's surgeries
  List<Surgery> get todaysSurgeries {
    return getSurgeriesForDate(DateTime.now());
  }

  /// Get surgeries by status
  List<Surgery> getSurgeriesByStatus(String status) {
    return surgeries.where((s) => s.status == status).toList();
  }

  /// Check if there are surgeries for a specific date
  bool hasSurgeriesOnDate(DateTime date) {
    return getSurgeriesForDate(date).isNotEmpty;
  }
}

/// Error occurred while loading/updating surgeries
class SurgeryError extends SurgeryState {
  final String message;

  const SurgeryError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Surgery operation in progress (create/update/delete)
class SurgeryOperationInProgress extends SurgeryState {
  final String operation; // 'creating', 'updating', 'deleting'

  const SurgeryOperationInProgress(this.operation);

  @override
  List<Object?> get props => [operation];
}

/// Surgery operation succeeded
class SurgeryOperationSuccess extends SurgeryState {
  final String message;
  final List<Surgery> surgeries; // Keep current surgeries for seamless transition

  const SurgeryOperationSuccess({
    required this.message,
    required this.surgeries,
  });

  @override
  List<Object?> get props => [message, surgeries];
}
