import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:sunu_task/models/User.dart';
import 'package:sunu_task/services/storage_service.dart';

/// Gère l'authentification et la session utilisateur
class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Charge l'utilisateur depuis le stockage (au démarrage)
  Future<void> init() async {
    _currentUser = StorageService.instance.getCurrentUser();
    notifyListeners();
  }

  /// Connexion
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final users = await StorageService.instance.getUsers();
      final user = users.where(
            (u) => u.email.toLowerCase() == email.toLowerCase() &&
            u.password == password,
      ).firstOrNull;

      if (user != null) {
        _currentUser = user;
        await StorageService.instance.saveCurrentUser(user);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Email ou mot de passe incorrect';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Une erreur est survenue';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Inscription
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Vérifier si l'email existe déjà
      final users = await StorageService.instance.getUsers();
      final exists = users.any(
            (u) => u.email.toLowerCase() == email.toLowerCase(),
      );

      if (exists) {
        _error = 'Un compte existe déjà avec cet email';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Créer le nouvel utilisateur
      final newUser = User(
        id: const Uuid().v4(),
        name: name,
        email: email,
        password: password,
      );

      await StorageService.instance.saveUser(newUser);
      await StorageService.instance.saveCurrentUser(newUser);
      _currentUser = newUser;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Une erreur est survenue';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    await StorageService.instance.clearCurrentUser();
    _currentUser = null;
    notifyListeners();
  }

  /// Mise à jour du profil
  Future<void> updateProfile({String? name, String? email}) async {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(name: name, email: email);
    await StorageService.instance.saveUser(updated);
    await StorageService.instance.saveCurrentUser(updated);
    _currentUser = updated;
    notifyListeners();
  }

  /// Efface le message d'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
