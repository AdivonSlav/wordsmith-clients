import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/widgets/input_field.dart';
import 'package:wordsmith_utils/dialogs/progress_line_dialog.dart';
import 'package:wordsmith_utils/models/query_result.dart';
import 'package:wordsmith_utils/models/report/report_reason.dart';
import 'package:wordsmith_utils/models/report/report_reason_search.dart';
import 'package:wordsmith_utils/models/report/report_type.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/user_report/user_report_insert.dart';
import 'package:wordsmith_utils/providers/report_reason_provider.dart';
import 'package:wordsmith_utils/providers/user_reports_provider.dart';
import 'package:wordsmith_utils/show_snackbar.dart';
import 'package:wordsmith_utils/validators.dart';

class UserReportDialogWidget extends StatefulWidget {
  final int userId;

  const UserReportDialogWidget({super.key, required this.userId});

  @override
  State<UserReportDialogWidget> createState() => _UserReportDialogWidgetState();
}

class _UserReportDialogWidgetState extends State<UserReportDialogWidget> {
  late UserReportsProvider _userReportsProvider;
  late ReportReasonProvider _reportReasonProvider;

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
      FilledButton(
        onPressed: () => _reportUser(),
        child: const Text("Report"),
      ),
    ];
  }

  void _reportUser() async {
    if (!_reasonFormKey.currentState!.validate() ||
        !_descriptionFormKey.currentState!.validate()) {
      return;
    }

    if (_isReportingInProgress || _selectedReasonId == null) return;
    _toggleReportingInProgress();

    var request = UserReportInsert(
      reportedUserId: widget.userId,
      content: _reasonDescriptionController.text,
      reportReasonId: _selectedReasonId!,
    );

    await _userReportsProvider.postReport(request).then((result) {
      _toggleReportingInProgress();
      switch (result) {
        case Success():
          showSnackbar(context: context, content: "Succesfully reported user");
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
    var search = const ReportReasonSearch(type: ReportType.user);
    _reportReasonFuture = _reportReasonProvider.getReportReasons(search);
  }

  @override
  void initState() {
    _userReportsProvider = context.read<UserReportsProvider>();
    _reportReasonProvider = context.read<ReportReasonProvider>();
    _getReportReasons();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ProgressLineDialog(
        key: _dialogKey,
        title: const Text("Report user"),
        content: _buildContent(),
        actions: _buildActions(),
      ),
    );
  }
}
