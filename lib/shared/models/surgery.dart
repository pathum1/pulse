import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Postponement history entry
class PostponementHistory extends Equatable {
  final DateTime originalDate;
  final DateTime newDate;
  final String reason;
  final DateTime postponedAt;
  final String postponedBy; // Surgeon ID

  const PostponementHistory({
    required this.originalDate,
    required this.newDate,
    required this.reason,
    required this.postponedAt,
    required this.postponedBy,
  });

  factory PostponementHistory.fromMap(Map<String, dynamic> map) {
    return PostponementHistory(
      originalDate: (map['originalDate'] as Timestamp).toDate(),
      newDate: (map['newDate'] as Timestamp).toDate(),
      reason: map['reason'] ?? '',
      postponedAt: (map['postponedAt'] as Timestamp).toDate(),
      postponedBy: map['postponedBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'originalDate': Timestamp.fromDate(originalDate),
      'newDate': Timestamp.fromDate(newDate),
      'reason': reason,
      'postponedAt': Timestamp.fromDate(postponedAt),
      'postponedBy': postponedBy,
    };
  }

  @override
  List<Object?> get props => [originalDate, newDate, reason, postponedAt, postponedBy];
}

/// Surgery audit entry for tracking changes
class SurgeryAuditEntry extends Equatable {
  final String action; // created, updated, postponed, cancelled, completed
  final String field; // which field was changed
  final String? oldValue;
  final String? newValue;
  final DateTime timestamp;
  final String changedBy; // Surgeon ID
  final String? reason;

  const SurgeryAuditEntry({
    required this.action,
    required this.field,
    this.oldValue,
    this.newValue,
    required this.timestamp,
    required this.changedBy,
    this.reason,
  });

  factory SurgeryAuditEntry.fromMap(Map<String, dynamic> map) {
    return SurgeryAuditEntry(
      action: map['action'] ?? '',
      field: map['field'] ?? '',
      oldValue: map['oldValue'],
      newValue: map['newValue'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      changedBy: map['changedBy'] ?? '',
      reason: map['reason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'action': action,
      'field': field,
      'oldValue': oldValue,
      'newValue': newValue,
      'timestamp': Timestamp.fromDate(timestamp),
      'changedBy': changedBy,
      'reason': reason,
    };
  }

  @override
  List<Object?> get props => [action, field, oldValue, newValue, timestamp, changedBy, reason];
}

/// Surgery Model
/// Represents a scheduled surgery in the Pulse Track system
class Surgery extends Equatable {
  final String id;
  final String surgeonId;
  final String surgeryTypeId;
  final String surgeryTypeName; // Denormalized for quick access
  final String patientId; // Reference to Patient model
  final String patientName; // Denormalized for quick access
  final String patientUniqueId; // Patient's alphanumeric ID
  final String? patientAge;
  final String? patientGender;
  final String indication;
  final String importantMedication;
  final String importantComorbidity;
  final String remarks;
  final DateTime scheduledStart;
  final Duration estimatedDuration;
  final String status; // scheduled, in_progress, completed, cancelled, overdue, postponed
  final DateTime? actualStart;
  final DateTime? actualEnd;
  final String operatingRoom;
  final String? notes;
  final List<String> complications;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy; // Surgeon ID who created this surgery
  final String? modifiedBy; // Last surgeon ID who modified this surgery
  final String? surgeonName; // Denormalized for quick access
  final int reminderMinutes; // How many minutes before surgery to remind
  final bool isEmergency;
  
  // Postponement tracking
  final bool isPostponed;
  final DateTime? originalScheduledStart; // Original date/time before postponement
  final List<PostponementHistory> postponementHistory;
  
  // Audit tracking
  final List<SurgeryAuditEntry> auditHistory;
  
  final Map<String, dynamic>? additionalData;

  const Surgery({
    required this.id,
    required this.surgeonId,
    required this.surgeryTypeId,
    required this.surgeryTypeName,
    required this.patientId,
    required this.patientName,
    required this.patientUniqueId,
    this.patientAge,
    this.patientGender,
    required this.indication,
    required this.importantMedication,
    required this.importantComorbidity,
    required this.remarks,
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
    required this.createdBy,
    this.modifiedBy,
    this.surgeonName,
    this.reminderMinutes = 30,
    this.isEmergency = false,
    this.isPostponed = false,
    this.originalScheduledStart,
    this.postponementHistory = const [],
    this.auditHistory = const [],
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
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      patientUniqueId: data['patientUniqueId'] ?? '',
      patientAge: data['patientAge'],
      patientGender: data['patientGender'],
      indication: data['indication'] ?? '',
      importantMedication: data['importantMedication'] ?? '',
      importantComorbidity: data['importantComorbidity'] ?? '',
      remarks: data['remarks'] ?? '',
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
      createdBy: data['createdBy'] ?? '',
      modifiedBy: data['modifiedBy'],
      surgeonName: data['surgeonName'],
      reminderMinutes: data['reminderMinutes'] ?? 30,
      isEmergency: data['isEmergency'] ?? false,
      isPostponed: data['isPostponed'] ?? false,
      originalScheduledStart: data['originalScheduledStart'] != null 
          ? (data['originalScheduledStart'] as Timestamp).toDate()
          : null,
      postponementHistory: (data['postponementHistory'] as List<dynamic>?)
          ?.map((item) => PostponementHistory.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      auditHistory: (data['auditHistory'] as List<dynamic>?)
          ?.map((item) => SurgeryAuditEntry.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      additionalData: data['additionalData'],
    );
  }

  /// Convert Surgery to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'surgeonId': surgeonId,
      'surgeryTypeId': surgeryTypeId,
      'surgeryTypeName': surgeryTypeName,
      'patientId': patientId,
      'patientName': patientName,
      'patientUniqueId': patientUniqueId,
      'patientAge': patientAge,
      'patientGender': patientGender,
      'indication': indication,
      'importantMedication': importantMedication,
      'importantComorbidity': importantComorbidity,
      'remarks': remarks,
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
      'createdBy': createdBy,
      'modifiedBy': modifiedBy,
      'surgeonName': surgeonName,
      'reminderMinutes': reminderMinutes,
      'isEmergency': isEmergency,
      'isPostponed': isPostponed,
      'originalScheduledStart': originalScheduledStart != null 
          ? Timestamp.fromDate(originalScheduledStart!) : null,
      'postponementHistory': postponementHistory.map((item) => item.toMap()).toList(),
      'auditHistory': auditHistory.map((item) => item.toMap()).toList(),
      'additionalData': additionalData,
    };
  }

  /// Create a copy of this Surgery with updated fields and audit tracking
  Surgery copyWith({
    String? id,
    String? surgeonId,
    String? surgeryTypeId,
    String? surgeryTypeName,
    String? patientId,
    String? patientName,
    String? patientUniqueId,
    String? patientAge,
    String? patientGender,
    String? indication,
    String? importantMedication,
    String? importantComorbidity,
    String? remarks,
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
    String? createdBy,
    String? modifiedBy,
    String? surgeonName,
    int? reminderMinutes,
    bool? isEmergency,
    bool? isPostponed,
    DateTime? originalScheduledStart,
    List<PostponementHistory>? postponementHistory,
    List<SurgeryAuditEntry>? auditHistory,
    Map<String, dynamic>? additionalData,
  }) {
    return Surgery(
      id: id ?? this.id,
      surgeonId: surgeonId ?? this.surgeonId,
      surgeryTypeId: surgeryTypeId ?? this.surgeryTypeId,
      surgeryTypeName: surgeryTypeName ?? this.surgeryTypeName,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientUniqueId: patientUniqueId ?? this.patientUniqueId,
      patientAge: patientAge ?? this.patientAge,
      patientGender: patientGender ?? this.patientGender,
      indication: indication ?? this.indication,
      importantMedication: importantMedication ?? this.importantMedication,
      importantComorbidity: importantComorbidity ?? this.importantComorbidity,
      remarks: remarks ?? this.remarks,
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
      createdBy: createdBy ?? this.createdBy,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      surgeonName: surgeonName ?? this.surgeonName,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      isEmergency: isEmergency ?? this.isEmergency,
      isPostponed: isPostponed ?? this.isPostponed,
      originalScheduledStart: originalScheduledStart ?? this.originalScheduledStart,
      postponementHistory: postponementHistory ?? this.postponementHistory,
      auditHistory: auditHistory ?? this.auditHistory,
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
  
  /// Check if surgery has postponement indicator
  bool get hasPostponementIndicator => isPostponed && postponementHistory.isNotEmpty;

  /// Get postponement count
  int get postponementCount => postponementHistory.length;

  /// Get latest postponement reason
  String? get latestPostponementReason => 
      postponementHistory.isNotEmpty ? postponementHistory.last.reason : null;

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
    patientId,
    patientName,
    patientUniqueId,
    patientAge,
    patientGender,
    indication,
    importantMedication,
    importantComorbidity,
    remarks,
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
    createdBy,
    modifiedBy,
    surgeonName,
    reminderMinutes,
    isEmergency,
    isPostponed,
    originalScheduledStart,
    postponementHistory,
    auditHistory,
    additionalData,
  ];

  @override
  String toString() {
    return 'Surgery(id: $id, patient: $patientName, type: $surgeryTypeName, status: $status, time: $formattedScheduledTime)';
  }
}