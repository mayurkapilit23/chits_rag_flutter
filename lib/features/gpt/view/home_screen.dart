import 'package:chatgpt_clone/features/auth/bloc/auth_bloc.dart';
import 'package:chatgpt_clone/features/auth/bloc/auth_state.dart';
import 'package:chatgpt_clone/features/gpt/widgets/custom_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/utils/bottom_sheets.dart';
import '../../../core/utils/show_context_menu.dart';
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
  //for customChips
  void _sendMessage(String text, GptLoadedState state) {
    final message = text.trim();
    if (message.isEmpty) return;

    context.read<GptBloc>().add(
      SendUserMessageEvent(
        prompt: message,
        mobile: state.mobileNumber ?? "",
        sessionId: state.conversations[state.selectedConversationIndex].id,
      ),
    );
  }

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
    super.initState();
    context.read<AuthBloc>().add(CheckAuthStatusEvent());

    // IMPORTANT: listen to controller so setState runs on text changes
    _input.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _input.removeListener(
      () {},
    ); // harmless if listener removed, but ok to keep
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          key: const Key('home_scaffold'),
          backgroundColor: isDark
              ? AppColors.darkPrimary
              : AppColors.primaryColor,
          drawer: state is GptLoadedState ? _buildDrawer(context, state) : null,
          appBar: state is GptLoadedState || state is GptMessageSendingState
              ? AppBar(
                  leadingWidth: 64,
                  // important for spacing
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 8), // your padding
                    child: Builder(
                      builder: (context) {
                        return Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSecondary
                                : AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(
                              50,
                            ), // smooth corners
                            border: Border.all(
                              color: isDark ? Colors.grey : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            onPressed: () => Scaffold.of(context).openDrawer(),
                            icon: Icon(
                              Icons.menu,
                              color: isDark ? Colors.white : Colors.black,
                              size: 22,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  backgroundColor: isDark
                      ? AppColors.darkPrimary
                      : AppColors.primaryColor,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSecondary
                              : AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(
                            50,
                          ), // smooth corners
                          border: Border.all(
                            color: isDark ? Colors.grey : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                context.read<GptBloc>().add(
                                  CreateConversationEvent(),
                                );
                              },
                              icon: Icon(Icons.add),
                            ),
                            IconButton(
                              icon: const Icon(Icons.settings_outlined),
                              onPressed: () {
                                showSettingsBottomSheet(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : null,
          body: SafeArea(child: _buildContent(context, state)),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, GptLoadedState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authStates) {
        return Drawer(
          backgroundColor: isDark
              ? AppColors.darkPrimary
              : AppColors.primaryColor,
          child: SafeArea(
            child: Column(
              children: [
                // NEW CHAT BUTTON
                ListTile(
                  trailing: IconButton(
                    onPressed: () {
                      context.read<GptBloc>().add(CreateConversationEvent());
                      Navigator.pop(context);
                    },

                    icon: Icon(Icons.add),
                  ),
                  title: const Text(
                    'ChitsAI',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                //conversation list
                Expanded(
                  child: ListView.builder(
                    itemCount: state.conversations.length,
                    itemBuilder: (context, index) {
                      final c = state.conversations[index];
                      return GestureDetector(
                        onLongPressStart: (details) {
                          showContextMenuAtPosition(
                            context,
                            details.globalPosition,
                            index,
                          );
                        },
                        child: ListTile(
                          title: Text(
                            c.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.whiteColor
                                  : AppColors.darkPrimary,
                            ),
                          ),
                          selected: index == state.selectedConversationIndex,
                          selectedTileColor: Colors.grey.withOpacity(0.1),

                          onTap: () {
                            context.read<GptBloc>().add(
                              SelectConversationEvent(index),
                            );
                            Navigator.pop(context);
                          },

                          // trailing: IconButton(
                          //   icon: Icon(
                          //     Icons.delete,
                          //     size: 20,
                          //     color: isDark
                          //         ? AppColors.whiteColor
                          //         : AppColors.darkPrimary,
                          //   ),
                          //   onPressed: () {
                          //     context.read<GptBloc>().add(
                          //       DeleteConversationEvent(index),
                          //     );
                          //   },
                          // ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                //login/logout button
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? AppColors.primaryColor
                            : AppColors.darkSecondary,
                        foregroundColor: isDark
                            ? AppColors.darkPrimary
                            : Colors.white,

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
                        style: TextStyle(fontWeight: FontWeight.bold),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSecondary : AppColors.whiteColor,
            borderRadius: BorderRadius.circular(50),
            border: isDark
                ? Border.all(
                    color: isDark
                        ? Colors.grey.withOpacity(0.25)
                        : Colors.grey.withOpacity(0.35),
                    width: 1,
                  )
                : Border(),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
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
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    hintText: "Ask ChitsAI",
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      // fontSize: 15,
                      // color: isDark ? Colors.white : Colors.black,
                      color: Colors.grey.shade500,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              SizedBox(width: 6),

              //send button
              AnimatedSwitcher(
                duration: Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.whiteColor
                        : AppColors.darkPrimary,
                    shape: const CircleBorder(),
                  ),
                  icon: Icon(
                    Icons.arrow_upward,
                    color: isDark
                        ? AppColors.darkPrimary
                        : AppColors.whiteColor,
                  ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, GptState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ChitsAI',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.whiteColor
                                : AppColors.darkPrimary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            CustomChip(
                              // icon: Icons.flash_on_rounded,
                              text: "🛠️ Ask me about services",
                              isDark: isDark,
                              onTap: () => _sendMessage(
                                "Ask me about services",
                                loadedState!,
                              ),
                            ),
                            CustomChip(
                              text: "🤔 How chitfund works",
                              isDark: isDark,
                              onTap: () => _sendMessage(
                                "How chitfund works",
                                loadedState!,
                              ),
                            ),
                            CustomChip(
                              text: "👨🏻‍💼 Founder",
                              isDark: isDark,
                              onTap: () =>
                                  _sendMessage("Founder", loadedState!),
                            ),
                            CustomChip(
                              text: "🔄 Registration process",
                              isDark: isDark,
                              onTap: () => _sendMessage(
                                "Registration process",
                                loadedState!,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
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
              Text(state.message, textAlign: TextAlign.center),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.primaryColor
                      : AppColors.darkSecondary,
                  foregroundColor: isDark
                      ? AppColors.darkPrimary
                      : Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  context.read<GptBloc>().add(LoadInitialDataEvent());
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }
    }

    // Fallback - should not happen
    return const Center(child: Text('Unexpected state'));
  }
}
