import "package:json_annotation/json_annotation.dart";
import "package:wordsmith_utils/models/image/image.dart";
import "package:wordsmith_utils/models/user/user_status.dart";

part "user.g.dart";

@JsonSerializable()
class User {
  final int id;
  final String username;
  final String email;
  final Image? profileImage;
  final DateTime registrationDate;
  final UserStatus status;

  User(this.id, this.username, this.email, this.profileImage,
      this.registrationDate, this.status);

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
