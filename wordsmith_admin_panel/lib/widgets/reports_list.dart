import "package:flutter/material.dart";
import "package:wordsmith_admin_panel/widgets/loading.dart";
import "package:wordsmith_utils/datetime_formatter.dart";
import "package:wordsmith_utils/models/query_result.dart";
import "package:wordsmith_utils/models/user_report.dart";
import "package:wordsmith_utils/size_config.dart";

class ReportsListWidget extends StatefulWidget {
  final Future<QueryResult<UserReport>?> userReports;

  const ReportsListWidget({super.key, required this.userReports});

  @override
  State<StatefulWidget> createState() => _ReportsListWidgetState();
}

class _ReportsListWidgetState extends State<ReportsListWidget> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return FutureBuilder(
      future: widget.userReports,
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

        QueryResult<UserReport> userReports = snapshot.data;

        return SizedBox(
          height: SizeConfig.safeBlockVertical * 70.0,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.separated(
                itemCount: userReports.result.length,
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
                      leading: !userReports.result[index].reportDetails.isClosed
                          ? const Icon(Icons.warning)
                          : const Icon(Icons.check),
                      title: Text(userReports
                          .result[index].reportDetails.reportReason.reason),
                      trailing: Text(
                        formatDateTime(
                          date: userReports
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
