import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../shared/models/surgery.dart';

class SurgeryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SurgeryRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // Collection reference
  CollectionReference<Map<String, dynamic>> get _surgeriesCollection =>
      _firestore.collection('surgeries');

  // Get current user info for audit tracking
  String get _currentUserId => _auth.currentUser?.uid ?? 'unknown';
  String get _currentUserName =>
      _auth.currentUser?.displayName ?? _auth.currentUser?.email ?? 'Unknown User';

  /// Stream of all surgeries (real-time updates)
  Stream<List<Surgery>> watchAllSurgeries() {
    return _surgeriesCollection
        .orderBy('scheduledStart', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Surgery.fromFirestore(doc))
          .toList();
    });
  }

  /// Stream of surgeries for a specific date
  Stream<List<Surgery>> watchSurgeriesByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _surgeriesCollection
        .where('scheduledStart',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('scheduledStart', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Surgery.fromFirestore(doc))
          .toList();
    });
  }

  /// Stream of today's surgeries
  Stream<List<Surgery>> watchTodaysSurgeries() {
    return watchSurgeriesByDate(DateTime.now());
  }

  /// Stream of surgeries for a specific surgeon
  Stream<List<Surgery>> watchSurgeriesBySurgeon(String surgeonId) {
    return _surgeriesCollection
        .where('surgeonId', isEqualTo: surgeonId)
        .orderBy('scheduledStart', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Surgery.fromFirestore(doc))
          .toList();
    });
  }

  /// Get single surgery by ID
  Future<Surgery?> getSurgeryById(String surgeryId) async {
    try {
      final doc = await _surgeriesCollection.doc(surgeryId).get();
      if (doc.exists) {
        return Surgery.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch surgery: $e');
    }
  }

  /// Create a new surgery
  Future<Surgery> createSurgery(Surgery surgery) async {
    try {
      final now = DateTime.now();

      // Prepare surgery with audit info
      final surgeryWithAudit = surgery.copyWith(
        createdBy: _currentUserId,
        modifiedBy: _currentUserId,
      );

      // Add to Firestore
      final docRef = await _surgeriesCollection.add(surgeryWithAudit.toFirestore());

      // Return surgery with generated ID
      return surgeryWithAudit.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create surgery: $e');
    }
  }

  /// Update an existing surgery
  Future<void> updateSurgery(Surgery surgery) async {
    try {
      if (surgery.id.isEmpty) {
        throw Exception('Surgery ID is required for update');
      }

      // Update surgery with modification audit info
      final updatedSurgery = surgery.copyWith(
        modifiedBy: _currentUserId,
      );

      await _surgeriesCollection.doc(surgery.id).update(updatedSurgery.toFirestore());
    } catch (e) {
      throw Exception('Failed to update surgery: $e');
    }
  }

  /// Delete a surgery
  Future<void> deleteSurgery(String surgeryId) async {
    try {
      await _surgeriesCollection.doc(surgeryId).delete();
    } catch (e) {
      throw Exception('Failed to delete surgery: $e');
    }
  }

  /// Update surgery status
  Future<void> updateSurgeryStatus(String surgeryId, String status) async {
    try {
      final surgery = await getSurgeryById(surgeryId);
      if (surgery == null) {
        throw Exception('Surgery not found');
      }

      final updatedSurgery = surgery.copyWith(status: status);
      await updateSurgery(updatedSurgery);
    } catch (e) {
      throw Exception('Failed to update surgery status: $e');
    }
  }

  /// Postpone a surgery to a new date
  Future<void> postponeSurgery(
    String surgeryId,
    DateTime newDate,
    String reason,
  ) async {
    try {
      final surgery = await getSurgeryById(surgeryId);
      if (surgery == null) {
        throw Exception('Surgery not found');
      }

      // Create postponement history entry
      final postponementEntry = PostponementHistory(
        originalDate: surgery.scheduledStart,
        newDate: newDate,
        reason: reason,
        postponedBy: _currentUserName,
        postponedAt: DateTime.now(),
      );

      // Update surgery with new date and postponement history
      final updatedSurgery = surgery.copyWith(
        scheduledStart: newDate,
        postponementHistory: [...surgery.postponementHistory, postponementEntry],
      );

      await updateSurgery(updatedSurgery);
    } catch (e) {
      throw Exception('Failed to postpone surgery: $e');
    }
  }

  /// Get surgeries count by status
  Future<Map<String, int>> getSurgeryCountsByStatus() async {
    try {
      final snapshot = await _surgeriesCollection.get();
      final surgeries = snapshot.docs
          .map((doc) => Surgery.fromFirestore(doc))
          .toList();

      final counts = <String, int>{};
      final statuses = ['scheduled', 'in_progress', 'completed', 'cancelled', 'postponed', 'overdue'];

      for (final status in statuses) {
        counts[status] = surgeries.where((s) => s.status == status).length;
      }

      return counts;
    } catch (e) {
      throw Exception('Failed to get surgery counts: $e');
    }
  }

  /// Search surgeries by patient name
  Stream<List<Surgery>> searchSurgeriesByPatientName(String patientName) {
    return _surgeriesCollection
        .where('patientName', isGreaterThanOrEqualTo: patientName)
        .where('patientName', isLessThanOrEqualTo: '$patientName\uf8ff')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Surgery.fromFirestore(doc))
          .toList();
    });
  }

  /// Get surgeries within a date range
  Future<List<Surgery>> getSurgeriesInRange(DateTime start, DateTime end) async {
    try {
      final snapshot = await _surgeriesCollection
          .where('scheduledStart',
              isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('scheduledStart', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('scheduledStart')
          .get();

      return snapshot.docs
          .map((doc) => Surgery.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get surgeries in range: $e');
    }
  }
}
