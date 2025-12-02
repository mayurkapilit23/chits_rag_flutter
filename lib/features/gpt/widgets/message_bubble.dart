import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

import '../model/message.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final VoidCallback? onTextChanged;

  final bool animate; // only last bot message should animate

  const MessageBubble({
    super.key,
    required this.message,
    this.animate = false,
    this.onTextChanged,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _hasAnimated = false;
  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.isUser;

    final bubbleColor = isUser ? Color(0xFFE9F2FE) : Colors.grey.shade200;

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
                  // constrain width so long messages wrap instead of
                  // causing layout issues or bleeding into other bubbles
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.72,
                    ),
                    child: MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(textScaleFactor: 1.0),
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.4,
                          color: textColor,
                        ),
                        child: _buildMessageContent(context, textColor, isUser),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(
    BuildContext context,
    Color? textColor,
    bool isUser,
  ) {
    // USER MESSAGE → NORMAL TEXT
    if (widget.message.isUser || !widget.animate || _hasAnimated) {
      return SelectableText(
        widget.message.text,
        textAlign: isUser ? TextAlign.right : TextAlign.left,
        style: TextStyle(color: textColor, fontSize: 16, height: 1.4),
        // allow wrapping for long prompts
        maxLines: null,
      );
    }

    // BOT MESSAGE (last one only) → TYPEWRITER
    return RepaintBoundary(
      child: AnimatedTextKit(
        key: ValueKey(widget.message.id),
        totalRepeatCount: 1,
        isRepeatingAnimation: false,
        displayFullTextOnTap: true,
        animatedTexts: [
          TypewriterAnimatedText(
            widget.message.text,
            textStyle: TextStyle(color: textColor, fontSize: 16, height: 1.4),
            speed: const Duration(milliseconds: 30),
            cursor: "",
          ),
        ],
        // wrap/align the animated text inside an Align so it respects
        // the bubble's constrained width and the message side
        onFinished: () {
          widget.onTextChanged?.call();
          setState(() => _hasAnimated = true);
        },
        onNext: (_, __) {
          widget.onTextChanged?.call(); // 🔥 SCROLL DURING ANIMATION
        },
      ),
    );
  }
}
