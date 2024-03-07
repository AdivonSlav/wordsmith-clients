import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/utils/indexers/ebook_index_provider.dart';
import 'package:wordsmith_mobile/utils/indexers/models/ebook_index_model.dart';
import 'package:wordsmith_utils/dialogs/progress_line_dialog.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/show_snackbar.dart';

class LibraryOfflineRemoveWidget extends StatefulWidget {
  final EbookIndexModel indexModel;

  const LibraryOfflineRemoveWidget({super.key, required this.indexModel});

  @override
  State<LibraryOfflineRemoveWidget> createState() =>
      _LibraryOfflineRemoveWidgetState();
}

class _LibraryOfflineRemoveWidgetState
    extends State<LibraryOfflineRemoveWidget> {
  final _dialogKey = GlobalKey<ProgressLineDialogState>();
  late EbookIndexProvider _ebookIndexProvider;

  Future<void> _delete() async {
    _dialogKey.currentState!.toggleProgressLine();

    await _ebookIndexProvider.removeFromIndex(widget.indexModel).then((result) {
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

  @override
  Widget build(BuildContext context) {
    _ebookIndexProvider = Provider.of<EbookIndexProvider>(context);

    return ProgressLineDialog(
      key: _dialogKey,
      title: const Text("Delete ebook"),
      content: const Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              "Are you sure you want to delete the downloaded ebook?",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.0),
            Text(
              "This cannot be undone.",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: _delete,
          child: const Text("Yes"),
        ),
      ],
    );
  }
}
