import 'package:equatable/equatable.dart';
import '../../../../shared/models/patient.dart';

abstract class PatientEvent extends Equatable {
  const PatientEvent();

  @override
  List<Object?> get props => [];
}

/// Load all patients (starts listening to Firestore stream)
class LoadAllPatients extends PatientEvent {
  const LoadAllPatients();
}

/// Search patients by query
class SearchPatients extends PatientEvent {
  final String query;

  const SearchPatients(this.query);

  @override
  List<Object?> get props => [query];
}

/// Create a new patient
class CreatePatient extends PatientEvent {
  final Patient patient;

  const CreatePatient(this.patient);

  @override
  List<Object?> get props => [patient];
}

/// Update an existing patient
class UpdatePatient extends PatientEvent {
  final Patient patient;

  const UpdatePatient(this.patient);

  @override
  List<Object?> get props => [patient];
}

/// Delete a patient
class DeletePatient extends PatientEvent {
  final String patientId;

  const DeletePatient(this.patientId);

  @override
  List<Object?> get props => [patientId];
}

/// Patients updated from Firestore stream
class PatientsUpdated extends PatientEvent {
  final List<Patient> patients;

  const PatientsUpdated(this.patients);

  @override
  List<Object?> get props => [patients];
}

/// Clear search query
class ClearPatientSearch extends PatientEvent {
  const ClearPatientSearch();
}
