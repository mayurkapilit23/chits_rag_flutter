import 'package:equatable/equatable.dart';

import '../repo/theme_repository.dart';

class ThemeState extends Equatable {
  final AppTheme theme;

  const ThemeState(this.theme);

  @override
  List<Object?> get props => [theme];
}
