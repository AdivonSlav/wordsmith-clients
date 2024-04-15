import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/widgets/input_field.dart';
import 'package:wordsmith_utils/dialogs/progress_line_dialog.dart';
import 'package:wordsmith_utils/models/app_report/app_report_insert.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/providers/app_report_provider.dart';
import 'package:wordsmith_utils/show_snackbar.dart';
import 'package:wordsmith_utils/validators.dart';

class AppReportDialogWidget extends StatefulWidget {
  const AppReportDialogWidget({super.key});

  @override
  State<AppReportDialogWidget> createState() => _AppReportDialogWidgetState();
}

class _AppReportDialogWidgetState extends State<AppReportDialogWidget> {
  late AppReportProvider _appReportProvider;

  final _dialogKey = GlobalKey<ProgressLineDialogState>();
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  bool _isReportingInProgress = false;

  Widget _buildContent() {
    var size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
              "If you have a feature request or want to report a certain bug, please provide more information below"),
          const SizedBox(height: 8.0),
          SizedBox(
            width: size.width,
            child: Form(
              key: _formKey,
              child: InputField(
                enabled: !_isReportingInProgress,
                labelText: "Description",
                obscureText: false,
                validator: validateRequired,
                controller: _descriptionController,
                maxLines: 4,
                maxLength: 200,
              ),
            ),
          ),
        ],
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
        onPressed: () => _report(),
        child: const Text("Report"),
      ),
    ];
  }

  void _report() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isReportingInProgress) return;
    _toggleReportingInProgress();

    var request = AppReportInsert(content: _descriptionController.text);

    await _appReportProvider.postReport(request).then((result) {
      _toggleReportingInProgress();
      switch (result) {
        case Success():
          showSnackbar(context: context, content: "Succesfully reported");
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

  @override
  void initState() {
    _appReportProvider = context.read<AppReportProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ProgressLineDialog(
        key: _dialogKey,
        title: const Text("Report"),
        content: _buildContent(),
        actions: _buildActions(),
      ),
    );
  }
}
