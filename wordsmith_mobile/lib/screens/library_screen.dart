import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/utils/library_filter_values.dart';
import 'package:wordsmith_mobile/widgets/ebook_image.dart';
import 'package:wordsmith_mobile/widgets/library_categories.dart';
import 'package:wordsmith_mobile/widgets/library_filters.dart';
import 'package:wordsmith_mobile/widgets/library_view.dart';
import 'package:wordsmith_utils/dialogs.dart';
import 'package:wordsmith_utils/exceptions/unauthorized_exception.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/user_library/user_library.dart';
import 'package:wordsmith_utils/providers/maturity_ratings_provider.dart';
import 'package:wordsmith_utils/providers/user_library_provider.dart';

class LibraryScreenWidget extends StatefulWidget {
  const LibraryScreenWidget({super.key});

  @override
  State<StatefulWidget> createState() => _LibraryScreenWidgetState();
}

class _LibraryScreenWidgetState extends State<LibraryScreenWidget> {
  final _logger = LogManager.getLogger("LibraryScreen");
  late UserLibraryProvider _userLibraryProvider;
  late MaturityRatingsProvider _maturityRatingsProvider;
  final _scrollController = ScrollController();

  final List<UserLibrary> _userLibraryList = [];
  final _pageSize = 15;
  var _page = 1;
  var _hasMore = true;
  var _isLoading = false;
  LibraryFilterValues? _filterValues;

  Future _getLibraryBooks() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      var libraryResult = await _userLibraryProvider.getLibraryEntries(
        maturityRatingId: _filterValues?.selectedMaturityRating,
        isRead: _filterValues?.isRead,
        orderBy: _filterValues != null
            ? "${_filterValues!.sortByProperty}:${_filterValues!.sortByDirection}"
            : "EBook.Title:asc",
        libraryCategoryId: _filterValues?.selectedCategory?.id,
        page: _page,
        pageSize: _pageSize,
      );

      setState(() {
        _page++;
        _isLoading = false;

        if (libraryResult.result.length < _pageSize) {
          _hasMore = false;
        }

        _userLibraryList.addAll(libraryResult.result);
      });
    } on Exception catch (error) {
      if (context.mounted) {
        await showErrorDialog(
            context, const Text("Error"), Text(error.toString()));
      }
      _logger.severe(error);
    }
  }

  Future _buildFilterValues() async {
    try {
      var ratingResult = await _maturityRatingsProvider.getMaturityRatings();

      setState(() {
        _filterValues = LibraryFilterValues(
          maturityRatings: ratingResult.result,
          sortByProperty: "EBook.Title",
          sortByDirection: "asc",
        );
      });
    } on UnauthorizedException catch (error) {
      _logger.info(error);
    } on Exception catch (error) {
      if (context.mounted) {
        await showErrorDialog(
            context, const Text("Error"), Text(error.toString()));
      }
      _logger.severe(error);
    }
  }

  Future _refresh() async {
    setState(() {
      _isLoading = false;
      _hasMore = true;
      _page = 1;
      _userLibraryList.clear();
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

  @override
  void initState() {
    _userLibraryProvider = context.read<UserLibraryProvider>();
    _maturityRatingsProvider = context.read<MaturityRatingsProvider>();
    super.initState();

    _buildFilterValues();
    _getLibraryBooks();

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
    var size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: <Widget>[
          Row(
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
          ),
          const Divider(
            height: 1.0,
          ),
          Builder(builder: (context) => _buildCategoryIndicator()),
          SizedBox(
            height: size.height * 0.5,
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 1.0,
                  mainAxisSpacing: 15.0,
                ),
                itemCount: _userLibraryList.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index < _userLibraryList.length) {
                    var ebook = _userLibraryList[index].eBook!;

                    return GridTile(
                      child: GestureDetector(
                        onTap: null,
                        child: EBookImageWidget(
                          coverArtUrl: ebook.coverArt.imagePath,
                        ),
                      ),
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
          )
        ],
      ),
    );
  }
}
