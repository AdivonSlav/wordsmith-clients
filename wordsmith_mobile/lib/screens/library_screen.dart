import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/utils/indexers/ebook_index_provider.dart';
import 'package:wordsmith_mobile/utils/indexers/models/ebook_index_model.dart';
import 'package:wordsmith_mobile/utils/filters/library_filter_values.dart';
import 'package:wordsmith_mobile/widgets/library/library_categories.dart';
import 'package:wordsmith_mobile/widgets/library/library_categories_add.dart';
import 'package:wordsmith_mobile/widgets/library/library_categories_remove.dart';
import 'package:wordsmith_mobile/widgets/library/library_filters.dart';
import 'package:wordsmith_mobile/widgets/library/library_grid_tile.dart';
import 'package:wordsmith_mobile/widgets/library/library_info.dart';
import 'package:wordsmith_mobile/widgets/library/library_offline_grid_tile.dart';
import 'package:wordsmith_mobile/widgets/library/library_offline_info.dart';
import 'package:wordsmith_mobile/widgets/library/library_view.dart';
import 'package:wordsmith_utils/dialogs/show_error_dialog.dart';
import 'package:wordsmith_utils/exceptions/exception_types.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/sorting_directions.dart';
import 'package:wordsmith_utils/models/user_library/user_library.dart';
import 'package:wordsmith_utils/providers/user_library_provider.dart';
import 'package:wordsmith_utils/show_snackbar.dart';

class LibraryScreenWidget extends StatefulWidget {
  const LibraryScreenWidget({super.key});

  @override
  State<StatefulWidget> createState() => _LibraryScreenWidgetState();
}

class _LibraryScreenWidgetState extends State<LibraryScreenWidget> {
  final _logger = LogManager.getLogger("LibraryScreen");
  final _scrollController = ScrollController();

  late UserLibraryProvider _userLibraryProvider;
  late EbookIndexProvider _ebookIndexProvider;
  late LibraryFilterValuesProvider _filterValuesProvider;

  final List<UserLibrary> _userLibraryList = [];
  final List<EbookIndexModel> _indexModelList = [];
  final int _pageSize = 15;
  int _page = 1;
  bool _hasMore = true;
  bool _isOffline = false;
  bool _hasDisplayedOfflineMessage = false;

  var _isLoading = false;
  var _isSelectingBooks = false;

  // Keys are indices within the grid, while the values are the IDs of the library entries themselves
  final _selectedBooks = HashMap<int, int>();

  // Resetting this value forces the book selection banner to replay its animations
  var _bannerAnimationKey = UniqueKey();

  Future _getLibraryBooks() async {
    if (_isLoading) return;
    _isLoading = true;

    List<UserLibrary> libraryResult = [];
    List<EbookIndexModel> indexModelResult = [];
    LibraryFilterValues filterValues = _filterValuesProvider.filterValues;

    await _ebookIndexProvider.getAll(filterValues: filterValues).then((result) {
      switch (result) {
        case Success():
          indexModelResult = result.data;
        case Failure(exception: final e):
          showErrorDialog(context: context, content: Text(e.toString()));
      }
    });

    await _userLibraryProvider
        .getLibraryEntries(
      maturityRatingId: filterValues.selectedMaturityRatingId,
      isRead: filterValues.isRead,
      orderBy:
          "${filterValues.sort.apiValue}:${filterValues.sortDirection.apiValue}",
      libraryCategoryId: filterValues.selectedCategory?.id,
      page: _page,
      pageSize: _pageSize,
    )
        .then((result) async {
      switch (result) {
        case Success(data: final d):
          libraryResult = d.result;
          _isOffline = false;
        case Failure(exception: final e):
          if (e.type == ExceptionType.socketException) {
            _isOffline = true;

            if (!_hasDisplayedOfflineMessage) {
              showSnackbar(
                context: context,
                content: "Offline. You are only able to view downloaded ebooks",
              );
              _hasDisplayedOfflineMessage = true;
            }
          } else {
            showErrorDialog(context: context, content: Text(e.toString()));
          }
      }
    });

    setState(() {
      _page++;
      _isLoading = false;

      if (libraryResult.length < _pageSize) {
        _hasMore = false;
      }

      _userLibraryList.addAll(libraryResult);

      if (_isOffline) {
        _indexModelList.addAll(indexModelResult);
      } else {
        _indexModelList.clear();
      }
    });
  }

  Future _refresh() async {
    setState(() {
      _isLoading = false;
      _hasMore = true;
      _page = 1;
      _userLibraryList.clear();
      _indexModelList.clear();
      _removeAllBooksFromSelection();
    });

    _getLibraryBooks();
  }

  Widget _buildCategoryIndicator() {
    LibraryFilterValues filterValues = _filterValuesProvider.filterValues;

    if (filterValues.selectedCategory != null) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  "Showing category: ${filterValues.selectedCategory!.name}",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () {
                  _filterValuesProvider.updateFilterValueProperties(
                    selectedCategory: null,
                  );
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
    LibraryFilterValues filterValues = _filterValuesProvider.filterValues;

    if (_isSelectingBooks) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 8.0),
          Text(
            "${_selectedBooks.length}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
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
                  filterValues.selectedCategory == null) {
                _openCategoriesAdd();
              } else if (_selectedBooks.isNotEmpty &&
                  filterValues.selectedCategory != null) {
                _openCategoriesRemove();
              }
            },
            child: Text(_selectedBooks.isNotEmpty &&
                    filterValues.selectedCategory == null
                ? "Add to category"
                : "Remove from category"),
          ),
          IconButton(
            onPressed: () => _removeAllBooksFromSelection(),
            icon: const Icon(Icons.close),
          ),
        ],
      )
          .animate(key: _bannerAnimationKey)
          .fade(duration: const Duration(milliseconds: 100));
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
    )
        .animate(key: _bannerAnimationKey)
        .fade(duration: const Duration(milliseconds: 100));
  }

  Widget _buildTile(int index) {
    if (index < _userLibraryList.length && !_isOffline) {
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
    } else if (index < _indexModelList.length && _isOffline) {
      var model = _indexModelList[index];
      var isSelected = _isBookSelected(index);

      return LibraryOfflineGridTileWidget(
        indexModel: model,
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
          child: _hasMore ? const CircularProgressIndicator() : Container(),
        ),
      );
    }
  }

  void _openInfo(int index) async {
    await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          if (!_isOffline) {
            return LibraryInfoWidget(libraryEntry: _userLibraryList[index]);
          } else {
            return LibraryOfflineInfoWidget(indexModel: _indexModelList[index]);
          }
        }).then((result) {
      if (result == null) return;
      if (result == true) _refresh();
    });
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return const LibraryFiltersWidget();
      },
    );
  }

  void _openSorts() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return const LibraryViewWidget();
        });
  }

  void _openCategories() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const LibraryCategoriesWidget();
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
        );
      },
    );
  }

  void _enterBookSelection() {
    setState(() {
      _isSelectingBooks = true;
      _bannerAnimationKey = UniqueKey();
      _logger.info("Started selecting books!");
    });
  }

  void _exitBookSelection() {
    setState(() {
      _isSelectingBooks = false;
      _bannerAnimationKey = UniqueKey();
      _logger.info("Stopped selecting books!");
    });
  }

  void _addBookToSelection(int index, int entryId) {
    setState(() {
      if (_selectedBooks.isEmpty) {
        _enterBookSelection();
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
        _exitBookSelection();
      }
    });
  }

  void _removeAllBooksFromSelection() {
    setState(() {
      _exitBookSelection();
      _selectedBooks.clear();
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
    } else {
      _openInfo(index);
    }
  }

  void _onBookLongPress(int index, int entryId) {
    if (_isSelectingBooks) return;

    _addBookToSelection(index, entryId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _filterValuesProvider.addListener(_refresh);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _filterValuesProvider.removeListener(_refresh);
    _filterValuesProvider.clearFilterValues(notify: false);
    super.dispose();
  }

  @override
  void initState() {
    _userLibraryProvider = context.read<UserLibraryProvider>();
    _ebookIndexProvider = context.read<EbookIndexProvider>();
    _filterValuesProvider = context.read<LibraryFilterValuesProvider>();
    super.initState();

    Future.microtask(() {
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
                      itemCount: !_isOffline
                          ? _userLibraryList.length + 1
                          : _indexModelList.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildTile(index);
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
                            onPressed: _enterBookSelection,
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
