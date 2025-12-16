import 'package:equatable/equatable.dart';

import '../repo/theme_repository.dart';

abstract class ThemeEvent extends Equatable {}

class LoadTheme extends ThemeEvent {
  @override
  List<Object?> get props => [];
}

class ToggleTheme extends ThemeEvent {
  final AppTheme theme;
  ToggleTheme(this.theme);
  @override
  List<Object?> get props => [theme];
}
