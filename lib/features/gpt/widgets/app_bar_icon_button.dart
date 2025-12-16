import 'package:flutter/material.dart';

class AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const AppBarIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: Colors.transparent,
        // shape: CircleBorder(
        //   side: isDark
        //       ? const BorderSide(color: Colors.redAccent, width: 1)
        //       : BorderSide.none,
        // ),
        child: Row(
          children: [
            InkWell(
              // customBorder: const CircleBorder(),
              onTap: onPressed,
              child: Padding(
                padding: EdgeInsets.all(10), // 👈 equal inner padding
                child: Icon(icon, size: 22),
              ),
            ),
            InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: Padding(
                padding: EdgeInsets.all(10), // 👈 equal inner padding
                child: Icon(icon, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
