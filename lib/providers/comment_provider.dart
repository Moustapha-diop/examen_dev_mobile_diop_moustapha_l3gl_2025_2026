import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:sunu_task/models/comment.dart';
import 'package:sunu_task/services/storage_service.dart';

/// Gère les commentaires d'une tâche
class CommentProvider extends ChangeNotifier {
  List<Comment> _comments = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  /// Triés du plus récent au plus ancien
  List<Comment> get comments {
    final sorted = List<Comment>.from(_comments);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(sorted);
  }

  /// Nombre de commentaires
  int get commentCount => _comments.length;

  /// Charger les commentaires d'une tâche
  Future<void> loadComments(String taskId) async {
    _isLoading = true;
    notifyListeners();

    _comments = await StorageService.instance.getCommentsByTaskId(taskId);

    _isLoading = false;
    notifyListeners();
  }

  /// Ajouter un commentaire
  Future<void> addComment({
    required String taskId,
    required String userId,
    required String userName,
    required String content,
  }) async {
    final comment = Comment(
      id:       const Uuid().v4(),
      taskId:   taskId,
      userId:   userId,
      userName: userName,
      content:  content,
    );

    await StorageService.instance.saveComment(comment);
    _comments.add(comment);
    notifyListeners();
  }

  /// Supprimer un commentaire
  Future<void> deleteComment(String commentId) async {
    await StorageService.instance.deleteComment(commentId);
    _comments.removeWhere((c) => c.id == commentId);
    notifyListeners();
  }
}