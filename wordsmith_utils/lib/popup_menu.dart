import "package:flutter/material.dart";

void showPopupMenu(BuildContext context, List<PopupMenuItem> items,
    {String? semanticLabel}) {
  final RenderBox button = context.findRenderObject() as RenderBox;
  final Offset offset = button.localToGlobal(Offset.zero);

  showMenu(
    context: context,
    position: RelativeRect.fromLTRB(
      offset.dx,
      offset.dy + button.size.height - 5.0,
      offset.dx + button.size.width,
      offset.dy + button.size.height + 2.0,
    ),
    items: items,
    semanticLabel: semanticLabel,
  );
}
