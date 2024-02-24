import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/widgets/library/library_categories_create.dart';
import 'package:wordsmith_utils/dialogs/progress_line_dialog.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/user_library_category/user_library_category.dart';
import 'package:wordsmith_utils/models/user_library_category/user_library_category_add.dart';
import 'package:wordsmith_utils/providers/user_library_category_provider.dart';
import 'package:wordsmith_utils/show_snackbar.dart';

class LibraryCategoriesAddWidget extends StatefulWidget {
  final List<int> selectedEntryIds;
  final void Function() onAdd;

  const LibraryCategoriesAddWidget({
    super.key,
    required this.selectedEntryIds,
    required this.onAdd,
  });

  @override
  State<LibraryCategoriesAddWidget> createState() =>
      _LibraryCategoriesAddWidgetState();
}

class _LibraryCategoriesAddWidgetState
    extends State<LibraryCategoriesAddWidget> {
  final _logger = LogManager.getLogger("LibraryCategoriesAdd");
  late UserLibraryCategoryProvider _userLibraryCategoryProvider;
  late Future<QueryResult<UserLibraryCategory>> _libraryCategoriesFuture;

  final _dialogKey = GlobalKey<ProgressLineDialogState>();
  var _addingToCategory = false;

  Future<QueryResult<UserLibraryCategory>> _getLibraryCategories() async {
    try {
      return await _userLibraryCategoryProvider.getLibraryCategories();
    } on Exception catch (error) {
      _logger.severe(error);
      return Future.error(error);
    }
  }

  void _toggleInProgress() {
    setState(() {
      _addingToCategory = !_addingToCategory;
      _dialogKey.currentState!.toggleProgressLine();
    });
  }

  Future _addEntriesToCategory(int categoryId) async {
    if (_addingToCategory) return;

    _toggleInProgress();
    var add = UserLibraryCategoryAdd(widget.selectedEntryIds, categoryId, null);

    await _userLibraryCategoryProvider.addEntriesToCategory(add).then((result) {
      showSnackbar(context: context, content: result.message ?? "Success");

      // Indicate to the library screen that it should rebuild
      widget.onAdd();
      Navigator.of(context).pop();
      _toggleInProgress();
    }, onError: (error) {
      showSnackbar(context: context, content: error.toString());
      _toggleInProgress();
    });
  }

  void _openNewCategoryDialog(BuildContext context) async {
    var result = await showDialog(
        context: context,
        builder: (context) {
          return LibraryCategoriesCreateWidget(
            selectedEntryIds: widget.selectedEntryIds,
          );
        });

    if (result == true) {
      widget.onAdd();
    }
  }

  @override
  void initState() {
    _userLibraryCategoryProvider = context.read<UserLibraryCategoryProvider>();
    _libraryCategoriesFuture = _getLibraryCategories();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return ProgressLineDialog(
      key: _dialogKey,
      title: const Text("Add to a category"),
      content: SizedBox(
        height: size.height * 0.4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder(
            future: _libraryCategoriesFuture,
            builder: (BuildContext context,
                AsyncSnapshot<QueryResult<UserLibraryCategory>> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }

              var libraryCategories = snapshot.data!.result;
              return SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                  itemCount: libraryCategories.length,
                  itemBuilder: (context, index) {
                    var category = libraryCategories[index];

                    return Card(
                      child: ListTile(
                        title: Text(category.name),
                        onTap: () => _addEntriesToCategory(category.id),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Divider();
                  },
                ),
              );
            },
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _openNewCategoryDialog(context);
          },
          child: const Text("Create new category"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
