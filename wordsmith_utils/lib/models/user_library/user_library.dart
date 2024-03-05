import 'package:json_annotation/json_annotation.dart';
import 'package:wordsmith_utils/models/ebook/ebook.dart';

part "user_library.g.dart";

@JsonSerializable()
class UserLibrary {
  final int id;
  final int eBookId;
  final int userId;
  final Ebook eBook;
  final DateTime syncDate;
  final bool isRead;
  final String readProgress;
  final int? userLibraryCategoryId;
  final int lastChapterId;
  final int lastPage;

  UserLibrary(
    this.id,
    this.eBookId,
    this.userId,
    this.syncDate,
    this.isRead,
    this.readProgress,
    this.userLibraryCategoryId,
    this.lastChapterId,
    this.lastPage,
    this.eBook,
  );

  factory UserLibrary.fromJson(Map<String, dynamic> json) =>
      _$UserLibraryFromJson(json);

  Map<String, dynamic> toJson() => _$UserLibraryToJson(this);
}
