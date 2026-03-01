/// Modèle de données pour un projet
class Project {
  final String id;
  final String name;
  final String? description;
  final String userId; // propriétaire
  final int color; // valeur ARGB stockée comme int
  final DateTime createdAt;
  final DateTime? updatedAt;

  Project({
    required this.id,
    required this.name,
    this.description,
    required this.userId,
    required this.color,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? userId,
    int? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'userId': userId,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      userId: map['userId'] as String,
      color: map['color'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  @override
  String toString() => 'Project(id: $id, name: $name)';
}
