import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Surgery Type Model
/// Represents a type of surgery in the repository
class SurgeryType extends Equatable {
  final String id;
  final String name;
  final String category;
  final Duration averageDuration;
  final String description;
  final String createdBy; // Surgeon ID who added this type
  final DateTime createdAt;
  final DateTime updatedAt;
  final int usageCount; // How many times this surgery type has been used
  final List<String> tags; // Additional searchable tags
  final Map<String, dynamic>? metadata; // Additional metadata
  final bool isActive; // Whether this surgery type is currently active

  const SurgeryType({
    required this.id,
    required this.name,
    required this.category,
    required this.averageDuration,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.usageCount = 0,
    this.tags = const [],
    this.metadata,
    this.isActive = true,
  });

  /// Create SurgeryType from Firestore document
  factory SurgeryType.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SurgeryType(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      averageDuration: Duration(minutes: data['averageDurationMinutes'] ?? 60),
      description: data['description'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      usageCount: data['usageCount'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      metadata: data['metadata'],
      isActive: data['isActive'] ?? true,
    );
  }

  /// Create SurgeryType from Map (for predefined surgery types)
  factory SurgeryType.fromMap(Map<String, dynamic> map, String id, String createdBy) {
    return SurgeryType(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      averageDuration: Duration(minutes: map['averageDuration'] ?? 60),
      description: map['description'] ?? '',
      createdBy: createdBy,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      usageCount: 0,
      tags: List<String>.from(map['tags'] ?? []),
      metadata: map['metadata'],
      isActive: true,
    );
  }

  /// Convert SurgeryType to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'averageDurationMinutes': averageDuration.inMinutes,
      'description': description,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'usageCount': usageCount,
      'tags': tags,
      'metadata': metadata,
      'isActive': isActive,
    };
  }

  /// Create a copy of this SurgeryType with updated fields
  SurgeryType copyWith({
    String? id,
    String? name,
    String? category,
    Duration? averageDuration,
    String? description,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? usageCount,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    bool? isActive,
  }) {
    return SurgeryType(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      averageDuration: averageDuration ?? this.averageDuration,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      usageCount: usageCount ?? this.usageCount,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Get formatted average duration
  String get formattedDuration {
    final hours = averageDuration.inHours;
    final minutes = averageDuration.inMinutes.remainder(60);
    
    if (hours > 0) {
      if (minutes > 0) {
        return '${hours}h ${minutes}m';
      } else {
        return '${hours}h';
      }
    } else {
      return '${minutes}m';
    }
  }

  /// Check if surgery type matches search query
  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowerQuery) ||
           category.toLowerCase().contains(lowerQuery) ||
           description.toLowerCase().contains(lowerQuery) ||
           tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
  }

  /// Get search text for autocomplete
  String get searchText => '$name - $category - $description';

  /// Generate tags from name and description
  List<String> generateTags() {
    final generatedTags = <String>{};
    
    // Add words from name
    generatedTags.addAll(
      name.toLowerCase().split(' ').where((word) => word.length > 2)
    );
    
    // Add words from category
    generatedTags.addAll(
      category.toLowerCase().split(' ').where((word) => word.length > 2)
    );
    
    // Add words from description
    generatedTags.addAll(
      description.toLowerCase().split(' ').where((word) => word.length > 2)
    );
    
    // Remove common words
    const commonWords = {'the', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of', 'with', 'by', 'surgery', 'surgical'};
    generatedTags.removeWhere((tag) => commonWords.contains(tag));
    
    return generatedTags.toList();
  }

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    averageDuration,
    description,
    createdBy,
    createdAt,
    updatedAt,
    usageCount,
    tags,
    metadata,
    isActive,
  ];

  @override
  String toString() {
    return 'SurgeryType(id: $id, name: $name, category: $category, duration: $formattedDuration)';
  }
}