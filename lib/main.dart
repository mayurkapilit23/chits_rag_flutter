import 'package:chatgpt_clone/features/auth/bloc/auth_bloc.dart';
import 'package:chatgpt_clone/features/auth/repo/auth_repo.dart';
import 'package:chatgpt_clone/features/auth/repo/auth_services.dart';
import 'package:chatgpt_clone/features/gpt/bloc/gpt_bloc.dart';
import 'package:chatgpt_clone/features/gpt/repo/gpt_repo.dart';
import 'package:chatgpt_clone/features/gpt/repo/gpt_services.dart';
import 'package:chatgpt_clone/features/gpt/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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
      ],
      child: MaterialApp(
        title: 'KapilAI',
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          fontFamily: GoogleFonts.roboto().fontFamily,
          brightness: Brightness.light,
          inputDecorationTheme: InputDecorationTheme(border: InputBorder.none),
        ),
        home: HomeScreen(),
      ),
    );
  }
}
