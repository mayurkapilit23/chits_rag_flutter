import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/gpt/bloc/gpt_bloc.dart';
import '../../features/gpt/bloc/gpt_event.dart';
import '../colors/app_colors.dart';

void showContextMenuAtPosition(
  BuildContext context,
  Offset tapPosition,
  int index,
) async {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final result = await showMenu<String>(
    color: isDark ? AppColors.darkSecondary : AppColors.primaryColor,
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromPoints(tapPosition, tapPosition),
      Offset.zero & overlay.size,
    ),
    items: [
      // PopupMenuItem(
      //   value: 'edit',
      //   child: ListTile(leading: Icon(Icons.edit), title: Text('Edit')),
      // ),
      PopupMenuItem(
        value: 'delete',
        child: ListTile(
          leading: Icon(Icons.delete, color: Colors.redAccent),
          title: Text(
            'Delete',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
        ),
      ),
    ],
  );

  if (result == 'edit') {
    // edit logic
  } else if (result == 'delete') {
    context.read<GptBloc>().add(DeleteConversationEvent(index));
  }
}
