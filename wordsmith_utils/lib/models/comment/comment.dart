import 'package:json_annotation/json_annotation.dart';

part "comment.g.dart";

@JsonSerializable()
class Comment {
  final int id;
  final String content;
  final DateTime dateAdded;
  final bool isShown;
  final int? eBookChapterId;
  final int eBookId;
  final int userId;
  final bool hasLiked;
  final int likeCount;

  const Comment(
    this.id,
    this.content,
    this.dateAdded,
    this.isShown,
    this.eBookChapterId,
    this.eBookId,
    this.userId,
    this.hasLiked,
    this.likeCount,
  );

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
