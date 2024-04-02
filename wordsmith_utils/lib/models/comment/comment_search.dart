import 'package:json_annotation/json_annotation.dart';

part "comment_search.g.dart";

@JsonSerializable(createFactory: false)
class CommentSearch {
  final bool? isShown;
  final int? eBookChapterId;
  final int? eBookId;
  final int? userId;

  const CommentSearch({
    this.isShown,
    this.eBookChapterId,
    this.eBookId,
    this.userId,
  });

  Map<String, dynamic> toJson() => _$CommentSearchToJson(this);
}
