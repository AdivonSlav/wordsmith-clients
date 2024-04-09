import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_admin_panel/screens/reports_screen.dart';
import 'package:wordsmith_admin_panel/widgets/reports/report_email_dialog.dart';
import 'package:wordsmith_admin_panel/widgets/users/ban_user_dialog.dart';
import 'package:wordsmith_utils/formatters/datetime_formatter.dart';
import 'package:wordsmith_utils/models/ebook_report/ebook_report.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/user/user.dart';
import 'package:wordsmith_utils/models/user/user_status.dart';
import 'package:wordsmith_utils/providers/ebook_reports_provider.dart';
import 'package:wordsmith_utils/providers/user_provider.dart';

class EbookReportDialogWidget extends StatefulWidget {
  final int reportId;

  const EbookReportDialogWidget({super.key, required this.reportId});

  @override
  State<EbookReportDialogWidget> createState() =>
      _EbookReportDialogWidgetState();
}

class _EbookReportDialogWidgetState extends State<EbookReportDialogWidget> {
  late EbookReportsProvider _ebookReportsProvider;
  late UserProvider _userProvider;

  late Future<Result<QueryResult<EbookReport>>> _ebookReportFuture;

  final _labelStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 11.0,
  );

  Widget _buildReporterCard(EbookReport report) {
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

  Widget _buildSubmissionDateCard(EbookReport report) {
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

  Widget _buildReportReasonCard(EbookReport report) {
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

  Widget _buildReportedEbookCard(EbookReport report) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Reported ebook",
                style: _labelStyle,
              ),
              const SizedBox(height: 4.0),
              RichText(
                text: TextSpan(
                  text: "Title:  ",
                  children: <TextSpan>[
                    TextSpan(
                      text: report.reportedEBook.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  text: "Author:  ",
                  children: <TextSpan>[
                    TextSpan(
                      text: report.reportedEBook.author.username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
              const Spacer(),
              Align(
                alignment: Alignment.center,
                child: Wrap(
                  spacing: 12.0,
                  runSpacing: 8.0,
                  children: <Widget>[
                    OutlinedButton(
                      onPressed: () {}, // TODO
                      child: const Text("Go to ebook"),
                    ),
                    OutlinedButton(
                      onPressed: () {}, // TODO
                      child: const Text("Go to author"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportContentCard(EbookReport report) {
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

  Widget _buildReportActions(EbookReport report) {
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
                label: const Text("Send email to author"),
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
                  Icons.visibility_off,
                  color: Colors.white,
                ),
                label: const Text(
                  "Hide ebook",
                  style: TextStyle(color: Colors.white),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red[700],
                ),
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: FilledButton.icon(
                onPressed:
                    report.reportedEBook.author.status != UserStatus.active
                        ? null
                        : () => _openBanUserDialog(report.reportedEBook.author),
                icon: const Icon(
                  Icons.block_flipped,
                  color: Colors.white,
                ),
                label: Text(
                  report.reportedEBook.author.status != UserStatus.active
                      ? "Already banned"
                      : "Ban author",
                  style: const TextStyle(color: Colors.white),
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
            future: _ebookReportFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || snapshot.data == null) {
                return Center(
                    child: Text(snapshot.error?.toString() ?? "Error"));
              }

              late EbookReport report;

              switch (snapshot.data!) {
                case Success(data: final d):
                  report = d.result.first;
                case Failure(exception: final e):
                  return Center(child: Text(e.message));
              }

              return SizedBox(
                width: 500.0,
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
                                  _buildReportReasonCard(report)),
                          Builder(
                            builder: (context) =>
                                _buildSubmissionDateCard(report),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Builder(
                          builder: (context) =>
                              _buildReportedEbookCard(report)),
                    ),
                    Flexible(
                      flex: 3,
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
          ReportEmailDialogWidget(reportId: reportId, type: ReportType.ebook),
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
      _ebookReportFuture =
          _ebookReportsProvider.getEbookReport(widget.reportId);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userProvider.addListener(_refresh);
  }

  @override
  void dispose() {
    _userProvider.removeListener(_refresh);
    super.dispose();
  }

  @override
  void initState() {
    _ebookReportsProvider = context.read<EbookReportsProvider>();
    _userProvider = context.read<UserProvider>();
    _ebookReportFuture = _ebookReportsProvider.getEbookReport(widget.reportId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AlertDialog(
        title: const Text("Ebook report"),
        content: _buildContent(),
        actions: _buildActions(),
      ),
    );
  }
}
