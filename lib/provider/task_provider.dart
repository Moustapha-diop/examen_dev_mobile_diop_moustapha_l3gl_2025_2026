import 'package:flutter/material.dart';
import 'package:sunu_task/models/task.dart';
import 'package:sunu_task/services/storage_service.dart';

/// Gère les tâches d'un projet avec filtrage et tri
class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  TaskStatus? _statusFilter;
  TaskPriority? _priorityFilter;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  TaskStatus? get statusFilter => _statusFilter;
  TaskPriority? get priorityFilter => _priorityFilter;

  /// Retourne les tâches filtrées et triées
  List<Task> get tasks {
    var result = List<Task>.from(_tasks);

    // Filtrage
    if (_statusFilter != null) {
      result = result.where((t) => t.status == _statusFilter).toList();
    }
    if (_priorityFilter != null) {
      result = result.where((t) => t.priority == _priorityFilter).toList();
    }

    // Tri : inProgress > todo > done, puis high > medium > low
    result.sort((a, b) {
      final statusOrder = {
        TaskStatus.inProgress: 0,
        TaskStatus.todo: 1,
        TaskStatus.done: 2,
      };
      final priorityOrder = {
        TaskPriority.high: 0,
        TaskPriority.medium: 1,
        TaskPriority.low: 2,
      };

      final statusComp =
      (statusOrder[a.status] ?? 0).compareTo(statusOrder[b.status] ?? 0);
      if (statusComp != 0) return statusComp;

      return (priorityOrder[a.priority] ?? 0)
          .compareTo(priorityOrder[b.priority] ?? 0);
    });

    return result;
  }

  /// Compteur par statut (sans filtre)
  Map<TaskStatus, int> get taskCountByStatus {
    final map = <TaskStatus, int>{};
    for (final status in TaskStatus.values) {
      map[status] = _tasks.where((t) => t.status == status).length;
    }
    return map;
  }

  int get totalCount => _tasks.length;

  /// Charger les tâches d'un projet
  Future<void> loadTasks(String projectId) async {
    _isLoading = true;
    notifyListeners();

    _tasks = await StorageService.instance.getTasksByProjectId(projectId);

    _isLoading = false;
    notifyListeners();
  }

  /// Charger toutes les tâches d'un utilisateur
  Future<void> loadTasksByUser(String userId) async {
    _isLoading = true;
    notifyListeners();

    _tasks = await StorageService.instance.getTasksByUserId(userId);

    _isLoading = false;
    notifyListeners();
  }

  /// Créer une tâche
  Future<void> createTask(Task task) async {
    await StorageService.instance.saveTask(task);
    _tasks.add(task);
    notifyListeners();
  }

  /// Modifier une tâche
  Future<void> updateTask(Task task) async {
    await StorageService.instance.saveTask(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  /// Supprimer une tâche
  Future<void> deleteTask(String taskId) async {
    await StorageService.instance.deleteTask(taskId);
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

  /// Changer rapidement le statut d'une tâche
  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index >= 0) {
      final updated = _tasks[index].copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      await StorageService.instance.saveTask(updated);
      _tasks[index] = updated;
      notifyListeners();
    }
  }

  // ======== Filtres =========

  void setStatusFilter(TaskStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setPriorityFilter(TaskPriority? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  void clearFilters() {
    _statusFilter = null;
    _priorityFilter = null;
    notifyListeners();
  }
}
