import 'package:json_annotation/json_annotation.dart';

part "note.g.dart";

@JsonSerializable(createToJson: false)
class Note {
  final int id;
  final int userId;
  final int eBookId;
  final String content;
  final DateTime dateAdded;
  final String cfi;
  final String referencedText;

  const Note(
    this.id,
    this.userId,
    this.eBookId,
    this.content,
    this.dateAdded,
    this.cfi,
    this.referencedText,
  );

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
}
