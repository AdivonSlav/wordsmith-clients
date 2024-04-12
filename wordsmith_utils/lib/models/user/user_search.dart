import 'package:json_annotation/json_annotation.dart';

part "user_search.g.dart";

@JsonSerializable(createFactory: false)
class UserSearch {
  final String? username;

  const UserSearch({
    required this.username,
  });

  Map<String, dynamic> toJson() => _$UserSearchToJson(this);
}
