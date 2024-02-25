import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/utils/library_filter_values.dart';
import 'package:wordsmith_mobile/widgets/library/library_categories.dart';
import 'package:wordsmith_mobile/widgets/library/library_categories_add.dart';
import 'package:wordsmith_mobile/widgets/library/library_categories_remove.dart';
import 'package:wordsmith_mobile/widgets/library/library_filters.dart';
import 'package:wordsmith_mobile/widgets/library/library_grid_tile.dart';
import 'package:wordsmith_mobile/widgets/library/library_view.dart';
import 'package:wordsmith_utils/dialogs/show_error_dialog.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/user_library/user_library.dart';
import 'package:wordsmith_utils/providers/user_library_provider.dart';

class LibraryScreenWidget extends StatefulWidget {
  const LibraryScreenWidget({super.key});

  @override
  State<StatefulWidget> createState() => _LibraryScreenWidgetState();
}

class _LibraryScreenWidgetState extends State<LibraryScreenWidget> {
  final _logger = LogManager.getLogger("LibraryScreen");
  late UserLibraryProvider _userLibraryProvider;
  final _scrollController = ScrollController();

  final List<UserLibrary> _userLibraryList = [];
  final _pageSize = 15;
  var _page = 1;
  var _hasMore = true;
  LibraryFilterValues? _filterValues;

  var _isSelectingBooks = false;

  // Keys are indices within the grid, while the values are the IDs of the library entries themselves
  final _selectedBooks = HashMap<int, int>();

  Future _getLibraryBooks() async {
    if (_userLibraryProvider.isLoading) return;

    List<UserLibrary> libraryResult = [];

    await _userLibraryProvider
        .getLibraryEntries(
      maturityRatingId: _filterValues?.selectedMaturityRatingId,
      isRead: _filterValues?.isRead,
      orderBy: _filterValues != null
          ? "${_filterValues!.sortByProperty}:${_filterValues!.sortByDirection}"
          : "EBook.Title:asc",
      libraryCategoryId: _filterValues?.selectedCategory?.id,
      page: _page,
      pageSize: _pageSize,
    )
        .then((_) {
      switch (_userLibraryProvider.libraryEntries!) {
        case Success(data: final d):
          libraryResult = d.result;
        case Failure(errorMessage: final e):
          showErrorDialog(context, const Text("Error"), Text(e));
      }
    });

    setState(() {
      _page++;

      if (libraryResult.length < _pageSize) {
        _hasMore = false;
      }

      _userLibraryList.addAll(libraryResult);
    });
  }

  Future _buildFilterValues() async {
    setState(() {
      _filterValues = LibraryFilterValues(
        sortByProperty: "EBook.Title",
        sortByDirection: "asc",
      );
    });
  }

  Future _refresh() async {
    setState(() {
      _hasMore = true;
      _page = 1;
      _userLibraryList.clear();
      _removeAllBooksFromSelection();
    });

    _getLibraryBooks();
  }

  Future _refreshWithFilters(LibraryFilterValues values) async {
    setState(() {
      _filterValues = values;
      _refresh();
    });
  }

  Widget _buildCategoryIndicator() {
    if (_filterValues?.selectedCategory != null) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  "Showing category: ${_filterValues!.selectedCategory!.name}",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () {
                  _filterValues?.selectedCategory = null;
                  _refresh();
                },
                icon: const Icon(Icons.remove_circle),
              ),
            ],
          ),
        ],
      );
    }

    return const SizedBox(height: 15.0);
  }

  Widget _buildBanner() {
    if (_isSelectingBooks) {
      return MaterialBanner(
        content: Text("${_selectedBooks.length}/20"),
        actions: [
          TextButton(
            onPressed: () {
              if (_selectedBooks.isEmpty) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text("Select at least one book!"),
                  ),
                );
              } else if (_selectedBooks.isNotEmpty &&
                  _filterValues?.selectedCategory == null) {
                _openCategoriesAdd();
              } else if (_selectedBooks.isNotEmpty &&
                  _filterValues?.selectedCategory != null) {
                _openCategoriesRemove();
              }
            },
            child: Text(_selectedBooks.isNotEmpty &&
                    _filterValues?.selectedCategory == null
                ? "Add to category"
                : "Remove from category"),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.delete_forever),
          ),
          IconButton(
            onPressed: () => _removeAllBooksFromSelection(),
            icon: const Icon(Icons.close),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(onPressed: _openFilters, icon: const Icon(Icons.tune)),
        const Spacer(),
        TextButton(
          onPressed: _openCategories,
          child: const Text("Categories"),
        ),
        IconButton(onPressed: _openSorts, icon: const Icon(Icons.sort)),
      ],
    );
  }

  void _openFilters() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          if (_filterValues == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return LibraryFiltersWidget(
            filterValues: _filterValues!,
            onSelect: (values) {
              _refreshWithFilters(values);
              Navigator.of(context).pop();
            },
          );
        });
  }

  void _openSorts() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          if (_filterValues == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return LibraryViewWidget(
            filterValues: _filterValues!,
            onSelect: (values) {
              _refreshWithFilters(values);
              Navigator.of(context).pop();
            },
          );
        });
  }

  void _openCategories() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (_filterValues == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return LibraryCategoriesWidget(
          filterValues: _filterValues!,
          onSelect: (values) {
            _refreshWithFilters(values);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _openCategoriesAdd() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return LibraryCategoriesAddWidget(
          selectedEntryIds: _selectedBooks.values.toList(),
          onAdd: _refresh,
        );
      },
    );
  }

  void _openCategoriesRemove() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return LibraryCategoriesRemoveWidget(
            selectedEntryIds: _selectedBooks.values.toList(),
            onRemove: () {
              _filterValues?.selectedCategory = null;
              _refresh();
            },
          );
        });
  }

  void _addBookToSelection(int index, int entryId) {
    setState(() {
      if (_selectedBooks.isEmpty) {
        _isSelectingBooks = true;
        _logger.info("Started selecting books!");
      }

      _selectedBooks[index] = entryId;
      _logger.info(
          "Selected book $index. Selection is now at ${_selectedBooks.length}");
    });
  }

  void _removeBookFromSelection(int index) {
    setState(() {
      _selectedBooks.remove(index);
      _logger.info(
          "Removed book $index from selection. Selection is now at ${_selectedBooks.length}");

      if (_selectedBooks.isEmpty) {
        _isSelectingBooks = false;
        _logger.info("Stopped selecting books");
      }
    });
  }

  void _removeAllBooksFromSelection() {
    setState(() {
      _isSelectingBooks = false;
      _selectedBooks.clear();
      _logger.info("Stopped selecting books");
    });
  }

  bool _isBookSelected(int index) {
    return _isSelectingBooks && _selectedBooks.containsKey(index);
  }

  void _onBookTap(int index, int entryId) {
    if (_isSelectingBooks) {
      if (!_selectedBooks.containsKey(index)) {
        _addBookToSelection(index, entryId);
      } else {
        _removeBookFromSelection(index);
      }
    }
  }

  void _onBookLongPress(int index, int entryId) {
    if (_isSelectingBooks) return;

    _addBookToSelection(index, entryId);
  }

  @override
  void initState() {
    _userLibraryProvider = context.read<UserLibraryProvider>();
    super.initState();

    Future.microtask(() {
      _buildFilterValues();
      _getLibraryBooks();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        _logger.info("Reached the end, should fetch more books!");
        _getLibraryBooks();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          Builder(builder: (context) => _buildBanner()),
          const Divider(
            height: 1.0,
          ),
          Builder(builder: (context) => _buildCategoryIndicator()),
          Expanded(
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _refresh,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: GridView.builder(
                      shrinkWrap: true,
                      primary: false,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 15.0,
                        mainAxisSpacing: 15.0,
                        childAspectRatio: size.width / (size.height * 0.75),
                      ),
                      itemCount: _userLibraryList.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index < _userLibraryList.length) {
                          var libraryEntry = _userLibraryList[index];
                          var isSelected = _isBookSelected(index);

                          return LibraryGridTileWidget(
                            libraryEntry: libraryEntry,
                            tileIndex: index,
                            isSelected: isSelected,
                            isSelectingBooks: _isSelectingBooks,
                            onBookTap: _onBookTap,
                            onBookLongPress: _onBookLongPress,
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32.0),
                            child: Center(
                              child: _hasMore
                                  ? const CircularProgressIndicator()
                                  : Container(),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10.0, bottom: 20.0),
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.onBackground,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 1.0,
                              spreadRadius: 1.0,
                            ),
                          ]),
                      child: Visibility(
                          visible: !_isSelectingBooks,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _isSelectingBooks = true;
                              });
                            },
                            icon: const Icon(Icons.edit),
                            color: theme.colorScheme.onPrimary,
                          )),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
