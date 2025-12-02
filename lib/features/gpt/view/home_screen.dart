import 'package:chatgpt_clone/features/auth/bloc/auth_bloc.dart';
import 'package:chatgpt_clone/features/auth/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/colors/app_colors.dart';
import '../../auth/models/session_manager.dart';
import '../../auth/view/mobile_number_sheet.dart';
import '../bloc/gpt_bloc.dart';
import '../bloc/gpt_event.dart';
import '../bloc/gpt_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // UI Controllers
  final ScrollController _scroll = ScrollController();

  final TextEditingController _input = TextEditingController();

  void _scrollToBottom() {
    if (_scroll.hasClients) {
      Future.delayed(Duration(milliseconds: 100), () {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GptBloc, GptState>(
      listenWhen: (prev, curr) {
        // Only scroll when the messages list grows
        if (prev is GptLoadedState && curr is GptLoadedState) {
          final prevCount = prev
              .conversations[prev.selectedConversationIndex]
              .messages
              .length;
          final currCount = curr
              .conversations[curr.selectedConversationIndex]
              .messages
              .length;

          return currCount > prevCount; // scroll only on new message
        }
        return false;
      },
      listener: (context, state) {
        if (state is GptErrorState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
              ),
            );
          });
        }
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      },
      builder: (context, state) {
        if (state is GptInitialState) {
          context.read<GptBloc>().add(LoadInitialDataEvent());
          return Scaffold(
            backgroundColor: AppColors.primaryColor,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is GptLoadingState) {
          return Scaffold(
            backgroundColor: AppColors.primaryColor,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        //error state - show snackbar but keep UI visible

        //loaded state (main UI) - also shown when error occurs
        if (state is GptLoadedState || state is GptMessageSendingState) {
          // WidgetsBinding.instance.addPostFrameCallback(
          //   (_) => ,
          // );
          _scrollToBottom();
          final loaded = state as GptLoadedState;
          final conv = loaded.conversations[loaded.selectedConversationIndex];
          return Scaffold(
            backgroundColor: AppColors.primaryColor,
            drawer: _buildDrawer(context, loaded),
            appBar: AppBar(
              backgroundColor: AppColors.primaryColor,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: Icon(Icons.settings_outlined),
                  onPressed: () {},
                ),
              ],
            ),

            // body
            body: Column(
              children: [
                //message list
                Expanded(
                  child: ListView.builder(
                    controller: _scroll,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    itemCount: conv.messages.length + (loaded.isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= conv.messages.length) {
                        return TypingIndicator();
                      }
                      // return MessageBubble(message: conv.messages[index]);

                      return MessageBubble(
                        message: conv.messages[index],
                        animate:
                            !conv.messages[index].isUser &&
                            index == conv.messages.length - 1,
                        onTextChanged: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToBottom(); // ← instantly scroll while animating
                          });
                        },
                      );
                    },
                  ),
                ),

                //input composer
                _buildComposer(context, loaded),
              ],
            ),
          );
        }

        return SizedBox.shrink();
      },
    );
  }

  //drawer ui
  Widget _buildDrawer(BuildContext context, GptLoadedState state) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authStates) {
        return Drawer(
          backgroundColor: Colors.white,
          child: SafeArea(
            child: Column(
              children: [
                // NEW CHAT BUTTON
                ListTile(
                  leading: Icon(Icons.add),
                  title: Text(
                    "New Chat",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    context.read<GptBloc>().add(CreateConversationEvent());
                    Navigator.pop(context);
                  },
                ),

                Divider(),

                //conversation list
                Expanded(
                  child: ListView.builder(
                    itemCount: state.conversations.length,
                    itemBuilder: (context, index) {
                      final c = state.conversations[index];
                      return ListTile(
                        title: Text(
                          c.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        selected: index == state.selectedConversationIndex,
                        selectedTileColor: Colors.grey.withOpacity(0.15),

                        onTap: () {
                          context.read<GptBloc>().add(
                            SelectConversationEvent(index),
                          );
                          Navigator.pop(context);
                        },

                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline),
                          onPressed: () {
                            context.read<GptBloc>().add(
                              DeleteConversationEvent(index),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 16),

                //login/logout button
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        if (authStates is AuthenticatedState) {
                          // LOGOUT
                          await SessionManager.logout();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Logged out successfully")),
                          );

                          // Reload state
                          context.read<GptBloc>().add(LoadInitialDataEvent());
                        } else {
                          // LOGIN (open mobile input sheet)
                          showMobileNumberSheet(context);
                        }
                      },
                      child: Text(
                        authStates is AuthenticatedState ? 'Logout' : 'Login',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //message input bar
  Widget _buildComposer(BuildContext context, GptLoadedState state) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _input,
                  minLines: 1,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: "Ask ChatGPT...",
                    border: InputBorder.none,
                  ),
                ),
              ),

              SizedBox(width: 6),

              //send button
              IconButton(
                icon: Icon(Icons.send, color: Colors.black),
                onPressed: () {
                  final text = _input.text.trim();
                  if (text.isEmpty) return;

                  context.read<GptBloc>().add(
                    SendUserMessageEvent(
                      prompt: text,
                      mobile: state.mobileNumber ?? "",
                      sessionId: state
                          .conversations[state.selectedConversationIndex]
                          .id,
                    ),
                  );

                  _input.clear();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
