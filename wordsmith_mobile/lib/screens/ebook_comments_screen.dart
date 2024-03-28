import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/utils/filters/comment_filter_values.dart';
import 'package:wordsmith_mobile/widgets/input_field.dart';
import 'package:wordsmith_utils/dialogs/progress_indicator_dialog.dart';
import 'package:wordsmith_utils/dialogs/show_error_dialog.dart';
import 'package:wordsmith_utils/formatters/datetime_formatter.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/comment/comment.dart';
import 'package:wordsmith_utils/models/comment/comment_insert.dart';
import 'package:wordsmith_utils/models/comment/comment_search.dart';
import 'package:wordsmith_utils/models/ebook/ebook.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/sorting_directions.dart';
import 'package:wordsmith_utils/providers/comment_provider.dart';
import 'package:wordsmith_utils/show_snackbar.dart';
import 'package:wordsmith_utils/validators.dart';

class EbookCommentsScreenWidget extends StatefulWidget {
  final Ebook ebook;
  final bool isInLibrary;

  const EbookCommentsScreenWidget({
    super.key,
    required this.ebook,
    required this.isInLibrary,
  });

  @override
  State<EbookCommentsScreenWidget> createState() =>
      _EbookCommentsScreenWidgetState();
}

class _EbookCommentsScreenWidgetState extends State<EbookCommentsScreenWidget> {
  final _logger = LogManager.getLogger("EbookCommentsScreen");
  late CommentProvider _commentProvider;

  final _scrollController = ScrollController();
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<Comment> _comments = [];
  final CommentFilterValues _commentFilterValues = CommentFilterValues(
    sort: CommentSorts.mostRecent,
    sortDirection: SortDirections.descending,
  );
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  final int _pageSize = 15;
  int _totalCount = 0;

  bool _showCommentAdd = false;

  void _showAddComment() {
    if (!widget.isInLibrary) {
      showSnackbar(
        context: context,
        content:
            "You cannot comment on an ebook you do not have in your library!",
      );
      return;
    }

    setState(() {
      _showCommentAdd = !_showCommentAdd;
      _commentController.clear();
    });
  }

  Widget _buildCommentAddButton() {
    return ElevatedButton.icon(
      onPressed: () => _showAddComment(),
      icon: !_showCommentAdd
          ? const Icon(Icons.add_comment)
          : const Icon(Icons.cancel),
      label: !_showCommentAdd ? const Text("Add") : const Text("Cancel"),
    );
  }

  Widget _buildCommentAddField() {
    return Visibility(
      visible: _showCommentAdd,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 8.0,
          right: 8.0,
          top: 18.0,
          bottom: 8.0,
        ),
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: InputField(
                controller: _commentController,
                labelText: "Add a comment",
                obscureText: false,
                validator: validateCommentContent,
                maxLines: 6,
                maxLength: 400,
              ),
            ),
            ElevatedButton(
                onPressed: () => _submitNewComment(),
                child: const Text("Submit")),
          ],
        ),
      ).animate().fade(duration: const Duration(milliseconds: 100)),
    );
  }

  Widget _buildSegmentedFilter() {
    return SegmentedButton(
      showSelectedIcon: false,
      segments: [
        ButtonSegment<CommentSorts>(
          value: CommentSorts.mostRecent,
          label: Text(CommentSorts.mostRecent.label),
        ),
        ButtonSegment<CommentSorts>(
          value: CommentSorts.mostPopular,
          label: Text(CommentSorts.mostPopular.label),
        ),
      ],
      selected: <CommentSorts>{_commentFilterValues.sort},
      onSelectionChanged: (Set<CommentSorts> newSelection) {
        setState(() {
          _commentFilterValues.sort = newSelection.first;
        });
      },
    );
  }

  Widget _buildCommentCount() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text("${_totalCount.toString()} comments"),
    );
  }

  Widget _buildCommentList() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _comments.length + 1,
      itemBuilder: (context, index) {
        if (index >= _comments.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Center(
              child: _hasMore ? const CircularProgressIndicator() : Container(),
            ),
          );
        }

        var comment = _comments[index];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.user?.username ?? "Unknown",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  comment.content,
                  style: const TextStyle(fontSize: 14.0),
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      timeAgoSinceDate(date: comment.dateAdded),
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          iconSize: 24.0,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          style: const ButtonStyle(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: const Icon(Icons.favorite_border),
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          "${comment.likeCount.toString()} likes",
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitNewComment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ProgressIndicatorDialog().show(context, text: "Submitting...");

    var newComment = CommentInsert(
      content: _commentController.text,
      eBookId: widget.ebook.id,
      eBookChapterId: null,
    );

    await _commentProvider.postComment(newComment).then((result) {
      ProgressIndicatorDialog().dismiss();
      switch (result) {
        case Success(data: final d):
          _refresh();
          _showAddComment();
          showSnackbar(
            context: context,
            content: "Posted comment",
          );
        case Failure(exception: final e):
          showSnackbar(context: context, content: e.toString());
      }
    });
  }

  Future _getComments() async {
    if (_isLoading) return;
    _isLoading = true;

    List<Comment> commentResult = [];
    var search = CommentSearch(eBookId: widget.ebook.id);

    await _commentProvider
        .getComments(
      search,
      page: _page,
      pageSize: _pageSize,
      orderBy:
          "${_commentFilterValues.sort.apiValue}:${_commentFilterValues.sortDirection.apiValue}",
    )
        .then((result) {
      switch (result) {
        case Success(data: final d):
          commentResult = d.result;
          _totalCount = d.totalCount!;
        case Failure(exception: final e):
          showErrorDialog(context: context, content: Text(e.toString()));
      }
    });

    setState(() {
      _page++;
      _isLoading = false;

      if (commentResult.length < _pageSize) {
        _hasMore = false;
      }

      _comments.addAll(commentResult);
    });
  }

  Future _refresh() async {
    setState(() {
      _isLoading = false;
      _hasMore = true;
      _page = 1;
      _comments.clear();
    });

    _getComments();
  }

  @override
  void initState() {
    _commentProvider = context.read<CommentProvider>();
    super.initState();

    Future.microtask(() => _getComments());

    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        _logger.info("Reached the end, should fetch more comments!");
        _getComments();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Comments",
          style: theme.textTheme.titleMedium,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Builder(builder: (context) => _buildSegmentedFilter()),
                Builder(builder: (context) => _buildCommentAddButton()),
              ],
            ),
            Builder(builder: (context) => _buildCommentCount()),
            Builder(builder: (context) => _buildCommentAddField()),
            const Divider(height: 24.0),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Builder(
                    builder: (context) => _buildCommentList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
