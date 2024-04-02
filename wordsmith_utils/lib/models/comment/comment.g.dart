// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      json['id'] as int,
      json['content'] as String,
      DateTime.parse(json['dateAdded'] as String),
      json['isShown'] as bool,
      json['eBookChapterId'] as int?,
      json['eBookChapter'] == null
          ? null
          : EbookChapter.fromJson(json['eBookChapter'] as Map<String, dynamic>),
      json['eBookId'] as int,
      json['userId'] as int,
      json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      json['hasLiked'] as bool,
      json['likeCount'] as int,
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'dateAdded': instance.dateAdded.toIso8601String(),
      'isShown': instance.isShown,
      'eBookChapterId': instance.eBookChapterId,
      'eBookChapter': instance.eBookChapter,
      'eBookId': instance.eBookId,
      'userId': instance.userId,
      'user': instance.user,
      'hasLiked': instance.hasLiked,
      'likeCount': instance.likeCount,
    };
