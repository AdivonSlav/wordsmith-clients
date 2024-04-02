import 'package:json_annotation/json_annotation.dart';

part "ebook_chapter_search.g.dart";

@JsonSerializable(createFactory: false)
class EbookChapterSearch {
  final String? chapterName;
  final int? eBookId;

  const EbookChapterSearch({
    this.chapterName,
    this.eBookId,
  });

  Map<String, dynamic> toJson() => _$EbookChapterSearchToJson(this);
}
