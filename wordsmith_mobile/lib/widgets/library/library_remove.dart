import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/utils/indexers/ebook_index_provider.dart';
import 'package:wordsmith_mobile/utils/indexers/models/ebook_index_model.dart';
import 'package:wordsmith_utils/dialogs/progress_line_dialog.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/user_library/user_library.dart';
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

  bool _confirmingCompleteDeletion = false;

  Future<void> _delete() async {
    var model = widget.indexModel;

    if (model == null) return;

    _dialogKey.currentState!.toggleProgressLine();

    await _ebookIndexProvider.removeFromIndex(model).then((result) {
      switch (result) {
        case Success():
          Navigator.of(context).pop(true);
          showSnackbar(
              context: context, content: "Ebook deleted from local storage!");
        case Failure(exception: final e):
          Navigator.of(context).pop(false);
          showSnackbar(context: context, content: e.toString());
      }
    });
  }

  Future<void> _deleteCompletely() async {
    // TODO: Implement
  }

  Future<void> _confirmCompleteDeletion() async {
    setState(() {
      _confirmingCompleteDeletion = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    _ebookIndexProvider = Provider.of<EbookIndexProvider>(context);

    return ProgressLineDialog(
      key: _dialogKey,
      title: const Text("Delete ebook"),
      content: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            Visibility(
              visible: !_confirmingCompleteDeletion,
              child: const Column(
                children: [
                  Text(
                    "You can either delete the locally-downloaded copy, or the entire library entry for the ebook.",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    "Note that if you remove the library entry and you purchased the ebook, you will have to purchase it again if you want to re-add",
                    textAlign: TextAlign.center,
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
      ),
      actions: <Widget>[
        Visibility(
          visible: !_confirmingCompleteDeletion,
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
      ],
    ).animate().fade(duration: const Duration(milliseconds: 100));
  }
}
