import "package:wordsmith_utils/models/ebook_report.dart";
import "package:wordsmith_utils/providers/base_provider.dart";

class EBookReportsProvider extends BaseProvider<EBookReport> {
  EBookReportsProvider() : super("ebook-reports");

  @override
  EBookReport fromJson(data) {
    return EBookReport.fromJson(data);
  }
}
