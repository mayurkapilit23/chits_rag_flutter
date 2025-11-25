import 'package:flutter/material.dart';

import '../../../core/colors/app_colors.dart';
import '../../../main.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final bubbleColor = isUser ? AppColors.userBubbleColor : Colors.transparent;
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
          // if (!isUser) ...[
          //   Padding(
          //     padding: const EdgeInsets.only(right: 8.0),
          //     child: CircleAvatar(child: Icon(Icons.smart_toy, size: 18)),
          //   ),
          // ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(50),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.black12,
                    //     offset: Offset(0, 2),
                    //     blurRadius: 6,
                    //   ),
                    // ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: SelectableText(
                    message.text,
                    style: TextStyle(color: textColor, fontSize: 15),
                  ),
                ),
                // SizedBox(height: 4),
                // Text(
                //   _formatTime(message.time),
                //   style: TextStyle(fontSize: 11, color: Colors.grey),
                // ),
              ],
            ),
          ),
          // if (isUser) ...[
          //   SizedBox(width: 8),
          //   CircleAvatar(child: Text('Y')), // Y for you
          // ],
        ],
      ),
    );
  }

  static String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
