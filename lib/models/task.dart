/// Statut d'une tâche
enum TaskStatus { todo, inProgress, done }

/// Priorité d'une tâche
enum TaskPriority { low, medium, high }

/// Modèle de données pour une tâche
class Task {
  final String id;
  final String projectId;
  final String userId;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Task({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.title,
    this.description,
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    this.dueDate,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? id,
    String? projectId,
    String? userId,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'userId': userId,
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      status: TaskStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => TaskStatus.todo,
      ),
      priority: TaskPriority.values.firstWhere(
            (e) => e.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  @override
  String toString() => 'Task(id: $id, title: $title, status: $status)';
}
