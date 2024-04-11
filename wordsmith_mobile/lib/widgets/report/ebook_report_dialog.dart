import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/widgets/input_field.dart';
import 'package:wordsmith_utils/dialogs/progress_line_dialog.dart';
import 'package:wordsmith_utils/models/ebook_report/ebook_report_insert.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/report/report_reason.dart';
import 'package:wordsmith_utils/models/report/report_reason_search.dart';
import 'package:wordsmith_utils/models/report/report_type.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/providers/ebook_reports_provider.dart';
import 'package:wordsmith_utils/providers/report_reason_provider.dart';
import 'package:wordsmith_utils/show_snackbar.dart';
import 'package:wordsmith_utils/validators.dart';

class EbookReportDialogWidget extends StatefulWidget {
  final int ebookId;

  const EbookReportDialogWidget({super.key, required this.ebookId});

  @override
  State<EbookReportDialogWidget> createState() =>
      _EbookReportDialogWidgetState();
}

class _EbookReportDialogWidgetState extends State<EbookReportDialogWidget> {
  late ReportReasonProvider _reportReasonProvider;
  late EbookReportsProvider _ebookReportsProvider;

  late Future<Result<QueryResult<ReportReason>>> _reportReasonFuture;

  final _dialogKey = GlobalKey<ProgressLineDialogState>();
  final _reasonFormKey = GlobalKey<FormState>();
  final _descriptionFormKey = GlobalKey<FormState>();
  int? _selectedReasonId;
  final _reasonDescriptionController = TextEditingController();

  bool _isReportingInProgress = false;

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Builder(builder: (context) => _buildReportReasonSelection()),
          const SizedBox(height: 18.0),
          Builder(builder: (context) => _buildReportContentField()),
        ],
      ),
    );
  }

  Widget _buildReportReasonSelection() {
    return FutureBuilder(
      future: _reportReasonFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }

        late List<ReportReason> reasons;

        switch (snapshot.data!) {
          case Success(data: final d):
            reasons = d.result;
          case Failure(exception: final e):
            return Center(
              child: Text(e.toString()),
            );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text("Select report reason"),
            Form(
              key: _reasonFormKey,
              child: DropdownButtonFormField(
                isExpanded: true,
                value: _selectedReasonId,
                validator: validateRequiredNumeric,
                items: reasons.map<DropdownMenuItem<int>>((reason) {
                  return DropdownMenuItem(
                    value: reason.id,
                    child: Text(reason.reason),
                  );
                }).toList(),
                onChanged: (value) {
                  if (_isReportingInProgress) return;
                  setState(() {
                    _selectedReasonId = value;
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReportContentField() {
    var size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width,
      child: Form(
        key: _descriptionFormKey,
        child: InputField(
          enabled: !_isReportingInProgress,
          labelText: "Description",
          obscureText: false,
          validator: validateRequired,
          controller: _reasonDescriptionController,
          maxLines: 4,
          maxLength: 200,
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    return <Widget>[
      TextButton(
        onPressed: () => _dismiss(),
        child: const Text("Cancel"),
      ),
      TextButton(
        onPressed: () => _reportEbook(),
        child: const Text("Report"),
      ),
    ];
  }

  void _reportEbook() async {
    if (!_reasonFormKey.currentState!.validate() ||
        !_descriptionFormKey.currentState!.validate()) {
      return;
    }

    if (_isReportingInProgress || _selectedReasonId == null) return;
    _toggleReportingInProgress();

    var request = EbookReportInsert(
      reportedEBookId: widget.ebookId,
      content: _reasonDescriptionController.text,
      reportReasonId: _selectedReasonId!,
    );

    await _ebookReportsProvider.postReport(request).then((result) {
      _toggleReportingInProgress();
      switch (result) {
        case Success():
          showSnackbar(
              context: context,
              content: result.data.message ?? "Succesfully reported ebook");
          _dismiss();
        case Failure():
          showSnackbar(
              context: context,
              content: result.exception.message,
              backgroundColor: Colors.red);
      }
    });
  }

  void _dismiss() {
    if (!_isReportingInProgress) {
      Navigator.of(context).pop();
    }
  }

  void _toggleReportingInProgress() {
    setState(() {
      _dialogKey.currentState!.toggleProgressLine();
      _isReportingInProgress = !_isReportingInProgress;
    });
  }

  void _getReportReasons() async {
    var search = const ReportReasonSearch(type: ReportType.ebook);
    _reportReasonFuture = _reportReasonProvider.getReportReasons(search);
  }

  @override
  void initState() {
    _ebookReportsProvider = context.read<EbookReportsProvider>();
    _reportReasonProvider = context.read<ReportReasonProvider>();
    _getReportReasons();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PopScope(
        canPop: !_isReportingInProgress,
        child: ProgressLineDialog(
          key: _dialogKey,
          title: const Text("Report ebook"),
          content: _buildContent(),
          actions: _buildActions(),
        ),
      ),
    );
  }
}
