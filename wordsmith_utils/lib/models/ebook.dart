import "package:json_annotation/json_annotation.dart";
import "package:wordsmith_utils/models/genre.dart";
import "package:wordsmith_utils/models/image.dart";
import "package:wordsmith_utils/models/maturity_rating.dart";

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
  final Image coverArt;
  final Genre genre;
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
      this.coverArt,
      this.genre,
      this.maturityRating);

  factory EBook.fromJson(Map<String, dynamic> json) => _$EBookFromJson(json);

  Map<String, dynamic> toJson() => _$EBookToJson(this);
}
