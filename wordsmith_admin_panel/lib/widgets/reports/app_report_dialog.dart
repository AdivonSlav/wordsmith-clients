import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_utils/dialogs/progress_indicator_dialog.dart';
import 'package:wordsmith_utils/formatters/datetime_formatter.dart';
import 'package:wordsmith_utils/models/app_report/app_report.dart';
import 'package:wordsmith_utils/models/app_report/app_report_update.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/providers/app_report_provider.dart';
import 'package:wordsmith_utils/show_snackbar.dart';

class AppReportDialogWidget extends StatefulWidget {
  final int reportId;

  const AppReportDialogWidget({super.key, required this.reportId});

  @override
  State<AppReportDialogWidget> createState() => _AppReportDialogWidgetState();
}

class _AppReportDialogWidgetState extends State<AppReportDialogWidget> {
  late AppReportProvider _appReportProvider;

  late Future<Result<QueryResult<AppReport>>> _appReportFuture;

  bool _closingReportInProgress = false;

  final _labelStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 11.0,
  );

  Widget _buildContent() {
    return SingleChildScrollView(
      child: SizedBox(
        width: 450.0,
        height: 550.0,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder(
              future: _appReportFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || snapshot.data == null) {
                  return Center(
                      child: Text(snapshot.error?.toString() ?? "Error"));
                }

                late AppReport report;

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
                                builder: (context) =>
                                    _buildReporterCard(report)),
                            Builder(
                              builder: (context) =>
                                  _buildSubmissionDateCard(report),
                            ),
                          ],
                        ),
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

  Widget _buildReporterCard(AppReport report) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Reported by", style: _labelStyle),
              const SizedBox(height: 4.0),
              Text(report.user.username),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmissionDateCard(AppReport report) {
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
                  date: report.submissionDate,
                  format: "MMM d, y H:mm:ss",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportContentCard(AppReport report) {
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
                  child: SelectableText(report.content),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportActions(AppReport report) {
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
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: report.isClosed ? null : () => _closeReport(),
            icon: report.isClosed
                ? const Icon(Icons.check)
                : const Icon(Icons.close),
            label: report.isClosed
                ? const Text("Closed")
                : const Text("Close report"),
          ),
        ),
      ],
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

    var update = const AppReportUpdate(isClosed: true);

    await _appReportProvider
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

  void _refresh() {
    setState(() {
      _appReportFuture = _appReportProvider.getAppReport(widget.reportId);
    });
  }

  void _dismiss() {
    if (_closingReportInProgress) return;
    Navigator.of(context).pop();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appReportProvider.addListener(_refresh);
  }

  @override
  void dispose() {
    _appReportProvider.removeListener(_refresh);
    super.dispose();
  }

  @override
  void initState() {
    _appReportProvider = context.read<AppReportProvider>();
    _refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AlertDialog(
        title: const Text("App report"),
        content: _buildContent(),
        actions: _buildActions(),
      ),
    );
  }
}
