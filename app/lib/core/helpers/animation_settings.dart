import 'package:shared_preferences/shared_preferences.dart';

class AnimationSettings {
  AnimationSettings._();

  static const String _homeAnimationKey = 'settings_home_animation_enabled';
  static const String _detailAnimationKey =
      'settings_memory_detail_animation_enabled';

  static Future<bool> isHomeAnimationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_homeAnimationKey) ?? true;
  }

  static Future<void> setHomeAnimationEnabled(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_homeAnimationKey, isEnabled);
  }

  static Future<bool> isMemoryDetailAnimationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_detailAnimationKey) ?? true;
  }

  static Future<void> setMemoryDetailAnimationEnabled(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_detailAnimationKey, isEnabled);
  }
}
