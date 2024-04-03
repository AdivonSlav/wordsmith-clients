import "package:flutter/material.dart";
import "package:wordsmith_admin_panel/widgets/input_field.dart";

class ProfileInfoFieldWidget extends StatefulWidget {
  final String labelText;
  final String valueText;
  final TextEditingController controller;
  final void Function() callbackFunction;

  const ProfileInfoFieldWidget({
    super.key,
    required this.labelText,
    required this.valueText,
    required this.controller,
    required this.callbackFunction,
  });

  @override
  State<StatefulWidget> createState() => _ProfileInfoFieldWidgetState();
}

class _ProfileInfoFieldWidgetState extends State<ProfileInfoFieldWidget> {
  bool _editable = false;

  void _toggleEditable() {
    setState(() {
      _editable = !_editable;

      if (!_editable) {
        widget.controller.text = "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(width: 100.0, child: Text(widget.labelText)),
        InputField(
          labelText: widget.valueText,
          controller: widget.controller,
          enabled: _editable,
        ),
        const SizedBox(width: 25.0),
        IconButton(
          onPressed: _toggleEditable,
          icon: Icon(!_editable ? Icons.edit : Icons.edit_off),
        ),
        const SizedBox(width: 15.0),
        Visibility(
          visible: _editable,
          child: IconButton(
            onPressed: () async {
              widget.callbackFunction();
              _toggleEditable();
            },
            icon: const Icon(Icons.check),
          ),
        )
      ],
    );
  }
}
