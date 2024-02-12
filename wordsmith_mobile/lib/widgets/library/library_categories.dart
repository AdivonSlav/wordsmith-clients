import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/utils/library_filter_values.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/user_library_category/user_library_category.dart';
import 'package:wordsmith_utils/providers/user_library_category_provider.dart';

class LibraryCategoriesWidget extends StatefulWidget {
  final LibraryFilterValues filterValues;
  final void Function(LibraryFilterValues values) onSelect;

  const LibraryCategoriesWidget({
    super.key,
    required this.filterValues,
    required this.onSelect,
  });

  @override
  State<StatefulWidget> createState() => _LibraryCategoriesWidgetState();
}

class _LibraryCategoriesWidgetState extends State<LibraryCategoriesWidget> {
  final _logger = LogManager.getLogger("LibraryCategories");
  late UserLibraryCategoryProvider _userLibraryCategoryProvider;
  late Future<QueryResult<UserLibraryCategory>> _libraryCategoriesFuture;

  Future<QueryResult<UserLibraryCategory>> _getLibraryCategories() async {
    try {
      return await _userLibraryCategoryProvider.getLibraryCategories();
    } on Exception catch (error) {
      _logger.severe(error);
      return Future.error(error);
    }
  }

  void _selectCategory(UserLibraryCategory category) {
    widget.filterValues.selectedCategory = category;
    widget.onSelect(widget.filterValues);
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

    return SimpleDialog(
      title: const Text("Your categories"),
      children: <Widget>[
        const Divider(),
        SizedBox(
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

                if (libraryCategories.isEmpty) {
                  return const Center(
                    child: Text(
                      "You have no categories currently.\nLong-tap on a library entry to start creating one!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  );
                }

                return SizedBox(
                  width: double.maxFinite,
                  child: ListView.separated(
                    itemCount: libraryCategories.length,
                    itemBuilder: (context, index) {
                      var category = libraryCategories[index];

                      return ListTile(
                        leading: widget.filterValues.selectedCategory?.id ==
                                category.id
                            ? const Icon(Icons.check_circle)
                            : null,
                        title: Text(category.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {},
                        ),
                        onTap: () => _selectCategory(category),
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
      ],
    );
  }
}
