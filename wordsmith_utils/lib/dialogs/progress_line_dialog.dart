import "package:flutter/material.dart";

class ProgressLineDialog extends StatefulWidget {
  final Widget title;
  final Widget content;
  final List<Widget>? actions;

  const ProgressLineDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.actions,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ProgressLineDialogState();
}

class ProgressLineDialogState extends State<ProgressLineDialog> {
  bool _showProgressLine = false;

  void toggleProgressLine() {
    setState(() {
      _showProgressLine = !_showProgressLine;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.only(top: 25.0),
      contentPadding: const EdgeInsets.all(0.0),
      actionsPadding: const EdgeInsets.only(bottom: 15.0, right: 10.0),
      title: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: widget.title,
          ),
          const SizedBox(height: 20.0),
          if (_showProgressLine) const LinearProgressIndicator(),
          const Divider(height: 0.0),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          widget.content,
          const Divider(height: 0.0),
          const SizedBox(height: 15.0),
        ],
      ),
      actions: widget.actions,
    );
  }
}
