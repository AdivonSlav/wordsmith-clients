import 'package:json_annotation/json_annotation.dart';

part "ebook_search.g.dart";

@JsonSerializable(createFactory: false)
class EbookSearch {
  final String? title;
  final List<int>? genres;
  final int? maturityRatingId;
  final int? authorId;

  const EbookSearch({
    this.title,
    this.genres,
    this.maturityRatingId,
    this.authorId,
  });

  Map<String, dynamic> toJson() => _$EbookSearchToJson(this);
}
