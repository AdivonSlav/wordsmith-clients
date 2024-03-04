import "package:json_annotation/json_annotation.dart";
import "package:wordsmith_utils/models/image/image.dart";
import "package:wordsmith_utils/models/maturity_rating/maturity_rating.dart";
import "package:wordsmith_utils/models/user/user.dart";

part "ebook.g.dart";

@JsonSerializable()
class EBook {
  final int id;
  final String title;
  final String description;
  final double? ratingAverage;
  final DateTime publishedDate;
  final DateTime updatedDate;
  final double? price;
  final int chapterCount;
  final String path;
  final User author;
  Image coverArt;
  final String genres;
  final MaturityRating maturityRating;

  EBook(
    this.id,
    this.title,
    this.description,
    this.ratingAverage,
    this.publishedDate,
    this.updatedDate,
    this.price,
    this.chapterCount,
    this.path,
    this.author,
    this.coverArt,
    this.genres,
    this.maturityRating,
  );

  factory EBook.fromJson(Map<String, dynamic> json) => _$EBookFromJson(json);

  Map<String, dynamic> toJson() => _$EBookToJson(this);
}
