import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:wordsmith_admin_panel/widgets/loading.dart";
import "package:wordsmith_utils/dialogs.dart";
import "package:wordsmith_utils/exceptions/base_exception.dart";
import "package:wordsmith_utils/logger.dart";
import "package:wordsmith_utils/models/query_result.dart";
import "package:wordsmith_utils/models/user_report.dart";
import "package:wordsmith_utils/providers/user_login_provider.dart";
import "package:wordsmith_utils/providers/user_reports_provider.dart";
import "package:wordsmith_utils/size_config.dart";

class ReportsScreenWidget extends StatefulWidget {
  final _logger = LogManager.getLogger("ReportsScreen");

  ReportsScreenWidget({super.key});

  @override
  State<StatefulWidget> createState() => _ReportsScreenWidgetState();
}

class _ReportsScreenWidgetState extends State<ReportsScreenWidget> {
  late UserLoginProvider _userLoginProvider;
  late UserReportsProvider _userReportsProvider;

  int _pageSize = 10;
  late QueryResult<UserReport> _userReports;
  // EBookReports should also be a property here when implemented

  Future<QueryResult<UserReport>?> getUserReports() async {
    String? accessToken = await _userLoginProvider.getAccessToken(context);

    if (accessToken == null) return null;

    Map<String, String> queries = {
      "page": "1",
      "pageSize": _pageSize.toString(),
    };

    var result = await _userReportsProvider.get(
        filter: queries, bearerToken: accessToken);

    return result;
  }

  Future<void> getAllReports() async {
    try {
      var userReportResult = await getUserReports();

      if (userReportResult != null) {
        _userReports = userReportResult;
      }
    } on BaseException catch (error) {
      return Future.error(error);
    } on Exception catch (error) {
      widget._logger.severe(error);
      return Future.error(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    _userLoginProvider = context.read<UserLoginProvider>();
    _userReportsProvider = context.read<UserReportsProvider>();
    var theme = Theme.of(context);

    return FutureBuilder(
      future: getAllReports(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const LoadingWidget();
        }

        if (snapshot.hasError) {
          return Column(
            children: <Widget>[
              const Text("An error occurred while fetching results."),
              Text(snapshot.error.toString())
            ],
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text("User reports: ${_userReports.totalCount}"),
              SizedBox(
                width: SizeConfig.safeBlockHorizontal * 30.0,
                height: SizeConfig.safeBlockVertical * 30.0,
                child: Card(
                  child: ListView.builder(
                    itemCount: _userReports.result.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading:
                            !_userReports.result[index].reportDetails.isClosed
                                ? Icon(Icons.warning)
                                : Icon(Icons.check),
                        title: Text(_userReports
                            .result[index].reportDetails.reportReason.reason),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
