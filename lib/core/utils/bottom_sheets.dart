import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../features/theme/bloc/theme_bloc.dart';
import '../../features/theme/bloc/theme_event.dart';
import '../../features/theme/bloc/theme_state.dart';
import '../../features/theme/repo/theme_repository.dart';
import '../colors/app_colors.dart';

void showSettingsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (context) {
      return BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final isDark =
              context.watch<ThemeBloc>().state.theme == AppTheme.dark;
          return Container(
            decoration: BoxDecoration(
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
                    trailing: CupertinoSwitch(
                      inactiveThumbColor: Colors.grey.shade400,
                      inactiveTrackColor: Colors.grey.shade300,

                      thumbColor: isDark
                          ? AppColors.whiteColor
                          : AppColors.darkSecondary,
                      activeTrackColor: isDark
                          ? AppColors.darkPrimary
                          : AppColors.darkSecondary,
                      value: isDark,
                      onChanged: (value) {
                        context.read<ThemeBloc>().add(
                          ToggleTheme(value ? AppTheme.dark : AppTheme.light),
                        );
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
