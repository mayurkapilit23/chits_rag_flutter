import 'dart:math';

import 'package:chatgpt_clone/features/auth/view/login_page.dart';
import 'package:chatgpt_clone/features/gpt/widgets/typing_indicator.dart';
import 'package:flutter/material.dart';

import '../../../core/colors/app_colors.dart';
import '../../../main.dart';
import '../widgets/message_bubble.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final List<Conversation> _conversations = List.generate(
    6,
    (i) => Conversation(
      id: 'conv_$i',
      title: i == 0 ? 'General' : 'Conversation ${i + 1}',
      messages: _sampleMessages(i == 0),
    ),
  );

  int _selectedConversationIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // scroll to bottom when first built
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    final conv = _conversations[_selectedConversationIndex];
    final msg = Message(
      id: UniqueKey().toString(),
      text: text.trim(),
      time: DateTime.now(),
      isUser: true,
    );
    setState(() {
      conv.messages.add(msg);
      _isTyping = true; // simulate assistant thinking
      _textController.clear();
    });
    _scrollToBottom();

    // Simulate assistant reply after a short delay (replace with API call)
    Future.delayed(Duration(milliseconds: 800 + Random().nextInt(900)), () {
      final reply = Message(
        id: UniqueKey().toString(),
        text: _autoReplyFor(text),
        time: DateTime.now(),
        isUser: false,
      );
      setState(() {
        conv.messages.add(reply);
        _isTyping = false;
      });
      _scrollToBottom();
    });
  }

  void _createNewConversation() {
    setState(() {
      final newConv = Conversation(
        id: 'conv_${_conversations.length}',
        title: 'Conversation ${_conversations.length + 1}',
        messages: [],
      );
      _conversations.insert(0, newConv);
      _selectedConversationIndex = 0;
    });
    Navigator.of(context).pop();
  }

  void _selectConversation(int idx) {
    setState(() {
      _selectedConversationIndex = idx;
    });
    Navigator.of(context).maybePop();
    // scroll to bottom after small delay
    Future.delayed(Duration(milliseconds: 150), _scrollToBottom);
  }

  void _deleteConversation(int idx) {
    if (_conversations.length <= 1) return;
    setState(() {
      _conversations.removeAt(idx);
      _selectedConversationIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final conv = _conversations[_selectedConversationIndex];
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'ChatGPT',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),

                    // IconButton(
                    //   icon: Icon(Icons.edit_document),
                    //   onPressed: widget.onToggleTheme,
                    // ),
                    IconButton(
                      icon: Icon(Icons.edit_document),
                      onPressed: _createNewConversation,
                    ),
                  ],
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 12.0),
              //   child: ElevatedButton.icon(
              //     onPressed: _createNewConversation,
              //     icon: Icon(Icons.add),
              //     label: Text('New chat'),
              //   ),
              // ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  itemCount: _conversations.length,
                  itemBuilder: (context, index) {
                    final c = _conversations[index];
                    return ListTile(
                      title: Text(
                        c.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.black),
                      ),
                      // subtitle: c.messages.isNotEmpty
                      //     ? Text(_previewText(c.messages.last.text))
                      //     : Text('No messages yet.'),
                      selected: index == _selectedConversationIndex,
                      selectedTileColor: Colors.indigo.withOpacity(0.15),

                      onTap: () => _selectConversation(index),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Colors.black,
                        ),
                        onPressed: () => _deleteConversation(index),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              Ink(
                padding: EdgeInsets.symmetric(horizontal: 10),
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LoginPage()),
                    );
                  },
                  child: Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined),
            onPressed: () => _showSettingsSheet(),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: AppColors.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  Expanded(
                    child: conv.messages.isEmpty
                        ? Center(
                            child: Text(
                              'What can I help with?',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.only(top: 12, bottom: 12),
                            itemCount:
                                conv.messages.length + (_isTyping ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= conv.messages.length) {
                                // typing indicator
                                return TypingIndicator();
                              }
                              final message = conv.messages[index];
                              return MessageBubble(message: message);
                            },
                          ),
                  ),
                  // Divider(height: 1),
                  _buildComposer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Row(
          children: [
            IconButton(
              style: IconButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.black,
                shadowColor: Colors.black.withOpacity(0.3),
                elevation: 8, // smooth shadow
              ),
              icon: Icon(Icons.add, size: 30),
              onPressed: _showAttachmentSheet,
            ),

            SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02), // soft shadow
                      blurRadius: 5,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        minLines: 1,
                        maxLines: 6,
                        decoration: InputDecoration(
                          hintText: 'Ask ChatGPT',
                          hintStyle: TextStyle(color: Colors.grey),
                          isDense: true, // reduces height
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 5, // reduce here
                            horizontal: 10,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),

                    // if (_textController.text.isEmpty) ...[
                    //   IconButton(icon: Icon(Icons.mic_none), onPressed: () {}),
                    // ] else
                    //   ...[],
                    Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                        style: IconButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black,
                        ),
                        icon: Icon(Icons.arrow_upward),
                        onPressed: () => _sendMessage(_textController.text),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // SizedBox(width: 5),
            // FloatingActionButton(
            //   heroTag: 'send_btn',
            //   mini: true,
            //   onPressed: () => _sendMessage(_textController.text),
            //   child: Icon(Icons.send),
            // ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentSheet() {
    showModalBottomSheet(
      backgroundColor: AppColors.primaryColor,
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.image),
              title: Text('Image'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.insert_drive_file),
              title: Text('File'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.cancel),
              title: Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      backgroundColor: AppColors.primaryColor,
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ListTile(
            //   leading: Icon(Icons.palette_outlined),
            //   title: Text('Theme'),
            //   subtitle: Text('Toggle light / dark mode'),
            //   trailing: Switch(
            //     value: widget.themeMode == ThemeMode.dark,
            //     onChanged: (_) => widget.onToggleTheme(),
            //   ),
            // ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Clear conversation'),
              onTap: () {
                setState(() {
                  _conversations[_selectedConversationIndex].messages.clear();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.close),
              title: Text('Close'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  static List<Message> _sampleMessages(bool withContent) {
    if (!withContent) return [];
    return [
      Message(
        id: 'm1',
        text: 'Hello! How can I help you today?',
        time: DateTime.now().subtract(Duration(minutes: 7)),
        isUser: false,
      ),
      Message(
        id: 'm2',
        text:
            'I want to build a Flutter app similar to ChatGPT. Can you show me the UI?',
        time: DateTime.now().subtract(Duration(minutes: 6)),
        isUser: true,
      ),
      Message(
        id: 'm3',
        text:
            'Absolutely — I can help with a UI and connect it to an API. What features do you want?',
        time: DateTime.now().subtract(Duration(minutes: 5)),
        isUser: false,
      ),
    ];
  }

  static String _autoReplyFor(String input) {
    // Simple canned reply generator for demo purposes.
    if (input.toLowerCase().contains('flutter'))
      return 'Nice — Flutter is a great choice! I can give you code, UI patterns, and tips.';
    if (input.trim().length < 10) return 'Could you provide a bit more detail?';
    return 'Here is a short mock reply that simulates the assistant responding to your message: "${input.trim()}"';
  }

  static String _previewText(String text) {
    return text.length > 40 ? text.substring(0, 40) + '...' : text;
  }
}
