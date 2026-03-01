import 'package:flutter/material.dart';
import 'package:sunu_task/models/project.dart';
import 'package:sunu_task/services/storage_service.dart';

/// Gère la collection de projets de l'utilisateur
class ProjectProvider extends ChangeNotifier {
  List<Project> _projects = [];
  Project? _selectedProject;
  bool _isLoading = false;

  List<Project> get projects => List.unmodifiable(_projects);
  Project? get selectedProject => _selectedProject;
  int get projectCount => _projects.length;
  bool get isLoading => _isLoading;

  /// Charger les projets d'un utilisateur
  Future<void> loadProjects(String userId) async {
    _isLoading = true;
    notifyListeners();

    _projects = await StorageService.instance.getProjectsByUserId(userId);

    _isLoading = false;
    notifyListeners();
  }

  /// Créer un projet
  Future<void> createProject(Project project) async {
    await StorageService.instance.saveProject(project);
    _projects.add(project);
    notifyListeners();
  }

  /// Modifier un projet
  Future<void> updateProject(Project project) async {
    await StorageService.instance.saveProject(project);
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index >= 0) {
      _projects[index] = project;
      // Mettre à jour le projet sélectionné si c'est le même
      if (_selectedProject?.id == project.id) {
        _selectedProject = project;
      }
      notifyListeners();
    }
  }

  /// Supprimer un projet (et ses tâches via StorageService)
  Future<void> deleteProject(String projectId) async {
    await StorageService.instance.deleteProject(projectId);
    _projects.removeWhere((p) => p.id == projectId);
    if (_selectedProject?.id == projectId) {
      _selectedProject = null;
    }
    notifyListeners();
  }

  /// Sélectionner un projet (pour la navigation)
  void selectProject(Project? project) {
    _selectedProject = project;
    notifyListeners();
  }
}
