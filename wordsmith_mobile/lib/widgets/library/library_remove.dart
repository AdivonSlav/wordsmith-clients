import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/utils/indexers/ebook_index_provider.dart';
import 'package:wordsmith_mobile/utils/indexers/models/ebook_index_model.dart';
import 'package:wordsmith_utils/dialogs/progress_line_dialog.dart';
import 'package:wordsmith_utils/dialogs/show_error_dialog.dart';
import 'package:wordsmith_utils/models/entity_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/user_library/user_library.dart';
import 'package:wordsmith_utils/providers/user_library_provider.dart';
import 'package:wordsmith_utils/show_snackbar.dart';

class LibraryRemoveWidget extends StatefulWidget {
  final UserLibrary libraryEntry;
  final EbookIndexModel? indexModel;

  const LibraryRemoveWidget({
    super.key,
    required this.libraryEntry,
    this.indexModel,
  });

  @override
  State<LibraryRemoveWidget> createState() => _LibraryRemoveWidgetState();
}

class _LibraryRemoveWidgetState extends State<LibraryRemoveWidget> {
  final _dialogKey = GlobalKey<ProgressLineDialogState>();
  late EbookIndexProvider _ebookIndexProvider;
  late UserLibraryProvider _userLibraryProvider;

  bool _confirmingCompleteDeletion = false;
  bool _isDeleting = false;

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: <Widget>[
          Visibility(
            visible: !_confirmingCompleteDeletion,
            child: const Column(
              children: [
                Text(
                    "You can either delete the locally-downloaded copy, or the entire library entry for the ebook."),
                SizedBox(height: 8.0),
                Text(
                  "Note that if you remove the library entry and you purchased the ebook, you will have to purchase it again if you want to re-add",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Visibility(
            visible: _confirmingCompleteDeletion,
            child: const Column(
              children: [
                Text("Are you sure?"),
                SizedBox(height: 8.0),
                Text(
                  "This cannot be undone",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildActions() {
    return <Widget>[
      Visibility(
        visible: !_confirmingCompleteDeletion,
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () => _dismiss(false),
                child: const Text("Cancel"),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: widget.indexModel != null ? _delete : null,
                child: const Text("Remove local copy"),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: _confirmCompleteDeletion,
                child: const Text(
                  "Remove completely",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
      Visibility(
        visible: _confirmingCompleteDeletion,
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: _deleteCompletely,
                child: const Text(
                  "Remove completely",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  void _delete() async {
    if (_isDeleting) return;
    _toggleIsDeleting();

    var model = widget.indexModel;

    if (model == null) return;

    await _ebookIndexProvider.removeFromIndex(model).then((result) {
      _toggleIsDeleting();
      switch (result) {
        case Success():
          _dismiss(true);
          showSnackbar(
              context: context, content: "Ebook deleted from local storage!");
        case Failure(exception: final e):
          _dismiss(false);
          showErrorDialog(context: context, content: Text(e.message));
      }
    });
  }

  void _deleteCompletely() async {
    if (_isDeleting) return;
    _toggleIsDeleting();

    await _userLibraryProvider
        .deleteLibraryEntry(widget.libraryEntry.id)
        .then((result) {
      _toggleIsDeleting();
      switch (result) {
        case Success<EntityResult<UserLibrary>>():
          _dismiss(true);
          showSnackbar(context: context, content: "Removed library entry!");
        case Failure<EntityResult<UserLibrary>>(exception: final e):
          _dismiss(false);
          showErrorDialog(context: context, content: Text(e.message));
      }
    });
  }

  void _confirmCompleteDeletion() async {
    setState(() {
      _confirmingCompleteDeletion = true;
    });
  }

  void _toggleIsDeleting() {
    setState(() {
      _dialogKey.currentState!.toggleProgressLine();
      _isDeleting = !_isDeleting;
    });
  }

  void _dismiss(bool result) {
    if (!_isDeleting) {
      Navigator.of(context).pop(result);
    }
  }

  @override
  void initState() {
    _ebookIndexProvider = context.read<EbookIndexProvider>();
    _userLibraryProvider = context.read<UserLibraryProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ProgressLineDialog(
        key: _dialogKey,
        title: const Text("Delete ebook"),
        content: _buildContent(),
        actions: _buildActions(),
      ).animate().fade(duration: const Duration(milliseconds: 100)),
    );
  }
}
