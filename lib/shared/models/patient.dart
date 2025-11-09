import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'dart:math';

/// Patient Model
/// Represents a patient in the Pulse Track system
class Patient extends Equatable {
  final String id; // Firestore document ID
  final String uniqueId; // Auto-generated alphanumeric patient identifier
  final String name;
  final String age;
  final String sex; // Male, Female, Other
  final String indication;
  final String importantMedication;
  final String importantComorbidity;
  final String remarks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy; // Surgeon ID who created the patient record
  final String? modifiedBy; // Last surgeon ID who modified the record

  const Patient({
    required this.id,
    required this.uniqueId,
    required this.name,
    required this.age,
    required this.sex,
    required this.indication,
    required this.importantMedication,
    required this.importantComorbidity,
    required this.remarks,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.modifiedBy,
  });

  /// Generate a unique alphanumeric patient ID
  /// Format: PXX####XX where X = letter, # = number
  static String generateUniqueId() {
    final random = Random();
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    
    String id = 'P'; // Prefix for Patient
    
    // Add 2 random letters
    for (int i = 0; i < 2; i++) {
      id += letters[random.nextInt(letters.length)];
    }
    
    // Add 4 random numbers
    for (int i = 0; i < 4; i++) {
      id += numbers[random.nextInt(numbers.length)];
    }
    
    // Add 2 more random letters
    for (int i = 0; i < 2; i++) {
      id += letters[random.nextInt(letters.length)];
    }
    
    return id; // Example: PAB1234CD
  }

  /// Create Patient from Firestore document
  factory Patient.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Patient(
      id: doc.id,
      uniqueId: data['uniqueId'] ?? '',
      name: data['name'] ?? '',
      age: data['age'] ?? '',
      sex: data['sex'] ?? '',
      indication: data['indication'] ?? '',
      importantMedication: data['importantMedication'] ?? '',
      importantComorbidity: data['importantComorbidity'] ?? '',
      remarks: data['remarks'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
      modifiedBy: data['modifiedBy'],
    );
  }

  /// Convert Patient to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'uniqueId': uniqueId,
      'name': name,
      'age': age,
      'sex': sex,
      'indication': indication,
      'importantMedication': importantMedication,
      'importantComorbidity': importantComorbidity,
      'remarks': remarks,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'modifiedBy': modifiedBy,
    };
  }

  /// Create a copy of this Patient with updated fields
  Patient copyWith({
    String? id,
    String? uniqueId,
    String? name,
    String? age,
    String? sex,
    String? indication,
    String? importantMedication,
    String? importantComorbidity,
    String? remarks,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? modifiedBy,
  }) {
    return Patient(
      id: id ?? this.id,
      uniqueId: uniqueId ?? this.uniqueId,
      name: name ?? this.name,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      indication: indication ?? this.indication,
      importantMedication: importantMedication ?? this.importantMedication,
      importantComorbidity: importantComorbidity ?? this.importantComorbidity,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      modifiedBy: modifiedBy ?? this.modifiedBy,
    );
  }

  /// Get formatted patient display name with unique ID
  String get displayName => '$name ($uniqueId)';

  /// Get age with unit
  String get formattedAge => age.isNotEmpty ? '$age years' : 'Age not specified';

  /// Check if patient has critical medication
  bool get hasCriticalMedication => importantMedication.isNotEmpty;

  /// Check if patient has comorbidities
  bool get hasComorbidities => importantComorbidity.isNotEmpty;

  /// Get sex display text
  String get sexDisplayText {
    switch (sex.toLowerCase()) {
      case 'male':
      case 'm':
        return 'Male';
      case 'female':
      case 'f':
        return 'Female';
      case 'other':
      case 'o':
        return 'Other';
      default:
        return 'Not specified';
    }
  }

  @override
  List<Object?> get props => [
    id,
    uniqueId,
    name,
    age,
    sex,
    indication,
    importantMedication,
    importantComorbidity,
    remarks,
    createdAt,
    updatedAt,
    createdBy,
    modifiedBy,
  ];

  @override
  String toString() {
    return 'Patient(id: $id, uniqueId: $uniqueId, name: $name, age: $age, sex: $sex)';
  }
}

/// Patient search result for dropdown
class PatientSearchResult extends Equatable {
  final Patient patient;
  final double matchScore; // For search ranking

  const PatientSearchResult({
    required this.patient,
    required this.matchScore,
  });

  @override
  List<Object?> get props => [patient, matchScore];
}