import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme { light, dark, system }

class ThemeRepository {
  static const _themeKey = 'app_theme';

  Future<AppTheme> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);

    if (themeIndex == null) return AppTheme.system;
    return AppTheme.values[themeIndex];
  }

  Future<void> saveTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, theme.index);
  }
}
