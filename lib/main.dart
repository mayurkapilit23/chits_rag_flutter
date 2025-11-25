import 'package:chatgpt_clone/features/auth/bloc/auth_bloc.dart';
import 'package:chatgpt_clone/features/auth/repo/auth_repo.dart';
import 'package:chatgpt_clone/features/auth/repo/auth_services.dart';
import 'package:chatgpt_clone/features/gpt/bloc/gpt_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'features/auth/repo/auth_local_storage.dart';
import 'features/gpt/view/home_screen.dart';

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
    final AuthServices api = AuthServices();
    final AuthLocalStorage storage = AuthLocalStorage();
    return MultiBlocProvider(
      providers: [
        BlocProvider<GptBloc>(create: (_) => GptBloc()),
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(AuthRepo(api: api, storage: storage)),
        ),
      ],
      child: MaterialApp(
        title: 'GPT',
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          fontFamily: GoogleFonts.poppins().fontFamily,
          brightness: Brightness.light,
          primarySwatch: Colors.indigo,
          inputDecorationTheme: InputDecorationTheme(border: InputBorder.none),
        ),
        home: HomePage(),
      ),
    );
  }
}

// Simple message model
class Message {
  final String id;
  final String text;
  final DateTime time;
  final bool isUser;

  Message({
    required this.id,
    required this.text,
    required this.time,
    required this.isUser,
  });
}

class Conversation {
  final String id;
  final String title;
  final List<Message> messages;

  Conversation({required this.id, required this.title, required this.messages});
}
