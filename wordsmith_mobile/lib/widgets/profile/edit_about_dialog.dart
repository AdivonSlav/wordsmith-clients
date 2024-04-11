import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/widgets/input_field.dart';
import 'package:wordsmith_utils/dialogs/progress_line_dialog.dart';
import 'package:wordsmith_utils/dialogs/show_error_dialog.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/user/user.dart';
import 'package:wordsmith_utils/models/user/user_update.dart';
import 'package:wordsmith_utils/providers/auth_provider.dart';
import 'package:wordsmith_utils/providers/user_provider.dart';
import 'package:wordsmith_utils/show_snackbar.dart';

class EditAboutDialogWidget extends StatefulWidget {
  final User user;

  const EditAboutDialogWidget({super.key, required this.user});

  @override
  State<EditAboutDialogWidget> createState() => _EditAboutDialogWidgetState();
}

class _EditAboutDialogWidgetState extends State<EditAboutDialogWidget> {
  late AuthProvider _authProvider;
  late UserProvider _userProvider;

  final _dialogKey = GlobalKey<ProgressLineDialogState>();
  final _formKey = GlobalKey<FormState>();
  final _aboutController = TextEditingController();

  bool _savingInProgress = false;

  Widget _buildContent() {
    var size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: InputField(
            labelText: "About me",
            controller: _aboutController,
            maxLength: 100,
            maxLines: 3,
            obscureText: false,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    return <Widget>[
      TextButton(onPressed: () => _dismiss(), child: const Text("Cancel")),
      FilledButton(
          onPressed: () => _updateProfile(), child: const Text("Save")),
    ];
  }

  void _updateProfile() async {
    if (_savingInProgress || !_formKey.currentState!.validate()) {
      return;
    }
    _toggleSavingInProgress();

    var request = UserUpdate(
      username: widget.user.username,
      email: widget.user.email,
      about: _aboutController.text,
    );

    await _userProvider.updateLoggeduser(request).then((result) {
      _toggleSavingInProgress();
      switch (result) {
        case Success<User>():
          showSnackbar(
              context: context, content: "Succesfully updated profile");
          _authProvider.storeLogin(user: result.data);
          _dismiss();
        case Failure<User>():
          showErrorDialog(
              context: context, content: Text(result.exception.message));
      }
    });
  }

  void _toggleSavingInProgress() {
    setState(() {
      _dialogKey.currentState!.toggleProgressLine();
      _savingInProgress = !_savingInProgress;
    });
  }

  void _dismiss() {
    if (!_savingInProgress) {
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    _authProvider = context.read<AuthProvider>();
    _userProvider = context.read<UserProvider>();
    super.initState();
    _aboutController.text = widget.user.about;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ProgressLineDialog(
        key: _dialogKey,
        title: const Text("Edit about me"),
        content: _buildContent(),
        actions: _buildActions(),
      ),
    );
  }
}
