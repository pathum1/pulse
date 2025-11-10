import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/patient_repository.dart';
import '../../../../shared/models/patient.dart';
import 'patient_event.dart';
import 'patient_state.dart';

class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final PatientRepository _repository;
  StreamSubscription<List<Patient>>? _patientsSubscription;
  String? _currentSearchQuery;

  PatientBloc({
    required PatientRepository repository,
  })  : _repository = repository,
        super(const PatientInitial()) {
    // Register event handlers
    on<LoadAllPatients>(_onLoadAllPatients);
    on<SearchPatients>(_onSearchPatients);
    on<CreatePatient>(_onCreatePatient);
    on<UpdatePatient>(_onUpdatePatient);
    on<DeletePatient>(_onDeletePatient);
    on<PatientsUpdated>(_onPatientsUpdated);
    on<ClearPatientSearch>(_onClearPatientSearch);
  }

  /// Load all patients and listen to real-time updates
  Future<void> _onLoadAllPatients(
    LoadAllPatients event,
    Emitter<PatientState> emit,
  ) async {
    emit(const PatientLoading());

    await _patientsSubscription?.cancel();
    _currentSearchQuery = null;

    _patientsSubscription = _repository.watchAllPatients().listen(
      (patients) {
        add(PatientsUpdated(patients));
      },
      onError: (error) {
        emit(PatientError('Failed to load patients: $error'));
      },
    );
  }

  /// Search patients by query
  Future<void> _onSearchPatients(
    SearchPatients event,
    Emitter<PatientState> emit,
  ) async {
    _currentSearchQuery = event.query;

    await _patientsSubscription?.cancel();

    if (event.query.isEmpty) {
      // If search is cleared, load all patients
      add(const LoadAllPatients());
      return;
    }

    emit(const PatientLoading());

    _patientsSubscription = _repository.searchPatients(event.query).listen(
      (patients) {
        emit(PatientLoaded(
          patients: patients,
          searchQuery: event.query,
        ));
      },
      onError: (error) {
        emit(PatientError('Failed to search patients: $error'));
      },
    );
  }

  /// Create a new patient
  Future<void> _onCreatePatient(
    CreatePatient event,
    Emitter<PatientState> emit,
  ) async {
    // Keep current patients if available
    final currentPatients = state is PatientLoaded
        ? (state as PatientLoaded).patients
        : <Patient>[];

    emit(const PatientOperationInProgress('creating'));

    try {
      final createdPatient = await _repository.createPatient(event.patient);
      emit(PatientOperationSuccess(
        message: 'Patient created successfully',
        createdPatient: createdPatient,
        patients: currentPatients,
      ));

      // The stream will automatically update the state with new patient
    } catch (e) {
      emit(PatientError('Failed to create patient: $e'));
      // Restore previous state
      if (currentPatients.isNotEmpty) {
        emit(PatientLoaded(patients: currentPatients));
      }
    }
  }

  /// Update an existing patient
  Future<void> _onUpdatePatient(
    UpdatePatient event,
    Emitter<PatientState> emit,
  ) async {
    final currentPatients = state is PatientLoaded
        ? (state as PatientLoaded).patients
        : <Patient>[];

    emit(const PatientOperationInProgress('updating'));

    try {
      await _repository.updatePatient(event.patient);
      emit(PatientOperationSuccess(
        message: 'Patient updated successfully',
        patients: currentPatients,
      ));

      // The stream will automatically update the state
    } catch (e) {
      emit(PatientError('Failed to update patient: $e'));
      if (currentPatients.isNotEmpty) {
        emit(PatientLoaded(patients: currentPatients));
      }
    }
  }

  /// Delete a patient
  Future<void> _onDeletePatient(
    DeletePatient event,
    Emitter<PatientState> emit,
  ) async {
    final currentPatients = state is PatientLoaded
        ? (state as PatientLoaded).patients
        : <Patient>[];

    emit(const PatientOperationInProgress('deleting'));

    try {
      await _repository.deletePatient(event.patientId);
      emit(PatientOperationSuccess(
        message: 'Patient deleted successfully',
        patients: currentPatients,
      ));

      // The stream will automatically update the state
    } catch (e) {
      emit(PatientError('Failed to delete patient: $e'));
      if (currentPatients.isNotEmpty) {
        emit(PatientLoaded(patients: currentPatients));
      }
    }
  }

  /// Handle real-time patients updates from Firestore stream
  Future<void> _onPatientsUpdated(
    PatientsUpdated event,
    Emitter<PatientState> emit,
  ) async {
    emit(PatientLoaded(
      patients: event.patients,
      searchQuery: _currentSearchQuery,
    ));
  }

  /// Clear search query and reload all patients
  Future<void> _onClearPatientSearch(
    ClearPatientSearch event,
    Emitter<PatientState> emit,
  ) async {
    _currentSearchQuery = null;
    add(const LoadAllPatients());
  }

  @override
  Future<void> close() {
    _patientsSubscription?.cancel();
    return super.close();
  }
}
