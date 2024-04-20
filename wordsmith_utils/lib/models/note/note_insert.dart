import 'package:json_annotation/json_annotation.dart';

part "note_insert.g.dart";

@JsonSerializable(createFactory: false)
class NoteInsert {
  final int eBookId;
  final String content;
  final String cfi;
  final String referencedText;

  const NoteInsert({
    required this.eBookId,
    required this.content,
    required this.cfi,
    required this.referencedText,
  });

  Map<String, dynamic> toJson() => _$NoteInsertToJson(this);
}
