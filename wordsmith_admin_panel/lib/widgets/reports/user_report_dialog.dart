import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_admin_panel/screens/reports_screen.dart';
import 'package:wordsmith_admin_panel/widgets/reports/report_email_dialog.dart';
import 'package:wordsmith_admin_panel/widgets/users/ban_user_dialog.dart';
import 'package:wordsmith_utils/dialogs/progress_indicator_dialog.dart';
import 'package:wordsmith_utils/formatters/datetime_formatter.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/user/user.dart';
import 'package:wordsmith_utils/models/user/user_status.dart';
import 'package:wordsmith_utils/models/user_report/user_report.dart';
import 'package:wordsmith_utils/models/user_report/user_report_update.dart';
import 'package:wordsmith_utils/providers/user_provider.dart';
import 'package:wordsmith_utils/providers/user_reports_provider.dart';
import 'package:wordsmith_utils/show_snackbar.dart';

class UserReportDialogWidget extends StatefulWidget {
  final int reportId;

  const UserReportDialogWidget({super.key, required this.reportId});

  @override
  State<UserReportDialogWidget> createState() => _UserReportDialogWidgetState();
}

class _UserReportDialogWidgetState extends State<UserReportDialogWidget> {
  late UserReportsProvider _userReportsProvider;
  late UserProvider _userProvider;

  late Future<Result<QueryResult<UserReport>>> _userReportFuture;

  bool _closingReportInProgress = false;

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
                onPressed: report.reportDetails.isClosed
                    ? null
                    : () => _openSendEmailDialog(report.id),
                icon: const Icon(Icons.email),
                label: const Text("Send email to user"),
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: FilledButton.icon(
                onPressed:
                    report.reportDetails.isClosed ? null : () => _closeReport(),
                icon: report.reportDetails.isClosed
                    ? const Icon(Icons.check)
                    : const Icon(Icons.close),
                label: report.reportDetails.isClosed
                    ? const Text("Closed")
                    : const Text("Close report"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10.0),
        Visibility(
          visible: !report.reportDetails.isClosed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: FilledButton.icon(
                  onPressed: report.reportedUser.status != UserStatus.active
                      ? null
                      : () => _openBanUserDialog(report.reportedUser),
                  icon: const Icon(
                    Icons.block_flipped,
                    color: Colors.white,
                  ),
                  label: Text(
                    report.reportedUser.status != UserStatus.active
                        ? "Already banned"
                        : "Ban user",
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red[700],
                  ),
                ),
              ),
            ],
          ),
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
        onPressed: () => _dismiss(),
        child: const Text("Close"),
      ),
    ];
  }

  void _closeReport() async {
    if (_closingReportInProgress) return;
    _closingReportInProgress = true;
    ProgressIndicatorDialog().show(context, text: "Closing...");

    var update = const UserReportUpdate(isClosed: true);

    await _userReportsProvider
        .updateReport(id: widget.reportId, request: update, notify: true)
        .then((result) {
      ProgressIndicatorDialog().dismiss();
      _closingReportInProgress = false;
      switch (result) {
        case Success():
          showSnackbar(context: context, content: "Succesfully closed report");
        case Failure():
          showSnackbar(
              context: context,
              content: result.exception.message,
              backgroundColor: Colors.red);
      }
    });
  }

  void _openSendEmailDialog(int reportId) {
    showDialog(
      context: context,
      builder: (context) =>
          ReportEmailDialogWidget(reportId: reportId, type: ReportType.user),
    );
  }

  void _openBanUserDialog(User user) async {
    showDialog(
      context: context,
      builder: (context) => BanUserDialogWidget(user: user),
    );
  }

  void _refresh() {
    setState(() {
      _userReportFuture = _userReportsProvider.getUserReport(widget.reportId);
    });
  }

  void _dismiss() {
    if (_closingReportInProgress) return;
    Navigator.of(context).pop();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userProvider.addListener(_refresh);
    _userReportsProvider.addListener(_refresh);
  }

  @override
  void dispose() {
    _userProvider.removeListener(_refresh);
    _userReportsProvider.removeListener(_refresh);
    super.dispose();
  }

  @override
  void initState() {
    _userReportsProvider = context.read<UserReportsProvider>();
    _userProvider = context.read<UserProvider>();
    _refresh();
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
