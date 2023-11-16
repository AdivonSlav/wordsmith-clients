import "package:flutter/material.dart";
import "package:wordsmith_admin_panel/widgets/loading.dart";
import "package:wordsmith_utils/datetime_formatter.dart";
import "package:wordsmith_utils/models/ebook_report.dart";
import "package:wordsmith_utils/models/query_result.dart";
import "package:wordsmith_utils/models/user_report.dart";
import "package:wordsmith_utils/providers/cast.dart";
import "package:wordsmith_utils/size_config.dart";

class ReportsListWidget extends StatefulWidget {
  final Future<dynamic> reports;

  const ReportsListWidget({super.key, required this.reports});

  @override
  State<StatefulWidget> createState() => _ReportsListWidgetState();
}

class _ReportsListWidgetState extends State<ReportsListWidget> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return FutureBuilder(
      future: widget.reports,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SizedBox(
            height: SizeConfig.safeBlockVertical * 70.0,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoadingWidget(
                  width: 50.0,
                  height: 50.0,
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Column(
            children: <Widget>[
              const Text("An error occurred while fetching results."),
              Text(snapshot.error.toString())
            ],
          );
        }

        var userReports = castOrNull<QueryResult<UserReport>>(snapshot.data);
        var eBookReports = castOrNull<QueryResult<EBookReport>>(snapshot.data);

        return SizedBox(
          height: SizeConfig.safeBlockVertical * 70.0,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.separated(
                itemCount: userReports != null
                    ? userReports.result.length
                    : eBookReports!.result.length,
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(
                    height: 6,
                  );
                },
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSecondary,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      leading: (userReports != null
                              ? !userReports
                                  .result[index].reportDetails.isClosed
                              : !eBookReports!
                                  .result[index].reportDetails.isClosed)
                          ? const Icon(Icons.warning)
                          : const Icon(Icons.check),
                      title: Text(userReports != null
                          ? userReports
                              .result[index].reportDetails.reportReason.reason
                          : eBookReports!
                              .result[index].reportDetails.reportReason.reason),
                      trailing: Text(
                        formatDateTime(
                          date: userReports != null
                              ? userReports
                                  .result[index].reportDetails.submissionDate
                              : eBookReports!
                                  .result[index].reportDetails.submissionDate,
                          format: "yyyy-MM-dd H:m:s",
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
