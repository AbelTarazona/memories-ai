import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para gestionar las preferencias de comandos de voz
class VoicePreferences {
  static const String _keyVoicePermissionGranted = 'voice_permission_granted';
  static const String _keyVoiceOnboardingCompleted =
      'voice_onboarding_completed';

  /// Verifica si se completó el onboarding de voz
  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyVoiceOnboardingCompleted) ?? false;
  }

  /// Marca el onboarding como completado
  static Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyVoiceOnboardingCompleted, true);
  }

  /// Verifica si se otorgaron permisos de voz
  static Future<bool> hasVoicePermission() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyVoicePermissionGranted) ?? false;
  }

  /// Guarda el estado de permisos de voz
  static Future<void> setVoicePermission(bool granted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyVoicePermissionGranted, granted);
  }

  /// Resetea todas las preferencias de voz (útil para testing)
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyVoicePermissionGranted);
    await prefs.remove(_keyVoiceOnboardingCompleted);
  }
}
