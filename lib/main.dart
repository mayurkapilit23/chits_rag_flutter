import 'package:chatgpt_clone/features/auth/bloc/auth_bloc.dart';
import 'package:chatgpt_clone/features/auth/repo/auth_repo.dart';
import 'package:chatgpt_clone/features/auth/repo/auth_services.dart';
import 'package:chatgpt_clone/features/gpt/bloc/gpt_bloc.dart';
import 'package:chatgpt_clone/features/gpt/repo/gpt_repo.dart';
import 'package:chatgpt_clone/features/gpt/repo/gpt_services.dart';
import 'package:chatgpt_clone/features/gpt/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/utils/app_dark_theme.dart';
import 'core/utils/app_light_theme.dart';
import 'features/theme/bloc/theme_bloc.dart';
import 'features/theme/bloc/theme_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GptBloc>(create: (_) => GptBloc(GptRepo(GptServices()))),
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(AuthRepo(AuthServices())),
        ),
        BlocProvider(create: (_) => ThemeBloc()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'KapilAI',
            debugShowCheckedModeBanner: false,
            theme: AppLightTheme.theme,
            darkTheme: AppDarkTheme.theme,
            themeMode: state.themeMode,
            // controlled by bloc
            home: HomeScreen(),
          );
        },
      ),
    );
  }
}
