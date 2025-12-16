import 'package:flutter/material.dart';

class CustomChip extends StatelessWidget {
  const CustomChip({
    super.key,
    required this.text,
    required this.isDark,
    this.onTap,
  });

  final String text;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // screen width buckets
        final bool isLarge = constraints.maxWidth > 400;

        // final double iconSize = isLarge ? 20 : 16;
        final double fontSize = isLarge ? 14 : 12;
        final double horizontalPadding = isLarge ? 14 : 10;
        final double verticalPadding = isLarge ? 10 : 8;
        // final double spacing = isLarge ? 8 : 6;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            splashColor: (isDark ? Colors.white : Colors.black).withOpacity(
              0.15,
            ),
            highlightColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon(
                  //   icon,
                  //   size: iconSize,
                  //   color: isDark ? Colors.white : Colors.black,
                  // ),
                  // SizedBox(width: spacing),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      // color: isDark ? Colors.white : Colors.black,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
