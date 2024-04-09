import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_admin_panel/widgets/input_field.dart';
import 'package:wordsmith_utils/dialogs/progress_line_dialog.dart';
import 'package:wordsmith_utils/formatters/datetime_formatter.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/user/user.dart';
import 'package:wordsmith_utils/models/user/user_change_access.dart';
import 'package:wordsmith_utils/providers/user_provider.dart';
import 'package:wordsmith_utils/show_snackbar.dart';

class BanUserDialogWidget extends StatefulWidget {
  final User user;

  const BanUserDialogWidget({super.key, required this.user});

  @override
  State<BanUserDialogWidget> createState() => _BanUserDialogWidgetState();
}

class _BanUserDialogWidgetState extends State<BanUserDialogWidget> {
  late UserProvider _userProvider;

  final _dialogKey = GlobalKey<ProgressLineDialogState>();

  bool _banInProgress = false;
  bool _pickingExpirationDate = false;
  DateTime? _pickedExpirationDate;
  final _expirationDateValueController = TextEditingController();

  void _banUser() async {
    if (_banInProgress) return;
    _banInProgress = true;
    _dialogKey.currentState!.toggleProgressLine();

    var changeAccessRequest = UserChangeAccess(
      allowedAccess: false,
      expiryDate: _pickedExpirationDate,
    );

    await _userProvider
        .changeUserAccess(userId: widget.user.id, request: changeAccessRequest)
        .then((result) {
      _dialogKey.currentState!.toggleProgressLine();
      _banInProgress = false;
      switch (result) {
        case Success():
          showSnackbar(context: context, content: "Succesfully banned user");
          Navigator.of(context).pop();
        case Failure():
          showSnackbar(
              context: context,
              content: result.exception.message,
              backgroundColor: Colors.red);
      }
    });
  }

  void _pickExpirationDate() async {
    _pickedExpirationDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (_pickedExpirationDate != null) {
      _expirationDateValueController.text = formatDateTime(
        date: _pickedExpirationDate!,
        format: "yMMMd",
      );
    }
  }

  void _dismiss() {
    if (_banInProgress) return;
    Navigator.of(context).pop();
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            "Are you sure you want to ban user ${widget.user.username}?",
          ),
          const SizedBox(height: 14.0),
          Row(
            children: [
              Checkbox(
                value: _pickingExpirationDate,
                onChanged: (value) {
                  setState(() {
                    _pickingExpirationDate = value!;
                    _expirationDateValueController.clear();
                    _pickedExpirationDate = null;
                  });
                },
              ),
              const Text("Select expiration date for ban")
            ],
          ),
          const SizedBox(height: 8.0),
          Visibility(
            visible: _pickingExpirationDate,
            child: Column(
              children: [
                TextButton(
                  onPressed: () => _pickExpirationDate(),
                  child: const Text("Pick date"),
                ),
                InputField(
                  enabled: false,
                  controller: _expirationDateValueController,
                  labelText: "Picked date",
                ),
              ],
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
        onPressed: () => _banUser(),
        style: FilledButton.styleFrom(backgroundColor: Colors.red[700]),
        child: const Text(
          "Ban",
          style: TextStyle(color: Colors.white),
        ),
      ),
    ];
  }

  @override
  void initState() {
    _userProvider = context.read<UserProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ProgressLineDialog(
        key: _dialogKey,
        title: const Text("Ban user"),
        content: Builder(
          builder: (context) => _buildContent(),
        ),
        actions: _buildActions(),
      ),
    );
  }
}
