import "package:json_annotation/json_annotation.dart";

part "maturity_rating.g.dart";

@JsonSerializable()
class MaturityRating {
  final int id;
  final String name;
  final String shortName;

  MaturityRating(this.id, this.name, this.shortName);

  factory MaturityRating.fromJson(Map<String, dynamic> json) =>
      _$MaturityRatingFromJson(json);

  Map<String, dynamic> toJson() => _$MaturityRatingToJson(this);
}
