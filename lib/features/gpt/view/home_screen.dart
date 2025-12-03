import 'package:chatgpt_clone/features/auth/bloc/auth_bloc.dart';
import 'package:chatgpt_clone/features/auth/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';

import '../../../core/colors/app_colors.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/view/mobile_number_sheet.dart';
import '../bloc/gpt_bloc.dart';
import '../bloc/gpt_event.dart';
import '../bloc/gpt_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // UI Controllers
  final ScrollController _scroll = ScrollController();
  final TextEditingController _input = TextEditingController();

  // Track if we've shown snackbar for current error
  String? _lastShownError;

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

  void _showErrorSnackbar(BuildContext context, String message) {
    // Clear any existing snackbars first
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
    _lastShownError = message;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<AuthBloc>().add(CheckAuthStatusEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GptBloc, GptState>(
      listenWhen: (prev, curr) {
        // Listen for error state changes
        if (curr is GptErrorState) {
          return curr.message != _lastShownError;
        }

        // Clear last shown error when we leave error state
        if (prev is GptErrorState && curr is! GptErrorState) {
          _lastShownError = null;
        }

        return false;
      },
      listener: (context, state) {
        if (state is GptErrorState) {
          // Show snackbar immediately, not in post frame callback
          _showErrorSnackbar(context, state.message);
        }
      },
      builder: (context, state) {
        // Load initial data if needed
        if (state is GptInitialState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<GptBloc>().add(LoadInitialDataEvent());
          });
        }

        return Scaffold(
          key: Key('home_scaffold'),
          backgroundColor: AppColors.primaryColor,
          drawer: state is GptLoadedState ? _buildDrawer(context, state) : null,
          appBar: state is GptLoadedState || state is GptMessageSendingState
              ? AppBar(
                  backgroundColor: AppColors.primaryColor,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  actions: [
                    IconButton(
                      onPressed: () {
                        context.read<GptBloc>().add(CreateConversationEvent());
                      },
                      icon: Icon(Icons.add, size: 20),
                    ),
                    IconButton(
                      icon: Icon(Icons.settings_outlined),
                      onPressed: () {
                        _showSettingsBottomSheet(context);
                      },
                    ),
                  ],
                )
              : null,
          body: _buildContent(context, state),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, GptLoadedState state) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authStates) {
        return Drawer(
          backgroundColor: Colors.white,
          child: SafeArea(
            child: Column(
              children: [
                // NEW CHAT BUTTON
                FItem(
                  suffix: IconButton(
                    onPressed: () {
                      context.read<GptBloc>().add(CreateConversationEvent());
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.add, size: 20),
                  ),
                  title: const Text(
                    'KapilAI',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                // ListTile(
                //   leading: Icon(Icons.add),
                //   title: Text(
                //     "New Chat",
                //     style: TextStyle(fontWeight: FontWeight.bold),
                //   ),
                //   onTap: () {
                //     context.read<GptBloc>().add(CreateConversationEvent());
                //     Navigator.pop(context);
                //   },
                // ),
                const FDivider(),

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
                          context.read<AuthBloc>().add(LogoutEvent());

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

  Widget _buildContent(BuildContext context, GptState state) {
    // Loading states
    if (state is GptInitialState || state is GptLoadingState) {
      return Center(child: CircularProgressIndicator());
    }

    // Main loaded UI (also shown during error state to keep chat visible)
    if (state is GptLoadedState ||
        state is GptMessageSendingState ||
        state is GptErrorState) {
      // For error state, we still want to show the loaded UI if possible
      GptLoadedState? loadedState;
      if (state is GptLoadedState) {
        loadedState = state;
      } else if (state is GptMessageSendingState) {
        loadedState = state; // GptMessageSendingState extends GptLoadedState
      } else if (state is GptErrorState) {
        // Try to get previous loaded state from bloc state
        final blocState = context.read<GptBloc>().state;
        if (blocState is GptLoadedState) {
          loadedState = blocState;
        } else if (blocState is GptMessageSendingState) {
          loadedState = blocState;
        }
      }

      // If we have a loaded state, show the chat UI
      if (loadedState != null) {
        final conv =
            loadedState.conversations[loadedState.selectedConversationIndex];

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });

        return Column(
          children: [
            //message list
            Expanded(
              child: conv.messages.isEmpty
                  ? Center(child: Text('KapilAI'))
                  : ListView.builder(
                      controller: _scroll,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      itemCount:
                          conv.messages.length + (loadedState.isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= conv.messages.length) {
                          return TypingIndicator();
                        }
                        return MessageBubble(
                          message: conv.messages[index],
                          animate:
                              !conv.messages[index].isUser &&
                              index == conv.messages.length - 1,
                          onTextChanged: () {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollToBottom();
                            });
                          },
                        );
                      },
                    ),
            ),

            //input composer - only show if not in error state
            if (state is! GptErrorState || loadedState != null)
              _buildComposer(context, loadedState),
          ],
        );
      }

      // If we're in error state but don't have previous loaded state,
      // show the error screen
      if (state is GptErrorState) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text(
                state.message,
                // style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<GptBloc>().add(LoadInitialDataEvent());
                },
                child: Text('Retry'),
              ),
            ],
          ),
        );
      }
    }

    // Fallback - should not happen
    return Center(child: Text('Unexpected state'));
  }
}

void _showSettingsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (context) {
      bool isDarkMode = false; // You should get this from your theme provider

      return Container(
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
              FItem(
                prefix: Icon(FIcons.moon, size: 20),
                title: const Text('Dark Mode'),
                suffix: Switch(value: false, onChanged: (d) {}),
                // onPress: () {},
              ),

              SizedBox(height: 15),
            ],
          ),
        ),
      );
    },
  );
}
