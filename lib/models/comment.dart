import 'package:uuid/uuid.dart';

class Comment {
  final String id;
  final String taskId;
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.userName,
    required this.content,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Comment copyWith({
    String? id,
    String? taskId,
    String? userId,
    String? userName,
    String? content,
    DateTime? createdAt,
  }) {
    return Comment(
      id:        id        ?? this.id,
      taskId:    taskId    ?? this.taskId,
      userId:    userId    ?? this.userId,
      userName:  userName  ?? this.userName,
      content:   content   ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':        id,
      'taskId':    taskId,
      'userId':    userId,
      'userName':  userName,
      'content':   content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id:        map['id']       as String,
      taskId:    map['taskId']   as String,
      userId:    map['userId']   as String,
      userName:  map['userName'] as String,
      content:   map['content']  as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}