import 'package:flutter/material.dart';

class FadeDot extends AnimatedWidget {
  const FadeDot({super.key, required Animation<double> animation})
    : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final animation = listenable as Animation<double>;
    return Opacity(
      opacity: animation.value,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
