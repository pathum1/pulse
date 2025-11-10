import 'package:equatable/equatable.dart';
import '../../../../shared/models/surgery.dart';

abstract class SurgeryEvent extends Equatable {
  const SurgeryEvent();

  @override
  List<Object?> get props => [];
}

/// Load all surgeries (starts listening to Firestore stream)
class LoadAllSurgeries extends SurgeryEvent {
  const LoadAllSurgeries();
}

/// Load surgeries for a specific date
class LoadSurgeriesByDate extends SurgeryEvent {
  final DateTime date;

  const LoadSurgeriesByDate(this.date);

  @override
  List<Object?> get props => [date];
}

/// Load today's surgeries
class LoadTodaysSurgeries extends SurgeryEvent {
  const LoadTodaysSurgeries();
}

/// Load surgeries for a specific surgeon
class LoadSurgeriesBySurgeon extends SurgeryEvent {
  final String surgeonId;

  const LoadSurgeriesBySurgeon(this.surgeonId);

  @override
  List<Object?> get props => [surgeonId];
}

/// Create a new surgery
class CreateSurgery extends SurgeryEvent {
  final Surgery surgery;

  const CreateSurgery(this.surgery);

  @override
  List<Object?> get props => [surgery];
}

/// Update an existing surgery
class UpdateSurgery extends SurgeryEvent {
  final Surgery surgery;

  const UpdateSurgery(this.surgery);

  @override
  List<Object?> get props => [surgery];
}

/// Delete a surgery
class DeleteSurgery extends SurgeryEvent {
  final String surgeryId;

  const DeleteSurgery(this.surgeryId);

  @override
  List<Object?> get props => [surgeryId];
}

/// Update surgery status
class UpdateSurgeryStatus extends SurgeryEvent {
  final String surgeryId;
  final String status;

  const UpdateSurgeryStatus(this.surgeryId, this.status);

  @override
  List<Object?> get props => [surgeryId, status];
}

/// Postpone a surgery
class PostponeSurgery extends SurgeryEvent {
  final String surgeryId;
  final DateTime newDate;
  final String reason;

  const PostponeSurgery({
    required this.surgeryId,
    required this.newDate,
    required this.reason,
  });

  @override
  List<Object?> get props => [surgeryId, newDate, reason];
}

/// Surgeries updated from Firestore stream
class SurgeriesUpdated extends SurgeryEvent {
  final List<Surgery> surgeries;

  const SurgeriesUpdated(this.surgeries);

  @override
  List<Object?> get props => [surgeries];
}
