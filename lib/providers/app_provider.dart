import 'package:flutter/material.dart';
import 'package:sunu_task/services/storage_service.dart';

/// Gère l'état global de l'application (initialisation, onboarding)
class AppProvider extends ChangeNotifier {
  bool _isOnboardingComplete = false;
  bool _isInitialized = false;
  bool _isLoading = false;

  bool get isOnboardingComplete => _isOnboardingComplete;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  /// Charge l'état depuis StorageService
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _isOnboardingComplete = StorageService.instance.isOnboardingComplete;
    _isInitialized = true;

    _isLoading = false;
    notifyListeners();
  }

  /// Marque l'onboarding comme terminé
  Future<void> completeOnboarding() async {
    await StorageService.instance.setOnboardingComplete(true);
    _isOnboardingComplete = true;
    notifyListeners();
  }

  /// Réinitialise l'onboarding (utile pour les tests)
  Future<void> resetOnboarding() async {
    await StorageService.instance.setOnboardingComplete(false);
    _isOnboardingComplete = false;
    notifyListeners();
  }
}
