import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/utils/filters/library_filter_values.dart';
import 'package:wordsmith_utils/dialogs/progress_line_dialog.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/user_library_category/user_library_category_remove.dart';
import 'package:wordsmith_utils/providers/user_library_category_provider.dart';
import 'package:wordsmith_utils/show_snackbar.dart';

class LibraryCategoriesRemoveWidget extends StatefulWidget {
  final List<int> selectedEntryIds;

  const LibraryCategoriesRemoveWidget({
    super.key,
    required this.selectedEntryIds,
  });

  @override
  State<LibraryCategoriesRemoveWidget> createState() =>
      _LibraryCategoriesRemoveWidgetState();
}

class _LibraryCategoriesRemoveWidgetState
    extends State<LibraryCategoriesRemoveWidget> {
  final _dialogKey = GlobalKey<ProgressLineDialogState>();
  late UserLibraryCategoryProvider _userLibraryCategoryProvider;
  late LibraryFilterValuesProvider _filterValuesProvider;

  var _inProgress = false;

  void _toggleInProgress() {
    setState(() {
      _inProgress = !_inProgress;
      _dialogKey.currentState!.toggleProgressLine();
    });
  }

  void _removeFromCategory() async {
    if (_inProgress) return;
    _toggleInProgress();

    final removeModel =
        UserLibraryCategoryRemove(userLibraryIds: widget.selectedEntryIds);

    await _userLibraryCategoryProvider
        .removeCategoryFromEntries(removeModel)
        .then((result) {
      switch (result) {
        case Success<String>():
          showSnackbar(context: context, content: result.data);
          _filterValuesProvider.updateFilterValueProperties(
              selectedCategory: null);
        case Failure<String>():
          showSnackbar(context: context, content: result.exception.toString());
      }
    });

    _toggleInProgress();
  }

  @override
  void initState() {
    _userLibraryCategoryProvider = context.read<UserLibraryCategoryProvider>();
    _filterValuesProvider = context.read<LibraryFilterValuesProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ProgressLineDialog(
      key: _dialogKey,
      title: const Text("Remove category from entries"),
      content: const Padding(
        padding: EdgeInsets.all(12.0),
        child: Text(
            "Do you wish to remove the category from the selected entries?"),
      ),
      actions: <Widget>[
        TextButton(onPressed: _removeFromCategory, child: const Text("Yes")),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        )
      ],
    );
  }
}
