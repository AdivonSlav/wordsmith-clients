// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_insert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentInsert _$CommentInsertFromJson(Map<String, dynamic> json) =>
    CommentInsert(
      content: json['content'] as String,
      eBookChapterId: json['eBookChapterId'] as int?,
      eBookId: json['eBookId'] as int,
    );

Map<String, dynamic> _$CommentInsertToJson(CommentInsert instance) =>
    <String, dynamic>{
      'content': instance.content,
      'eBookChapterId': instance.eBookChapterId,
      'eBookId': instance.eBookId,
    };
