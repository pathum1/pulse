import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Surgeon Model
/// Represents a surgeon user in the Pulse Track system
class Surgeon extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String specialization;
  final bool isAvailableToday;
  final DateTime? lastCheckIn;
  final int totalSurgeriesCompleted;
  final String currentStatus; // available, busy, on_leave, in_surgery
  final List<String> certifications;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? profileImageUrl;
  final Map<String, dynamic>? notificationSettings;

  const Surgeon({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialization,
    required this.isAvailableToday,
    this.lastCheckIn,
    required this.totalSurgeriesCompleted,
    required this.currentStatus,
    this.certifications = const [],
    required this.createdAt,
    required this.updatedAt,
    this.profileImageUrl,
    this.notificationSettings,
  });

  /// Create Surgeon from Firestore document
  factory Surgeon.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Surgeon(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      specialization: data['specialization'] ?? '',
      isAvailableToday: data['isAvailableToday'] ?? false,
      lastCheckIn: data['lastCheckIn'] != null 
          ? (data['lastCheckIn'] as Timestamp).toDate()
          : null,
      totalSurgeriesCompleted: data['totalSurgeriesCompleted'] ?? 0,
      currentStatus: data['currentStatus'] ?? 'available',
      certifications: List<String>.from(data['certifications'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      profileImageUrl: data['profileImageUrl'],
      notificationSettings: data['notificationSettings'],
    );
  }

  /// Convert Surgeon to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'specialization': specialization,
      'isAvailableToday': isAvailableToday,
      'lastCheckIn': lastCheckIn != null ? Timestamp.fromDate(lastCheckIn!) : null,
      'totalSurgeriesCompleted': totalSurgeriesCompleted,
      'currentStatus': currentStatus,
      'certifications': certifications,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'profileImageUrl': profileImageUrl,
      'notificationSettings': notificationSettings,
    };
  }

  /// Create a copy of this Surgeon with updated fields
  Surgeon copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? specialization,
    bool? isAvailableToday,
    DateTime? lastCheckIn,
    int? totalSurgeriesCompleted,
    String? currentStatus,
    List<String>? certifications,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? profileImageUrl,
    Map<String, dynamic>? notificationSettings,
  }) {
    return Surgeon(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      specialization: specialization ?? this.specialization,
      isAvailableToday: isAvailableToday ?? this.isAvailableToday,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      totalSurgeriesCompleted: totalSurgeriesCompleted ?? this.totalSurgeriesCompleted,
      currentStatus: currentStatus ?? this.currentStatus,
      certifications: certifications ?? this.certifications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }

  /// Check if surgeon is currently in surgery
  bool get isInSurgery => currentStatus == 'in_surgery';
  
  /// Check if surgeon is available for new surgeries
  bool get isAvailableForSurgery => 
      isAvailableToday && 
      currentStatus == 'available' && 
      lastCheckIn != null &&
      DateTime.now().difference(lastCheckIn!).inHours < 24;

  /// Get status display text
  String get statusDisplayText {
    switch (currentStatus) {
      case 'available':
        return 'Available';
      case 'busy':
        return 'Busy';
      case 'on_leave':
        return 'On Leave';
      case 'in_surgery':
        return 'In Surgery';
      default:
        return 'Unknown';
    }
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    specialization,
    isAvailableToday,
    lastCheckIn,
    totalSurgeriesCompleted,
    currentStatus,
    certifications,
    createdAt,
    updatedAt,
    profileImageUrl,
    notificationSettings,
  ];

  @override
  String toString() {
    return 'Surgeon(id: $id, name: $name, email: $email, status: $currentStatus)';
  }
}