import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunu_task/models/project.dart';
import 'package:sunu_task/models/task.dart';
import 'package:sunu_task/models/User.dart';

class StorageService {
  // ===== Singleton ==========
  static StorageService? _instance;

  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  StorageService._();

  // ===== SharedPreferences ==========
  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // ======== Clés de Stockage =========
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyCurrentUser = 'current_user';
  static const String _keyUsers = 'users';
  static const String _keyProjects = 'projects';
  static const String _keyTasks = 'tasks';

  // ======== Onboarding =========

  bool get isOnboardingComplete {
    return _prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(_keyOnboardingComplete, value);
  }

  // ======== Utilisateur courant =========

  Future<void> saveCurrentUser(User user) async {
    await _prefs.setString(_keyCurrentUser, jsonEncode(user.toMap()));
  }

  User? getCurrentUser() {
    final json = _prefs.getString(_keyCurrentUser);
    if (json == null) return null;
    try {
      return User.fromMap(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearCurrentUser() async {
    await _prefs.remove(_keyCurrentUser);
  }

  // ======== Utilisateurs =========

  Future<List<User>> getUsers() async {
    final json = _prefs.getString(_keyUsers);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((e) => User.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveUser(User user) async {
    final users = await getUsers();
    final index = users.indexWhere((u) => u.id == user.id);
    if (index >= 0) {
      users[index] = user;
    } else {
      users.add(user);
    }
    await _prefs.setString(
      _keyUsers,
      jsonEncode(users.map((u) => u.toMap()).toList()),
    );
  }

  // ======== Projets =========

  Future<List<Project>> getProjects() async {
    final json = _prefs.getString(_keyProjects);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((e) => Project.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Project>> getProjectsByUserId(String userId) async {
    final projects = await getProjects();
    return projects.where((p) => p.userId == userId).toList();
  }

  Future<void> saveProject(Project project) async {
    final projects = await getProjects();
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index >= 0) {
      projects[index] = project;
    } else {
      projects.add(project);
    }
    await _prefs.setString(
      _keyProjects,
      jsonEncode(projects.map((p) => p.toMap()).toList()),
    );
  }

  Future<void> deleteProject(String projectId) async {
    final projects = await getProjects();
    projects.removeWhere((p) => p.id == projectId);
    await _prefs.setString(
      _keyProjects,
      jsonEncode(projects.map((p) => p.toMap()).toList()),
    );
    // Supprimer aussi toutes les tâches du projet
    await deleteTasksByProjectId(projectId);
  }

  // ======== Tâches =========

  Future<List<Task>> getTasks() async {
    final json = _prefs.getString(_keyTasks);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((e) => Task.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Task>> getTasksByProjectId(String projectId) async {
    final tasks = await getTasks();
    return tasks.where((t) => t.projectId == projectId).toList();
  }

  Future<List<Task>> getTasksByUserId(String userId) async {
    final tasks = await getTasks();
    return tasks.where((t) => t.userId == userId).toList();
  }

  Future<void> saveTask(Task task) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      tasks[index] = task;
    } else {
      tasks.add(task);
    }
    await _prefs.setString(
      _keyTasks,
      jsonEncode(tasks.map((t) => t.toMap()).toList()),
    );
  }

  Future<void> deleteTask(String taskId) async {
    final tasks = await getTasks();
    tasks.removeWhere((t) => t.id == taskId);
    await _prefs.setString(
      _keyTasks,
      jsonEncode(tasks.map((t) => t.toMap()).toList()),
    );
  }

  Future<void> deleteTasksByProjectId(String projectId) async {
    final tasks = await getTasks();
    tasks.removeWhere((t) => t.projectId == projectId);
    await _prefs.setString(
      _keyTasks,
      jsonEncode(tasks.map((t) => t.toMap()).toList()),
    );
  }
}