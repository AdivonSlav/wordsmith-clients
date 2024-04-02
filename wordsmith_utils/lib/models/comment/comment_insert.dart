import 'package:json_annotation/json_annotation.dart';

part "comment_insert.g.dart";

@JsonSerializable()
class CommentInsert {
  final String content;
  final int? eBookChapterId;
  final int eBookId;

  const CommentInsert({
    required this.content,
    required this.eBookChapterId,
    required this.eBookId,
  });

  factory CommentInsert.fromJson(Map<String, dynamic> json) =>
      _$CommentInsertFromJson(json);

  Map<String, dynamic> toJson() => _$CommentInsertToJson(this);
}
