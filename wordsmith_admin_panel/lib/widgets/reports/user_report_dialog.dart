import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_admin_panel/screens/reports_screen.dart';
import 'package:wordsmith_admin_panel/widgets/reports/report_email_dialog.dart';
import 'package:wordsmith_utils/formatters/datetime_formatter.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/user_report/user_report.dart';
import 'package:wordsmith_utils/providers/user_reports_provider.dart';

class UserReportDialogWidget extends StatefulWidget {
  final int reportId;

  const UserReportDialogWidget({super.key, required this.reportId});

  @override
  State<UserReportDialogWidget> createState() => _UserReportDialogWidgetState();
}

class _UserReportDialogWidgetState extends State<UserReportDialogWidget> {
  late UserReportsProvider _userReportsProvider;

  late Future<Result<QueryResult<UserReport>>> _userReportFuture;

  final _labelStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 11.0,
  );

  Widget _buildReporterCard(UserReport report) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Reported by", style: _labelStyle),
              const SizedBox(height: 4.0),
              Text(report.reportDetails.reporter.username),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmissionDateCard(UserReport report) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Submission date",
                style: _labelStyle,
              ),
              const SizedBox(height: 4.0),
              Text(
                formatDateTime(
                  date: report.reportDetails.submissionDate,
                  format: "MMM d, y H:mm:ss",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportedUserCard(UserReport report) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Reported user",
                style: _labelStyle,
              ),
              const SizedBox(height: 4.0),
              Text(report.reportedUser.username),
              const SizedBox(height: 8.0),
              Align(
                alignment: Alignment.center,
                child: OutlinedButton(
                  onPressed: () {}, // TODO
                  child: const Text("Go to user"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportReasonCard(UserReport report) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Report reason",
                style: _labelStyle,
              ),
              const SizedBox(height: 4.0),
              Text(report.reportDetails.reportReason.reason),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportContentCard(UserReport report) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Report content",
                style: _labelStyle,
              ),
              const SizedBox(height: 4.0),
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(report.reportDetails.content),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportActions(UserReport report) {
    return Column(
      children: <Widget>[
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Actions",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),
        const SizedBox(height: 12.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _openSendEmailDialog(report.id),
                icon: const Icon(Icons.email),
                label: const Text("Send email to user"),
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.close),
                label: const Text("Close report"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.block_flipped,
                  color: Colors.white,
                ),
                label: const Text(
                  "Ban user",
                  style: TextStyle(color: Colors.white),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red[700],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FutureBuilder(
            future: _userReportFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || snapshot.data == null) {
                return Center(
                    child: Text(snapshot.error?.toString() ?? "Error"));
              }

              late UserReport report;

              switch (snapshot.data!) {
                case Success(data: final d):
                  report = d.result.first;
                case Failure(exception: final e):
                  return Center(child: Text(e.message));
              }

              return SizedBox(
                width: 450.0,
                height: 550.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Builder(
                              builder: (context) => _buildReporterCard(report)),
                          Builder(
                            builder: (context) =>
                                _buildSubmissionDateCard(report),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Builder(
                              builder: (context) =>
                                  _buildReportedUserCard(report)),
                          Builder(
                              builder: (context) =>
                                  _buildReportReasonCard(report)),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Builder(
                          builder: (context) =>
                              _buildReportContentCard(report)),
                    ),
                    const Divider(),
                    Builder(builder: (context) => _buildReportActions(report)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions() {
    return <Widget>[
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text("Close"),
      ),
    ];
  }

  void _openSendEmailDialog(int reportId) {
    showDialog(
      context: context,
      builder: (context) =>
          ReportEmailDialogWidget(reportId: reportId, type: ReportType.user),
    );
  }

  @override
  void initState() {
    _userReportsProvider = context.read<UserReportsProvider>();
    _userReportFuture = _userReportsProvider.getUserReport(widget.reportId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AlertDialog(
        title: const Text("User report"),
        content: _buildContent(),
        actions: _buildActions(),
      ),
    );
  }
}
