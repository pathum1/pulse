import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Surgery Model
/// Represents a scheduled surgery in the Pulse Track system
class Surgery extends Equatable {
  final String id;
  final String surgeonId;
  final String surgeryTypeId;
  final String surgeryTypeName; // Denormalized for quick access
  final String patientName;
  final String patientId;
  final String? patientAge;
  final String? patientGender;
  final DateTime scheduledStart;
  final Duration estimatedDuration;
  final String status; // scheduled, in_progress, completed, cancelled, overdue
  final DateTime? actualStart;
  final DateTime? actualEnd;
  final String operatingRoom;
  final String? notes;
  final List<String> complications;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? surgeonName; // Denormalized for quick access
  final int reminderMinutes; // How many minutes before surgery to remind
  final bool isEmergency;
  final Map<String, dynamic>? additionalData;

  const Surgery({
    required this.id,
    required this.surgeonId,
    required this.surgeryTypeId,
    required this.surgeryTypeName,
    required this.patientName,
    required this.patientId,
    this.patientAge,
    this.patientGender,
    required this.scheduledStart,
    required this.estimatedDuration,
    required this.status,
    this.actualStart,
    this.actualEnd,
    required this.operatingRoom,
    this.notes,
    this.complications = const [],
    required this.createdAt,
    required this.updatedAt,
    this.surgeonName,
    this.reminderMinutes = 30,
    this.isEmergency = false,
    this.additionalData,
  });

  /// Create Surgery from Firestore document
  factory Surgery.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Surgery(
      id: doc.id,
      surgeonId: data['surgeonId'] ?? '',
      surgeryTypeId: data['surgeryTypeId'] ?? '',
      surgeryTypeName: data['surgeryTypeName'] ?? '',
      patientName: data['patientName'] ?? '',
      patientId: data['patientId'] ?? '',
      patientAge: data['patientAge'],
      patientGender: data['patientGender'],
      scheduledStart: (data['scheduledStart'] as Timestamp).toDate(),
      estimatedDuration: Duration(minutes: data['estimatedDurationMinutes'] ?? 60),
      status: data['status'] ?? 'scheduled',
      actualStart: data['actualStart'] != null 
          ? (data['actualStart'] as Timestamp).toDate()
          : null,
      actualEnd: data['actualEnd'] != null 
          ? (data['actualEnd'] as Timestamp).toDate()
          : null,
      operatingRoom: data['operatingRoom'] ?? '',
      notes: data['notes'],
      complications: List<String>.from(data['complications'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      surgeonName: data['surgeonName'],
      reminderMinutes: data['reminderMinutes'] ?? 30,
      isEmergency: data['isEmergency'] ?? false,
      additionalData: data['additionalData'],
    );
  }

  /// Convert Surgery to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'surgeonId': surgeonId,
      'surgeryTypeId': surgeryTypeId,
      'surgeryTypeName': surgeryTypeName,
      'patientName': patientName,
      'patientId': patientId,
      'patientAge': patientAge,
      'patientGender': patientGender,
      'scheduledStart': Timestamp.fromDate(scheduledStart),
      'estimatedDurationMinutes': estimatedDuration.inMinutes,
      'status': status,
      'actualStart': actualStart != null ? Timestamp.fromDate(actualStart!) : null,
      'actualEnd': actualEnd != null ? Timestamp.fromDate(actualEnd!) : null,
      'operatingRoom': operatingRoom,
      'notes': notes,
      'complications': complications,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'surgeonName': surgeonName,
      'reminderMinutes': reminderMinutes,
      'isEmergency': isEmergency,
      'additionalData': additionalData,
    };
  }

  /// Create a copy of this Surgery with updated fields
  Surgery copyWith({
    String? id,
    String? surgeonId,
    String? surgeryTypeId,
    String? surgeryTypeName,
    String? patientName,
    String? patientId,
    String? patientAge,
    String? patientGender,
    DateTime? scheduledStart,
    Duration? estimatedDuration,
    String? status,
    DateTime? actualStart,
    DateTime? actualEnd,
    String? operatingRoom,
    String? notes,
    List<String>? complications,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? surgeonName,
    int? reminderMinutes,
    bool? isEmergency,
    Map<String, dynamic>? additionalData,
  }) {
    return Surgery(
      id: id ?? this.id,
      surgeonId: surgeonId ?? this.surgeonId,
      surgeryTypeId: surgeryTypeId ?? this.surgeryTypeId,
      surgeryTypeName: surgeryTypeName ?? this.surgeryTypeName,
      patientName: patientName ?? this.patientName,
      patientId: patientId ?? this.patientId,
      patientAge: patientAge ?? this.patientAge,
      patientGender: patientGender ?? this.patientGender,
      scheduledStart: scheduledStart ?? this.scheduledStart,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      status: status ?? this.status,
      actualStart: actualStart ?? this.actualStart,
      actualEnd: actualEnd ?? this.actualEnd,
      operatingRoom: operatingRoom ?? this.operatingRoom,
      notes: notes ?? this.notes,
      complications: complications ?? this.complications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      surgeonName: surgeonName ?? this.surgeonName,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      isEmergency: isEmergency ?? this.isEmergency,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  /// Get estimated end time
  DateTime get estimatedEnd => scheduledStart.add(estimatedDuration);
  
  /// Get actual duration if surgery is completed
  Duration? get actualDuration {
    if (actualStart != null && actualEnd != null) {
      return actualEnd!.difference(actualStart!);
    }
    return null;
  }

  /// Check if surgery is currently in progress
  bool get isInProgress => status == 'in_progress';
  
  /// Check if surgery is completed
  bool get isCompleted => status == 'completed';
  
  /// Check if surgery is scheduled
  bool get isScheduled => status == 'scheduled';
  
  /// Check if surgery is overdue
  bool get isOverdue => 
      status == 'overdue' || 
      (isInProgress && DateTime.now().isAfter(estimatedEnd));

  /// Check if surgery is today
  bool get isToday {
    final now = DateTime.now();
    final surgeryDate = scheduledStart;
    return now.year == surgeryDate.year &&
           now.month == surgeryDate.month &&
           now.day == surgeryDate.day;
  }

  /// Check if surgery is upcoming (within next 2 hours)
  bool get isUpcoming {
    final now = DateTime.now();
    final timeDiff = scheduledStart.difference(now);
    return timeDiff.inMinutes > 0 && timeDiff.inHours <= 2;
  }

  /// Get time until surgery starts
  Duration get timeUntilStart {
    final now = DateTime.now();
    return scheduledStart.difference(now);
  }

  /// Get how long surgery has been running (if in progress)
  Duration? get timeRunning {
    if (actualStart != null) {
      return DateTime.now().difference(actualStart!);
    }
    return null;
  }

  /// Get how much time is over the estimated duration
  Duration? get overrunTime {
    if (isInProgress && actualStart != null) {
      final currentDuration = DateTime.now().difference(actualStart!);
      if (currentDuration > estimatedDuration) {
        return currentDuration - estimatedDuration;
      }
    }
    return null;
  }

  /// Get status display text
  String get statusDisplayText {
    switch (status) {
      case 'scheduled':
        return 'Scheduled';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'overdue':
        return 'Overdue';
      default:
        return 'Unknown';
    }
  }

  /// Get formatted scheduled time
  String get formattedScheduledTime {
    return '${scheduledStart.hour.toString().padLeft(2, '0')}:${scheduledStart.minute.toString().padLeft(2, '0')}';
  }

  /// Get formatted estimated end time
  String get formattedEstimatedEndTime {
    return '${estimatedEnd.hour.toString().padLeft(2, '0')}:${estimatedEnd.minute.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
    id,
    surgeonId,
    surgeryTypeId,
    surgeryTypeName,
    patientName,
    patientId,
    patientAge,
    patientGender,
    scheduledStart,
    estimatedDuration,
    status,
    actualStart,
    actualEnd,
    operatingRoom,
    notes,
    complications,
    createdAt,
    updatedAt,
    surgeonName,
    reminderMinutes,
    isEmergency,
    additionalData,
  ];

  @override
  String toString() {
    return 'Surgery(id: $id, patient: $patientName, type: $surgeryTypeName, status: $status, time: $formattedScheduledTime)';
  }
}