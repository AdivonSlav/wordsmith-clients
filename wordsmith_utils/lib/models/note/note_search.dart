import 'package:json_annotation/json_annotation.dart';

part "note_search.g.dart";

@JsonSerializable(createFactory: false)
class NoteSearch {
  final int? userId;
  final int? eBookId;

  const NoteSearch({
    required this.userId,
    required this.eBookId,
  });

  Map<String, dynamic> toJson() => _$NoteSearchToJson(this);
}
