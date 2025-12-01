import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

import '../model/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool animate; // only last bot message should animate

  const MessageBubble({super.key, required this.message, this.animate = false});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    final bubbleColor = Colors.grey.shade200;

    final textColor = isUser
        ? Colors.black
        : Theme.of(context).textTheme.bodyLarge?.color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0, 0.2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: _buildMessageContent(textColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(Color? textColor) {
    // USER MESSAGE → NORMAL TEXT
    if (message.isUser || !animate) {
      return SelectableText(
        message.text,
        style: TextStyle(color: textColor, fontSize: 15, height: 1.4),
      );
    }

    // BOT MESSAGE (last one only) → TYPEWRITER
    return AnimatedTextKit(
      key: ValueKey("bot-${message.id}-${message.text.length}"),
      isRepeatingAnimation: false,
      displayFullTextOnTap: true,
      animatedTexts: [
        TypewriterAnimatedText(
          message.text,
          textStyle: TextStyle(color: textColor, fontSize: 15, height: 1.4),
          speed: const Duration(milliseconds: 40),
          cursor: "|",
        ),
      ],
    );
  }
}
