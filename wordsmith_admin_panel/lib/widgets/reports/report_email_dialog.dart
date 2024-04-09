import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_admin_panel/screens/reports_screen.dart';
import 'package:wordsmith_admin_panel/widgets/input_field.dart';
import 'package:wordsmith_utils/dialogs/progress_line_dialog.dart';
import 'package:wordsmith_utils/models/ebook_report/ebook_report_email_send.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/user_report/user_report_email_send.dart';
import 'package:wordsmith_utils/providers/ebook_reports_provider.dart';
import 'package:wordsmith_utils/providers/user_reports_provider.dart';
import 'package:wordsmith_utils/show_snackbar.dart';
import 'package:wordsmith_utils/validators.dart';

class ReportEmailDialogWidget extends StatefulWidget {
  final int reportId;
  final ReportType type;

  const ReportEmailDialogWidget({
    super.key,
    required this.reportId,
    required this.type,
  });

  @override
  State<ReportEmailDialogWidget> createState() =>
      _ReportEmailDialogWidgetState();
}

class _ReportEmailDialogWidgetState extends State<ReportEmailDialogWidget> {
  late UserReportsProvider _userReportsProvider;
  late EbookReportsProvider _ebookReportsProvider;

  final _dialogKey = GlobalKey<ProgressLineDialogState>();
  final _formKey = GlobalKey<FormState>();
  final _bodyController = TextEditingController();

  bool _sendingInProgress = false;

  Widget _buildTitle() {
    switch (widget.type) {
      case ReportType.user:
        return const Text("Send email to reported user");
      case ReportType.ebook:
        return const Text("Send email to the author");
      case ReportType.app:
        return const Text("NOT DEFINED");
    }
  }

  @override
  void initState() {
    _userReportsProvider = context.read<UserReportsProvider>();
    _ebookReportsProvider = context.read<EbookReportsProvider>();
    super.initState();
  }

  void _sendEmail() async {
    if (_sendingInProgress || !_formKey.currentState!.validate()) {
      return;
    }
    _sendingInProgress = true;
    _dialogKey.currentState!.toggleProgressLine();

    if (widget.type == ReportType.user) {
      var emailSend = UserReportEmailSend(
          reportId: widget.reportId, body: _bodyController.text);

      await _userReportsProvider.sendEmail(emailSend).then((result) {
        _sendingInProgress = false;
        _dialogKey.currentState!.toggleProgressLine();
        switch (result) {
          case Success():
            showSnackbar(context: context, content: result.data.message!);
            Navigator.of(context).pop();
          case Failure():
            showSnackbar(
              context: context,
              content: result.exception.message,
              backgroundColor: Colors.red,
            );
        }
      });
    } else if (widget.type == ReportType.ebook) {
      var emailSend = EbookReportEmailSend(
          reportId: widget.reportId, body: _bodyController.text);

      await _ebookReportsProvider.sendEmail(emailSend).then((result) {
        _dialogKey.currentState!.toggleProgressLine();
        _sendingInProgress = false;
        switch (result) {
          case Success():
            showSnackbar(context: context, content: result.data.message!);
            Navigator.of(context).pop();
          case Failure():
            showSnackbar(
              context: context,
              content: result.exception.message,
              backgroundColor: Colors.red,
            );
        }
      });
    }
  }

  void dismiss() {
    if (_sendingInProgress) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ProgressLineDialog(
        key: _dialogKey,
        title: _buildTitle(),
        content: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: InputField(
              labelText: "Body",
              controller: _bodyController,
              validator: validateRequired,
              maxLines: 5,
              maxLength: 400,
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => dismiss(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => _sendEmail(),
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }
}
