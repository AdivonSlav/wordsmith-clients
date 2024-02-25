import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/utils/library_filter_values.dart';
import 'package:wordsmith_utils/dialogs/progress_line_dialog.dart';
import 'package:wordsmith_utils/models/result.dart';
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
  late Future getLibraryCategories;

  void _selectCategory(UserLibraryCategory category) {
    widget.filterValues.selectedCategory = category;
    widget.onSelect(widget.filterValues);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<UserLibraryCategoryProvider>().getLibraryCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return ProgressLineDialog(
      title: const Text("Your categories"),
      content: SizedBox(
        height: size.height * 0.4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<UserLibraryCategoryProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading || provider.libraryCategories == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              List<UserLibraryCategory> libraryCategories = [];

              switch (provider.libraryCategories!) {
                case Success(data: final d):
                  libraryCategories = d.result;
                case Failure(errorMessage: final e):
                  return Center(
                    child: Text(e),
                  );
              }

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

                    return Card(
                      child: ListTile(
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        )
      ],
    );
  }
}
