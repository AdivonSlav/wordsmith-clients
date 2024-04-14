import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/screens/profile_screen.dart';
import 'package:wordsmith_mobile/utils/filters/comment_filter_values.dart';
import 'package:wordsmith_mobile/widgets/input_field.dart';
import 'package:wordsmith_mobile/widgets/profile/profile_image.dart';
import 'package:wordsmith_utils/dialogs/progress_indicator_dialog.dart';
import 'package:wordsmith_utils/dialogs/show_error_dialog.dart';
import 'package:wordsmith_utils/formatters/datetime_formatter.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/comment/comment.dart';
import 'package:wordsmith_utils/models/comment/comment_insert.dart';
import 'package:wordsmith_utils/models/comment/comment_search.dart';
import 'package:wordsmith_utils/models/ebook_chapter/ebook_chapter.dart';
import 'package:wordsmith_utils/models/ebook_chapter/ebook_chapter_search.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/sorting_directions.dart';
import 'package:wordsmith_utils/models/user/user.dart';
import 'package:wordsmith_utils/providers/auth_provider.dart';
import 'package:wordsmith_utils/providers/comment_provider.dart';
import 'package:wordsmith_utils/providers/ebook_chapter_provider.dart';
import 'package:wordsmith_utils/show_snackbar.dart';
import 'package:wordsmith_utils/validators.dart';

class EbookCommentsScreenWidget extends StatefulWidget {
  final int ebookId;
  final bool isInLibrary;
  final int? ebookChapterId;

  const EbookCommentsScreenWidget({
    super.key,
    required this.ebookId,
    required this.isInLibrary,
    this.ebookChapterId,
  });

  @override
  State<EbookCommentsScreenWidget> createState() =>
      _EbookCommentsScreenWidgetState();
}

class _EbookCommentsScreenWidgetState extends State<EbookCommentsScreenWidget> {
  final _logger = LogManager.getLogger("EbookCommentsScreen");
  late CommentProvider _commentProvider;
  late EbookChapterProvider _chapterProvider;

  final _scrollController = ScrollController();
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final Color _likeColor = const Color(0xFFFF9529);
  final List<Comment> _comments = [];
  List<EbookChapter> _chapters = [];
  int? _selectedChapterId;
  final CommentFilterValues _commentFilterValues = CommentFilterValues(
    sort: CommentSorts.mostRecent,
    sortDirection: SortDirections.descending,
  );
  bool _isLoadingComments = false;
  bool _isLoadingChapters = false;
  bool _hasMore = true;
  int _page = 1;
  final int _pageSize = 15;
  int _totalCount = 0;
  bool _showCommentAdd = false;
  bool _likingInProgress = false;
  bool _deletingInProgress = false;

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
          value: CommentSorts.mostLiked,
          label: Text(CommentSorts.mostLiked.label),
        ),
      ],
      selected: <CommentSorts>{_commentFilterValues.sort},
      onSelectionChanged: (Set<CommentSorts> newSelection) {
        setState(() {
          _commentFilterValues.sort = newSelection.first;
          _refresh();
        });
      },
    );
  }

  Widget _buildChapterSelect() {
    return Row(
      children: [
        const Text("Select a chapter:"),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton(
              isExpanded: true,
              value: _selectedChapterId,
              onChanged: (value) {
                setState(() {
                  _selectedChapterId = value;
                  _refresh();
                });
              },
              selectedItemBuilder: (context) {
                return _chapters.map<Widget>((value) {
                  return Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value.chapterName,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList();
              },
              items: _chapters.map<DropdownMenuItem<int>>((chapter) {
                return DropdownMenuItem(
                  value: chapter.id,
                  child: Text(chapter.chapterName),
                );
              }).toList(),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _selectedChapterId = null;
              _refresh();
            });
          },
          icon: const Icon(Icons.clear),
        ),
      ],
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => _showAuthorProfileScreen(comment.user),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ProfileImageWidget(
                              profileImagePath:
                                  comment.user?.profileImage?.imagePath,
                              radius: 12.0,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showAuthorProfileScreen(comment.user),
                          child: Text(
                            comment.user?.username ?? "Unknown",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      comment.eBookChapter?.chapterName ?? "",
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey,
                      ),
                    ),
                  ],
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
                        Visibility(
                          visible:
                              comment.userId == AuthProvider.loggedUser?.id,
                          child: IconButton(
                            onPressed: () => _deleteComment(index),
                            iconSize: 20.0,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            style: const ButtonStyle(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: const Icon(Icons.delete),
                          ),
                        ),
                        const SizedBox(width: 14.0),
                        IconButton(
                          onPressed: () => _likeComment(index),
                          iconSize: 20.0,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          style: const ButtonStyle(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: !comment.hasLiked
                              ? const Icon(Icons.thumb_up_alt_outlined)
                              : Icon(Icons.thumb_up_alt, color: _likeColor),
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
      eBookId: widget.ebookId,
      eBookChapterId: _selectedChapterId,
    );

    await _commentProvider.postComment(newComment).then((result) {
      ProgressIndicatorDialog().dismiss();
      switch (result) {
        case Success():
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

  void _likeComment(int index) async {
    if (_likingInProgress) {
      return;
    }
    _likingInProgress = true;

    var comment = _comments[index];

    if (!comment.hasLiked) {
      await _commentProvider.likeComment(comment.id).then((result) {
        switch (result) {
          case Success(data: final d):
            setState(() {
              _comments[index] = d.result!;
              _likingInProgress = false;
            });
          case Failure(exception: final e):
            showSnackbar(context: context, content: e.toString());
            _likingInProgress = false;
        }
      });
    } else {
      await _commentProvider.removeLike(comment.id).then((result) {
        switch (result) {
          case Success(data: final d):
            setState(() {
              _comments[index] = d.result!;
              _likingInProgress = false;
            });
          case Failure(exception: final e):
            showSnackbar(context: context, content: e.toString());
            _likingInProgress = false;
        }
      });
    }
  }

  void _deleteComment(int index) async {
    if (_deletingInProgress) {
      return;
    }

    var shouldDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete comment"),
        content: const Text("Do you want to delete this comment?"),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (!shouldDelete) return;

    _deletingInProgress = true;

    var comment = _comments[index];

    await _commentProvider.deleteComment(comment.id).then((result) {
      switch (result) {
        case Success():
          _refresh();
          _deletingInProgress = false;
        case Failure(exception: final e):
          showSnackbar(context: context, content: e.toString());
          _deletingInProgress = false;
      }
    });
  }

  Future _getComments() async {
    if (_isLoadingComments) return;
    _isLoadingComments = true;

    List<Comment> commentResult = [];
    var search = CommentSearch(
      eBookId: widget.ebookId,
      eBookChapterId: _selectedChapterId,
    );

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

    if (mounted) {
      setState(() {
        _page++;
        _isLoadingComments = false;

        if (commentResult.length < _pageSize) {
          _hasMore = false;
        }

        _comments.addAll(commentResult);
      });
    }
  }

  Future _getChapters() async {
    if (_isLoadingChapters) return;
    _isLoadingChapters = true;

    var search = EbookChapterSearch(eBookId: widget.ebookId);

    await _chapterProvider
        .getChapters(search, pageSize: 1000, orderBy: "ChapterNumber:asc")
        .then((result) {
      switch (result) {
        case Success(data: final d):
          _isLoadingChapters = false;
          if (mounted) {
            setState(() {
              _chapters = d.result;
            });
          }
        case Failure(exception: final e):
          showErrorDialog(context: context, content: Text(e.toString()));
      }
    });
  }

  void _showAuthorProfileScreen(User? user) {
    if (user == null) return;
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ProfileScreenWidget(userId: user.id)));
  }

  Future _refresh() async {
    if (mounted) {
      setState(() {
        _isLoadingComments = false;
        _hasMore = true;
        _page = 1;
        _comments.clear();
      });

      _getComments();
    }
  }

  @override
  void initState() {
    _commentProvider = context.read<CommentProvider>();
    _chapterProvider = context.read<EbookChapterProvider>();
    super.initState();

    _selectedChapterId = widget.ebookChapterId;

    Future.microtask(() {
      _getComments();
      _getChapters();
    });

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
      resizeToAvoidBottomInset: false,
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
            Builder(builder: (context) => _buildChapterSelect()),
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
