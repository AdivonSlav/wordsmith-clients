import "package:json_annotation/json_annotation.dart";

part "maturity_rating.g.dart";

@JsonSerializable()
class MaturityRating {
  final int id;
  final String name;

  MaturityRating(this.id, this.name);

  factory MaturityRating.fromJson(Map<String, dynamic> json) =>
      _$MaturityRatingFromJson(json);

  Map<String, dynamic> toJson() => _$MaturityRatingToJson(this);
}
