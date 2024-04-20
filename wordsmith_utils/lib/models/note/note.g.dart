// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Note _$NoteFromJson(Map<String, dynamic> json) => Note(
      json['id'] as int,
      json['userId'] as int,
      json['eBookId'] as int,
      json['content'] as String,
      DateTime.parse(json['dateAdded'] as String),
      json['cfi'] as String,
      json['referencedText'] as String,
    );
