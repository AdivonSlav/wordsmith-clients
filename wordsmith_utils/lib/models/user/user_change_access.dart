import 'package:json_annotation/json_annotation.dart';

part "user_change_access.g.dart";

@JsonSerializable()
class UserChangeAccess {
  final bool allowedAccess;
  final DateTime? expiryDate;

  const UserChangeAccess({
    required this.allowedAccess,
    this.expiryDate,
  });

  factory UserChangeAccess.fromJson(Map<String, dynamic> json) =>
      _$UserChangeAccessFromJson(json);

  Map<String, dynamic> toJson() => _$UserChangeAccessToJson(this);
}
