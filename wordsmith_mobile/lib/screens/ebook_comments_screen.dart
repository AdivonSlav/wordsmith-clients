import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wordsmith_mobile/utils/filters/comment_filter_values.dart';
import 'package:wordsmith_mobile/widgets/input_field.dart';
import 'package:wordsmith_utils/models/ebook/ebook.dart';
import 'package:wordsmith_utils/models/sorting_directions.dart';
import 'package:wordsmith_utils/show_snackbar.dart';

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
  final _commentController = TextEditingController();
  bool _showCommentAdd = false;

  final CommentFilterValues _commentFilterValues = CommentFilterValues(
    sort: CommentSorts.mostRecent,
    sortDirection: SortDirections.descending,
  );

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
        child: InputField(
          controller: _commentController,
          labelText: "Add a comment",
          obscureText: false,
          maxLines: 6,
          maxLength: 400,
        ),
      ).animate().fade(duration: const Duration(milliseconds: 100)),
    );
  }

  Widget _buildSegmentedFilter() {
    return SegmentedButton(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment<CommentSorts>(
          value: CommentSorts.mostRecent,
          label: Text("Newest"),
        ),
        ButtonSegment<CommentSorts>(
          value: CommentSorts.mostPopular,
          label: Text("Most popular"),
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

  Widget _buildCommentList() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: 25,
      itemBuilder: (context, index) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "User #1",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  "Comment content",
                  style: TextStyle(fontSize: 14.0),
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "1st of January, 2024",
                      style: TextStyle(
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
                        const Text(
                          "2 likes",
                          style: TextStyle(
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
            Builder(builder: (context) => _buildCommentAddField()),
            const Divider(height: 24.0),
            Expanded(
              child: Builder(
                builder: (context) => _buildCommentList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
