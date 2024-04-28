import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_admin_panel/screens/reports_screen.dart';
import 'package:wordsmith_admin_panel/widgets/reports/report_email_dialog.dart';
import 'package:wordsmith_admin_panel/widgets/users/ban_user_dialog.dart';
import 'package:wordsmith_utils/dialogs/progress_indicator_dialog.dart';
import 'package:wordsmith_utils/formatters/datetime_formatter.dart';
import 'package:wordsmith_utils/models/ebook_report/ebook_report.dart';
import 'package:wordsmith_utils/models/ebook_report/ebook_report_update.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/user/user.dart';
import 'package:wordsmith_utils/models/user/user_status.dart';
import 'package:wordsmith_utils/providers/ebook_provider.dart';
import 'package:wordsmith_utils/providers/ebook_reports_provider.dart';
import 'package:wordsmith_utils/providers/user_provider.dart';
import 'package:wordsmith_utils/show_snackbar.dart';

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
  late EbookProvider _ebookProvider;

  late Future<Result<QueryResult<EbookReport>>> _ebookReportFuture;

  bool _closingReportInProgress = false;
  bool _hidingEbookInProgress = false;

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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Visibility(
              visible: !report.reportDetails.isClosed &&
                  report.reportedEBook.author.status == UserStatus.active,
              child: Expanded(
                child: FilledButton.icon(
                  onPressed: report.reportedEBook.isHidden
                      ? () => _unhideEbook(report)
                      : () => _hideEbook(report),
                  icon: report.reportedEBook.isHidden
                      ? const Icon(
                          Icons.visibility,
                          color: Colors.white,
                        )
                      : const Icon(
                          Icons.visibility_off,
                          color: Colors.white,
                        ),
                  label: Text(
                    report.reportedEBook.isHidden
                        ? "Unhide ebook"
                        : "Hide ebook",
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red[700],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10.0),
            Visibility(
              visible: !report.reportDetails.isClosed,
              child: Expanded(
                child: FilledButton.icon(
                  onPressed: report.reportedEBook.author.status !=
                          UserStatus.active
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
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: SizedBox(
        width: 500.0,
        height: 550.0,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
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
                    if (d.result.isEmpty) {
                      return const Center(child: Text("No report found"));
                    }
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
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Builder(
                                builder: (context) =>
                                    _buildReporterCard(report)),
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
                      Builder(
                          builder: (context) => _buildReportActions(report)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
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

    var update = const EbookReportUpdate(isClosed: true);

    await _ebookReportsProvider
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

  void _hideEbook(EbookReport report) async {
    if (_hidingEbookInProgress) return;
    _hidingEbookInProgress = true;
    ProgressIndicatorDialog().show(context, text: "Processing...");

    await _ebookProvider
        .hideEbook(ebookId: report.reportedEBook.id, notify: true)
        .then((result) {
      ProgressIndicatorDialog().dismiss();
      _hidingEbookInProgress = false;
      switch (result) {
        case Success():
          showSnackbar(context: context, content: "Succesfully hid ebook");
        case Failure():
          showSnackbar(
              context: context,
              content: result.exception.message,
              backgroundColor: Colors.red);
      }
    });
  }

  void _unhideEbook(EbookReport report) async {
    if (_hidingEbookInProgress) return;
    _hidingEbookInProgress = true;
    ProgressIndicatorDialog().show(context, text: "Processing...");

    await _ebookProvider
        .unhideEbook(ebookId: report.reportedEBook.id, notify: true)
        .then((result) {
      ProgressIndicatorDialog().dismiss();
      _hidingEbookInProgress = false;
      switch (result) {
        case Success():
          showSnackbar(
              context: context,
              content: "Succesfully made the ebook visible again");
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

  void _dismiss() {
    if (_closingReportInProgress) return;
    Navigator.of(context).pop();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userProvider.addListener(_refresh);
    _ebookReportsProvider.addListener(_refresh);
    _ebookProvider.addListener(_refresh);
  }

  @override
  void dispose() {
    _userProvider.removeListener(_refresh);
    _ebookReportsProvider.removeListener(_refresh);
    _ebookProvider.removeListener(_refresh);
    super.dispose();
  }

  @override
  void initState() {
    _ebookReportsProvider = context.read<EbookReportsProvider>();
    _userProvider = context.read<UserProvider>();
    _ebookProvider = context.read<EbookProvider>();
    _refresh();
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
