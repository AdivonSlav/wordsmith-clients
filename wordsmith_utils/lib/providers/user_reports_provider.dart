import "package:wordsmith_utils/models/user_report.dart";
import "package:wordsmith_utils/providers/base_provider.dart";

class UserReportsProvider extends BaseProvider<UserReport> {
  UserReportsProvider() : super("user-reports");

  @override
  UserReport fromJson(data) {
    return UserReport.fromJson(data);
  }
}
