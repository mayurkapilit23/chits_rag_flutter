import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/colors/app_colors.dart';
import '../model/message.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final bool animate;
  final VoidCallback? onTextChanged;

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
  late List<String> _words;
  int _visibleWordCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _words = widget.message.text.split(' ');

    final shouldAnimate =
        widget.animate && !widget.message.isUser && !widget.message.hasAnimated;

    if (shouldAnimate) {
      _startWordFade();
    } else {
      _visibleWordCount = _words.length;
    }
  }

  void _startWordFade() {
    _timer = Timer.periodic(
      const Duration(milliseconds: 70), // 👈 speed
      (timer) {
        if (_visibleWordCount < _words.length) {
          setState(() => _visibleWordCount++);
          widget.onTextChanged?.call(); // auto-scroll
        } else {
          widget.message.hasAnimated = true;
          timer.cancel();
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = widget.message.isUser;

    final bubbleColor = isUser
        ? (isDark ? AppColors.darkSecondary : Colors.grey.shade200)
        // : (isDark ? Colors.grey.shade800 : Colors.grey.shade300);
        : (isDark ? Colors.transparent : Colors.transparent);

    final textColor = isUser
        ? (isDark ? Colors.white : Colors.black)
        : (isDark ? Colors.white : Colors.black);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Wrap(
                children: List.generate(_visibleWordCount, (index) {
                  return _DelayedFadeWord(
                    word: _words[index],
                    delay: Duration(milliseconds: index * 30), //  stagger delay
                    textColor: textColor,
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DelayedFadeWord extends StatefulWidget {
  final String word;
  final Duration delay;
  final Color textColor;

  const _DelayedFadeWord({
    required this.word,
    required this.delay,
    required this.textColor,
  });

  @override
  State<_DelayedFadeWord> createState() => _DelayedFadeWordState();
}

class _DelayedFadeWordState extends State<_DelayedFadeWord> {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();

    Future.delayed(widget.delay, () {
      if (mounted) {
        setState(() => _opacity = 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Text(
        '${widget.word} ',
        style: TextStyle(
          fontSize: 16,
          height: 1.4,
          color: widget.textColor,
          fontFamily: 'SegoeUI',
        ),
      ),
    );
  }
}
