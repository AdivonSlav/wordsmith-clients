import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/utils/filters/ebook_filter_values.dart';
import 'package:wordsmith_mobile/widgets/ebook/ebook_filters.dart';
import 'package:wordsmith_mobile/widgets/ebook/ebook_list_tile.dart';
import 'package:wordsmith_mobile/widgets/ebook/ebook_view.dart';
import 'package:wordsmith_mobile/widgets/input_field.dart';
import 'package:wordsmith_utils/dialogs/show_error_dialog.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/ebook/ebook.dart';
import 'package:wordsmith_utils/models/ebook/ebook_search.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/sorting_directions.dart';
import 'package:wordsmith_utils/providers/ebook_provider.dart';

class EbookBrowseScreenWidget extends StatefulWidget {
  const EbookBrowseScreenWidget({super.key});

  @override
  State<EbookBrowseScreenWidget> createState() =>
      _EbookBrowseScreenWidgetState();
}

class _EbookBrowseScreenWidgetState extends State<EbookBrowseScreenWidget> {
  final _logger = LogManager.getLogger("EbookBrowseScreen");

  late EbookProvider _ebookProvider;
  late EbookFilterValuesProvider _filterValuesProvider;

  final _scrollController = ScrollController();
  final _titleController = TextEditingController();

  Timer? _titleDebounce;

  final List<Ebook> _ebooks = [];
  bool _isLoadingEbooks = false;
  bool _hasMore = false;
  int _page = 1;
  final int _pageSize = 5;
  int _totalCount = 0;

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
                onPressed: () => _openEbookFiltersSheet(),
                icon: const Icon(Icons.tune)),
            Text("$_totalCount books"),
            IconButton(
                onPressed: () => _openEbookViewSheet(),
                icon: const Icon(Icons.sort)),
          ],
        ),
        InputField(
          labelText: "Search by title",
          controller: _titleController,
          obscureText: false,
          onChangedCallback: (value) {
            if (_titleDebounce?.isActive ?? false) {
              _titleDebounce!.cancel();
            }

            _titleDebounce = Timer(const Duration(milliseconds: 200), () {
              _filterValuesProvider.updateFilterValueProperties(title: value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildEbookList() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _ebooks.length + 1,
      itemBuilder: (context, index) {
        if (index >= _ebooks.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Center(
              child: _hasMore ? const CircularProgressIndicator() : Container(),
            ),
          );
        }

        var ebook = _ebooks[index];

        return EbookListTile(ebook: ebook);
      },
    );
  }

  void _openEbookFiltersSheet() {
    if (_isLoadingEbooks) return;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return const EbookFiltersWidget();
      },
    );
  }

  void _openEbookViewSheet() {
    if (_isLoadingEbooks) return;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return const EbookViewWidget();
      },
    );
  }

  void _getEbooks() async {
    if (_isLoadingEbooks) return;
    _isLoadingEbooks = true;

    final filterValues = _filterValuesProvider.filterValues;

    List<Ebook> ebooksResult = [];
    var search = EbookSearch(
      maturityRatingId: filterValues.selectedMaturityRatingId,
      title: filterValues.title,
    );
    var sort = filterValues.sort;
    var sortDirection = filterValues.sortDirection;

    await _ebookProvider
        .getEbooks(search,
            page: _page,
            pageSize: _pageSize,
            orderBy: "${sort.apiValue}:${sortDirection.apiValue}")
        .then((result) {
      switch (result) {
        case Success():
          ebooksResult = result.data.result;
          _totalCount = result.data.totalCount!;
        case Failure():
          showErrorDialog(
            context: context,
            content: Text(result.exception.message),
          );
      }
    });

    if (mounted) {
      setState(() {
        _page++;
        _isLoadingEbooks = false;

        if (ebooksResult.length < _pageSize) {
          _hasMore = false;
        }

        _ebooks.addAll(ebooksResult);
      });
    }
  }

  Future _refresh() async {
    if (mounted) {
      setState(() {
        _isLoadingEbooks = false;
        _hasMore = false;
        _page = 1;
        _ebooks.clear();
      });

      _getEbooks();
    }
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
    _ebookProvider = context.read<EbookProvider>();
    _filterValuesProvider = context.read<EbookFilterValuesProvider>();

    Future.microtask(() {
      _getEbooks();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        _logger.info("Reached the end, should fetch more ebooks");
        _getEbooks();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Builder(builder: (context) => _buildHeader()),
          const Divider(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Builder(
                  builder: (context) => _buildEbookList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
