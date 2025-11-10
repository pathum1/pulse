import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/surgery_repository.dart';
import '../../../../shared/models/surgery.dart';
import 'surgery_event.dart';
import 'surgery_state.dart';

class SurgeryBloc extends Bloc<SurgeryEvent, SurgeryState> {
  final SurgeryRepository _repository;
  StreamSubscription<List<Surgery>>? _surgeriesSubscription;

  SurgeryBloc({
    required SurgeryRepository repository,
  })  : _repository = repository,
        super(const SurgeryInitial()) {
    // Register event handlers
    on<LoadAllSurgeries>(_onLoadAllSurgeries);
    on<LoadSurgeriesByDate>(_onLoadSurgeriesByDate);
    on<LoadTodaysSurgeries>(_onLoadTodaysSurgeries);
    on<LoadSurgeriesBySurgeon>(_onLoadSurgeriesBySurgeon);
    on<CreateSurgery>(_onCreateSurgery);
    on<UpdateSurgery>(_onUpdateSurgery);
    on<DeleteSurgery>(_onDeleteSurgery);
    on<UpdateSurgeryStatus>(_onUpdateSurgeryStatus);
    on<PostponeSurgery>(_onPostponeSurgery);
    on<SurgeriesUpdated>(_onSurgeriesUpdated);
  }

  /// Load all surgeries and listen to real-time updates
  Future<void> _onLoadAllSurgeries(
    LoadAllSurgeries event,
    Emitter<SurgeryState> emit,
  ) async {
    emit(const SurgeryLoading());

    await _surgeriesSubscription?.cancel();

    _surgeriesSubscription = _repository.watchAllSurgeries().listen(
      (surgeries) {
        add(SurgeriesUpdated(surgeries));
      },
      onError: (error) {
        add(SurgeriesUpdated([]));
        emit(SurgeryError('Failed to load surgeries: $error'));
      },
    );
  }

  /// Load surgeries for a specific date
  Future<void> _onLoadSurgeriesByDate(
    LoadSurgeriesByDate event,
    Emitter<SurgeryState> emit,
  ) async {
    emit(const SurgeryLoading());

    await _surgeriesSubscription?.cancel();

    _surgeriesSubscription = _repository.watchSurgeriesByDate(event.date).listen(
      (surgeries) {
        emit(SurgeryLoaded(
          surgeries: surgeries,
          filterDate: event.date,
        ));
      },
      onError: (error) {
        emit(SurgeryError('Failed to load surgeries: $error'));
      },
    );
  }

  /// Load today's surgeries
  Future<void> _onLoadTodaysSurgeries(
    LoadTodaysSurgeries event,
    Emitter<SurgeryState> emit,
  ) async {
    emit(const SurgeryLoading());

    await _surgeriesSubscription?.cancel();

    _surgeriesSubscription = _repository.watchTodaysSurgeries().listen(
      (surgeries) {
        emit(SurgeryLoaded(
          surgeries: surgeries,
          filterDate: DateTime.now(),
        ));
      },
      onError: (error) {
        emit(SurgeryError('Failed to load today\'s surgeries: $error'));
      },
    );
  }

  /// Load surgeries for a specific surgeon
  Future<void> _onLoadSurgeriesBySurgeon(
    LoadSurgeriesBySurgeon event,
    Emitter<SurgeryState> emit,
  ) async {
    emit(const SurgeryLoading());

    await _surgeriesSubscription?.cancel();

    _surgeriesSubscription = _repository.watchSurgeriesBySurgeon(event.surgeonId).listen(
      (surgeries) {
        add(SurgeriesUpdated(surgeries));
      },
      onError: (error) {
        emit(SurgeryError('Failed to load surgeon\'s surgeries: $error'));
      },
    );
  }

  /// Create a new surgery
  Future<void> _onCreateSurgery(
    CreateSurgery event,
    Emitter<SurgeryState> emit,
  ) async {
    // Keep current surgeries if available
    final currentSurgeries = state is SurgeryLoaded
        ? (state as SurgeryLoaded).surgeries
        : <Surgery>[];

    emit(const SurgeryOperationInProgress('creating'));

    try {
      await _repository.createSurgery(event.surgery);
      emit(SurgeryOperationSuccess(
        message: 'Surgery created successfully',
        surgeries: currentSurgeries,
      ));

      // The stream will automatically update the state with new surgery
    } catch (e) {
      emit(SurgeryError('Failed to create surgery: $e'));
      // Restore previous state
      if (currentSurgeries.isNotEmpty) {
        emit(SurgeryLoaded(surgeries: currentSurgeries));
      }
    }
  }

  /// Update an existing surgery
  Future<void> _onUpdateSurgery(
    UpdateSurgery event,
    Emitter<SurgeryState> emit,
  ) async {
    final currentSurgeries = state is SurgeryLoaded
        ? (state as SurgeryLoaded).surgeries
        : <Surgery>[];

    emit(const SurgeryOperationInProgress('updating'));

    try {
      await _repository.updateSurgery(event.surgery);
      emit(SurgeryOperationSuccess(
        message: 'Surgery updated successfully',
        surgeries: currentSurgeries,
      ));

      // The stream will automatically update the state
    } catch (e) {
      emit(SurgeryError('Failed to update surgery: $e'));
      if (currentSurgeries.isNotEmpty) {
        emit(SurgeryLoaded(surgeries: currentSurgeries));
      }
    }
  }

  /// Delete a surgery
  Future<void> _onDeleteSurgery(
    DeleteSurgery event,
    Emitter<SurgeryState> emit,
  ) async {
    final currentSurgeries = state is SurgeryLoaded
        ? (state as SurgeryLoaded).surgeries
        : <Surgery>[];

    emit(const SurgeryOperationInProgress('deleting'));

    try {
      await _repository.deleteSurgery(event.surgeryId);
      emit(SurgeryOperationSuccess(
        message: 'Surgery deleted successfully',
        surgeries: currentSurgeries,
      ));

      // The stream will automatically update the state
    } catch (e) {
      emit(SurgeryError('Failed to delete surgery: $e'));
      if (currentSurgeries.isNotEmpty) {
        emit(SurgeryLoaded(surgeries: currentSurgeries));
      }
    }
  }

  /// Update surgery status
  Future<void> _onUpdateSurgeryStatus(
    UpdateSurgeryStatus event,
    Emitter<SurgeryState> emit,
  ) async {
    final currentSurgeries = state is SurgeryLoaded
        ? (state as SurgeryLoaded).surgeries
        : <Surgery>[];

    emit(const SurgeryOperationInProgress('updating'));

    try {
      await _repository.updateSurgeryStatus(event.surgeryId, event.status);
      emit(SurgeryOperationSuccess(
        message: 'Surgery status updated',
        surgeries: currentSurgeries,
      ));

      // The stream will automatically update the state
    } catch (e) {
      emit(SurgeryError('Failed to update surgery status: $e'));
      if (currentSurgeries.isNotEmpty) {
        emit(SurgeryLoaded(surgeries: currentSurgeries));
      }
    }
  }

  /// Postpone a surgery
  Future<void> _onPostponeSurgery(
    PostponeSurgery event,
    Emitter<SurgeryState> emit,
  ) async {
    final currentSurgeries = state is SurgeryLoaded
        ? (state as SurgeryLoaded).surgeries
        : <Surgery>[];

    emit(const SurgeryOperationInProgress('updating'));

    try {
      await _repository.postponeSurgery(
        event.surgeryId,
        event.newDate,
        event.reason,
      );
      emit(SurgeryOperationSuccess(
        message: 'Surgery postponed successfully',
        surgeries: currentSurgeries,
      ));

      // The stream will automatically update the state
    } catch (e) {
      emit(SurgeryError('Failed to postpone surgery: $e'));
      if (currentSurgeries.isNotEmpty) {
        emit(SurgeryLoaded(surgeries: currentSurgeries));
      }
    }
  }

  /// Handle real-time surgeries updates from Firestore stream
  Future<void> _onSurgeriesUpdated(
    SurgeriesUpdated event,
    Emitter<SurgeryState> emit,
  ) async {
    emit(SurgeryLoaded(surgeries: event.surgeries));
  }

  @override
  Future<void> close() {
    _surgeriesSubscription?.cancel();
    return super.close();
  }
}
