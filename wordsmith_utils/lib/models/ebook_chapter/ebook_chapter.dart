import 'package:json_annotation/json_annotation.dart';

part "ebook_chapter.g.dart";

@JsonSerializable()
class EbookChapter {
  final int id;
  final String chapterName;
  final int chapterNumber;
  final int eBookId;

  const EbookChapter(
    this.id,
    this.chapterName,
    this.chapterNumber,
    this.eBookId,
  );

  factory EbookChapter.fromJson(Map<String, dynamic> json) =>
      _$EbookChapterFromJson(json);
  Map<String, dynamic> toJson() => _$EbookChapterToJson(this);
}
