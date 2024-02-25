import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/widgets/input_field.dart';
import 'package:wordsmith_utils/dialogs/progress_line_dialog.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/user_library_category/user_library_category_add.dart';
import 'package:wordsmith_utils/providers/user_library_category_provider.dart';
import 'package:wordsmith_utils/show_snackbar.dart';
import 'package:wordsmith_utils/validators.dart';

class LibraryCategoriesCreateWidget extends StatefulWidget {
  final List<int> selectedEntryIds;

  const LibraryCategoriesCreateWidget({
    super.key,
    required this.selectedEntryIds,
  });

  @override
  State<LibraryCategoriesCreateWidget> createState() =>
      _LibraryCategoriesCreateWidgetState();
}

class _LibraryCategoriesCreateWidgetState
    extends State<LibraryCategoriesCreateWidget> {
  late UserLibraryCategoryProvider _userLibraryCategoryProvider;

  final _dialogKey = GlobalKey<ProgressLineDialogState>();
  var _addingToCategory = false;
  final _categoryNameController = TextEditingController();

  void _toggleInProgress() {
    setState(() {
      _addingToCategory = !_addingToCategory;
      _dialogKey.currentState!.toggleProgressLine();
    });
  }

  Future _createCategoryForEntries() async {
    if (_addingToCategory) return;

    _toggleInProgress();
    var newCategoryName = _categoryNameController.text;
    var add =
        UserLibraryCategoryAdd(widget.selectedEntryIds, null, newCategoryName);

    await _userLibraryCategoryProvider.addEntriesToCategory(add).then((result) {
      switch (result) {
        case Success<String>():
          showSnackbar(context: context, content: result.data);
          // Indicate to the library screen that it should rebuild
          Navigator.of(context).pop(true);
        case Failure<String>():
          showSnackbar(context: context, content: result.exception.toString());
      }
    });

    _toggleInProgress();
  }

  @override
  Widget build(BuildContext context) {
    _userLibraryCategoryProvider = context.read<UserLibraryCategoryProvider>();

    return ProgressLineDialog(
      key: _dialogKey,
      title: const Text("Add new category"),
      content: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InputField(
              labelText: "Category name",
              controller: _categoryNameController,
              obscureText: false,
              validator: validateCategoryName,
              maxLength: 255,
              enabled: !_addingToCategory,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () =>
              _addingToCategory ? null : _createCategoryForEntries(),
          child: const Text("Add"),
        ),
        TextButton(
          onPressed: () =>
              _addingToCategory ? null : Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
