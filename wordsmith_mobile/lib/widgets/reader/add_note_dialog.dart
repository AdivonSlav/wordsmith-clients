import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/widgets/input_field.dart';
import 'package:wordsmith_utils/dialogs/progress_line_dialog.dart';
import 'package:wordsmith_utils/models/note/note_insert.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/providers/note_provider.dart';
import 'package:wordsmith_utils/show_snackbar.dart';
import 'package:wordsmith_utils/validators.dart';

class AddNoteDialogWidget extends StatefulWidget {
  final int ebookId;
  final String cfi;
  final String selectedText;

  const AddNoteDialogWidget({
    super.key,
    required this.ebookId,
    required this.cfi,
    required this.selectedText,
  });

  @override
  State<AddNoteDialogWidget> createState() => _AddNoteDialogWidgetState();
}

class _AddNoteDialogWidgetState extends State<AddNoteDialogWidget> {
  late NoteProvider _noteProvider;

  final _dialogKey = GlobalKey<ProgressLineDialogState>();
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();

  bool _isAdding = false;

  Widget _buildContent() {
    var size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 18.0),
            child: Container(
              width: size.width,
              height: size.height * 0.12,
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.selectedText),
                ),
              ),
            ),
          ),
          Form(
            key: _formKey,
            child: InputField(
              labelText: "Note content",
              controller: _contentController,
              maxLength: 400,
              maxLines: 3,
              validator: validateRequired,
              obscureText: false,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions() {
    return <Widget>[
      TextButton(
        onPressed: () => _dismiss(),
        child: const Text("Cancel"),
      ),
      FilledButton(
        onPressed: () => _addNote(),
        child: const Text("Add"),
      ),
    ];
  }

  void _addNote() async {
    if (_isAdding || !_formKey.currentState!.validate()) {
      return;
    }
    _dialogKey.currentState!.toggleProgressLine();
    _isAdding = true;

    var insert = NoteInsert(
      eBookId: widget.ebookId,
      content: _contentController.text,
      cfi: widget.cfi,
      referencedText: widget.selectedText,
    );

    await _noteProvider.postNote(insert).then((result) {
      _dialogKey.currentState!.toggleProgressLine();
      _isAdding = false;
      switch (result) {
        case Success():
          showSnackbar(context: context, content: "Note added");
          _dismiss();
        case Failure():
          showSnackbar(
            context: context,
            content: result.exception.message,
            backgroundColor: Colors.red,
          );
      }
    });
  }

  void _dismiss() {
    if (!_isAdding) {
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    _noteProvider = context.read<NoteProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ProgressLineDialog(
        key: _dialogKey,
        title: const Text("Add note"),
        content: _buildContent(),
        actions: _buildActions(),
      ),
    );
  }
}
