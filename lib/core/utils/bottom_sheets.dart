import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../features/theme/bloc/theme_bloc.dart';
import '../../features/theme/bloc/theme_event.dart';
import '../../features/theme/bloc/theme_state.dart';
import '../colors/app_colors.dart';

void showSettingsBottomSheet(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  showModalBottomSheet(
    context: context,
    // backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (context) {
      return BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          bool isDarkMode = state.themeMode == ThemeMode.dark;
          return Container(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.darkSecondary
                  : AppColors.whiteColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: PhosphorIcon(PhosphorIcons.moon(), size: 20),
                    title: const Text('Dark Mode'),
                    trailing: Switch(
                      activeTrackColor: isDarkMode
                          ? AppColors.darkPrimary
                          : AppColors.darkSecondary,
                      value: isDarkMode,
                      onChanged: (value) {
                        context.read<ThemeBloc>().add(ToggleThemeEvent());
                      },
                    ),
                  ),

                  SizedBox(height: 15),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
