import 'package:json_annotation/json_annotation.dart';
import 'package:wordsmith_utils/models/ebook.dart';

part "user_library.g.dart";

@JsonSerializable()
class UserLibrary {
  final int eBookId;
  final int userId;
  final EBook? eBook;
  final DateTime syncDate;
  final bool isRead;
  final String? readProgress;
  final int lastChapterId;
  final int lastPage;

  UserLibrary(this.eBookId, this.userId, this.syncDate, this.isRead,
      this.readProgress, this.lastChapterId, this.lastPage, this.eBook);

  factory UserLibrary.fromJson(Map<String, dynamic> json) =>
      _$UserLibraryFromJson(json);

  Map<String, dynamic> toJson() => _$UserLibraryToJson(this);
}
