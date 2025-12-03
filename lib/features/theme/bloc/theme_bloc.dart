import 'package:chatgpt_clone/features/theme/bloc/theme_event.dart';
import 'package:chatgpt_clone/features/theme/bloc/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _prefKey = "isDarkMode";

  ThemeBloc() : super(const ThemeState(themeMode: ThemeMode.system)) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<ToggleThemeEvent>(_onToggleTheme);
    on<SetThemeEvent>(_onSetTheme);

    add(LoadThemeEvent()); // Load theme at app start
  }

  Future<void> _onLoadTheme(
    LoadThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_prefKey);

    if (isDark == null) {
      emit(state.copyWith(themeMode: ThemeMode.system));
    } else {
      emit(
        state.copyWith(themeMode: isDark ? ThemeMode.dark : ThemeMode.light),
      );
    }
  }

  Future<void> _onToggleTheme(
    ToggleThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final newMode = state.themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_prefKey, newMode == ThemeMode.dark);

    emit(state.copyWith(themeMode: newMode));
  }

  Future<void> _onSetTheme(
    SetThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_prefKey, event.themeMode == ThemeMode.dark);

    emit(state.copyWith(themeMode: event.themeMode));
  }
}
