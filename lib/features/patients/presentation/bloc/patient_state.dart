import 'package:equatable/equatable.dart';
import '../../../../shared/models/patient.dart';

abstract class PatientState extends Equatable {
  const PatientState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any patients are loaded
class PatientInitial extends PatientState {
  const PatientInitial();
}

/// Loading patients from Firestore
class PatientLoading extends PatientState {
  const PatientLoading();
}

/// Patients successfully loaded
class PatientLoaded extends PatientState {
  final List<Patient> patients;
  final String? searchQuery;

  const PatientLoaded({
    required this.patients,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [patients, searchQuery];

  /// Filter patients by search query
  List<Patient> get filteredPatients {
    if (searchQuery == null || searchQuery!.isEmpty) {
      return patients;
    }

    final queryLower = searchQuery!.toLowerCase();
    return patients.where((patient) {
      final nameLower = patient.name.toLowerCase();
      final uniqueIdLower = patient.uniqueId.toLowerCase();
      return nameLower.contains(queryLower) ||
             uniqueIdLower.contains(queryLower);
    }).toList();
  }

  /// Check if currently searching
  bool get isSearching => searchQuery != null && searchQuery!.isNotEmpty;
}

/// Error occurred while loading/updating patients
class PatientError extends PatientState {
  final String message;

  const PatientError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Patient operation in progress (create/update/delete)
class PatientOperationInProgress extends PatientState {
  final String operation; // 'creating', 'updating', 'deleting'

  const PatientOperationInProgress(this.operation);

  @override
  List<Object?> get props => [operation];
}

/// Patient operation succeeded
class PatientOperationSuccess extends PatientState {
  final String message;
  final Patient? createdPatient; // For returning to add surgery flow
  final List<Patient> patients; // Keep current patients for seamless transition

  const PatientOperationSuccess({
    required this.message,
    this.createdPatient,
    required this.patients,
  });

  @override
  List<Object?> get props => [message, createdPatient, patients];
}
