import "package:flutter/material.dart";
import "package:wordsmith_admin_panel/widgets/input_field.dart";
import "package:wordsmith_utils/size_config.dart";

class ProfileInfoFieldWidget extends StatefulWidget {
  final String labelText;
  final String valueText;
  final TextEditingController controller;
  final Future<void> Function() callbackFunction;

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
  bool editable = false;

  void _toggleEditable() {
    setState(() {
      editable = !editable;

      if (!editable) {
        widget.controller.text = "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
            width: SizeConfig.safeBlockHorizontal * 9.0,
            child: Text(widget.labelText)),
        SizedBox(width: SizeConfig.safeBlockHorizontal * 2.0),
        InputField(
          labelText: widget.valueText,
          controller: widget.controller,
          enabled: editable,
        ),
        SizedBox(width: SizeConfig.safeBlockHorizontal * 2.0),
        IconButton(
          onPressed: _toggleEditable,
          icon: Icon(!editable ? Icons.edit : Icons.edit_off),
        ),
        SizedBox(width: SizeConfig.safeBlockHorizontal * 2.0),
        Visibility(
          visible: editable,
          child: IconButton(
            onPressed: () async {
              widget.callbackFunction;
              _toggleEditable();
            },
            icon: const Icon(Icons.check),
          ),
        )
      ],
    );
  }
}
