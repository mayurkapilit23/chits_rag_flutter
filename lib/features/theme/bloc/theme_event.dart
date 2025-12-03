import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
}

class LoadThemeEvent extends ThemeEvent {
  const LoadThemeEvent();
  @override
  List<Object?> get props => [];
}

class ToggleThemeEvent extends ThemeEvent {
  const ToggleThemeEvent();
  @override
  List<Object?> get props => [];
}

class SetThemeEvent extends ThemeEvent {
  final ThemeMode themeMode;
  const SetThemeEvent(this.themeMode);
  @override
  List<Object?> get props => [themeMode];
}
