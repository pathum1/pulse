import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../shared/models/patient.dart';

class PatientRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PatientRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // Collection reference
  CollectionReference<Map<String, dynamic>> get _patientsCollection =>
      _firestore.collection('patients');

  // Get current user ID
  String get _currentUserId => _auth.currentUser?.uid ?? 'unknown';

  /// Stream of all patients (real-time updates)
  Stream<List<Patient>> watchAllPatients() {
    return _patientsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Patient.fromFirestore(doc))
          .toList();
    });
  }

  /// Stream of patients with search functionality
  Stream<List<Patient>> searchPatients(String query) {
    if (query.isEmpty) {
      return watchAllPatients();
    }

    // Firestore doesn't support full-text search natively
    // We'll use a prefix search and filter in memory
    final queryLower = query.toLowerCase();

    return watchAllPatients().map((patients) {
      return patients.where((patient) {
        final nameLower = patient.name.toLowerCase();
        final uniqueIdLower = patient.uniqueId.toLowerCase();
        return nameLower.contains(queryLower) ||
               uniqueIdLower.contains(queryLower);
      }).toList();
    });
  }

  /// Get single patient by ID
  Future<Patient?> getPatientById(String patientId) async {
    try {
      final doc = await _patientsCollection.doc(patientId).get();
      if (doc.exists) {
        return Patient.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch patient: $e');
    }
  }

  /// Get patient by unique ID (e.g., "PAB1234CD")
  Future<Patient?> getPatientByUniqueId(String uniqueId) async {
    try {
      final snapshot = await _patientsCollection
          .where('uniqueId', isEqualTo: uniqueId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Patient.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch patient by unique ID: $e');
    }
  }

  /// Check if unique ID already exists
  Future<bool> isUniqueIdTaken(String uniqueId) async {
    try {
      final snapshot = await _patientsCollection
          .where('uniqueId', isEqualTo: uniqueId)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Generate a unique patient ID that doesn't exist in Firestore
  Future<String> generateUniquePatientId() async {
    String uniqueId;
    bool isTaken;

    // Keep generating until we find one that's not taken
    do {
      uniqueId = Patient.generateUniqueId();
      isTaken = await isUniqueIdTaken(uniqueId);
    } while (isTaken);

    return uniqueId;
  }

  /// Create a new patient
  Future<Patient> createPatient(Patient patient) async {
    try {
      final now = DateTime.now();

      // Generate unique ID if not provided
      String uniqueId = patient.uniqueId;
      if (uniqueId.isEmpty) {
        uniqueId = await generateUniquePatientId();
      }

      // Prepare patient with audit info
      final patientWithAudit = patient.copyWith(
        uniqueId: uniqueId,
        createdAt: now,
        updatedAt: now,
        createdBy: _currentUserId,
      );

      // Add to Firestore
      final docRef = await _patientsCollection.add(patientWithAudit.toFirestore());

      // Return patient with generated ID
      return patientWithAudit.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create patient: $e');
    }
  }

  /// Update an existing patient
  Future<void> updatePatient(Patient patient) async {
    try {
      if (patient.id.isEmpty) {
        throw Exception('Patient ID is required for update');
      }

      final now = DateTime.now();

      // Update patient with modification info
      final updatedPatient = patient.copyWith(
        updatedAt: now,
        modifiedBy: _currentUserId,
      );

      await _patientsCollection.doc(patient.id).update(updatedPatient.toFirestore());
    } catch (e) {
      throw Exception('Failed to update patient: $e');
    }
  }

  /// Delete a patient
  Future<void> deletePatient(String patientId) async {
    try {
      await _patientsCollection.doc(patientId).delete();
    } catch (e) {
      throw Exception('Failed to delete patient: $e');
    }
  }

  /// Get patients created by a specific surgeon
  Stream<List<Patient>> watchPatientsByCreator(String surgeonId) {
    return _patientsCollection
        .where('createdBy', isEqualTo: surgeonId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Patient.fromFirestore(doc))
          .toList();
    });
  }

  /// Get total patient count
  Future<int> getTotalPatientCount() async {
    try {
      final snapshot = await _patientsCollection.get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get patient count: $e');
    }
  }

  /// Search patients with ranking (for autocomplete)
  Future<List<PatientSearchResult>> searchPatientsWithRanking(String query) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      final snapshot = await _patientsCollection.get();
      final patients = snapshot.docs
          .map((doc) => Patient.fromFirestore(doc))
          .toList();

      final queryLower = query.toLowerCase();
      final results = <PatientSearchResult>[];

      for (final patient in patients) {
        double matchScore = 0.0;
        final nameLower = patient.name.toLowerCase();
        final uniqueIdLower = patient.uniqueId.toLowerCase();

        // Exact match on name
        if (nameLower == queryLower) {
          matchScore = 100.0;
        }
        // Starts with query on name
        else if (nameLower.startsWith(queryLower)) {
          matchScore = 80.0;
        }
        // Contains query in name
        else if (nameLower.contains(queryLower)) {
          matchScore = 60.0;
        }
        // Exact match on unique ID
        else if (uniqueIdLower == queryLower) {
          matchScore = 90.0;
        }
        // Contains query in unique ID
        else if (uniqueIdLower.contains(queryLower)) {
          matchScore = 50.0;
        }

        if (matchScore > 0) {
          results.add(PatientSearchResult(
            patient: patient,
            matchScore: matchScore,
          ));
        }
      }

      // Sort by match score descending
      results.sort((a, b) => b.matchScore.compareTo(a.matchScore));

      return results;
    } catch (e) {
      throw Exception('Failed to search patients: $e');
    }
  }
}
