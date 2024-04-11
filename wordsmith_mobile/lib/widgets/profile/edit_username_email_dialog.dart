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
import 'package:wordsmith_utils/validators.dart';

class EditUsernameEmailDialogWidget extends StatefulWidget {
  final User user;

  const EditUsernameEmailDialogWidget({super.key, required this.user});

  @override
  State<EditUsernameEmailDialogWidget> createState() =>
      _EditUsernameEmailDialogWidgetState();
}

class _EditUsernameEmailDialogWidgetState
    extends State<EditUsernameEmailDialogWidget> {
  late AuthProvider _authProvider;
  late UserProvider _userProvider;

  final _dialogKey = GlobalKey<ProgressLineDialogState>();
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _savingInProgress = false;

  Widget _buildContent() {
    var size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              InputField(
                labelText: "Username",
                controller: _usernameController,
                validator: validateUsername,
                obscureText: false,
              ),
              const SizedBox(height: 24.0),
              InputField(
                labelText: "Email",
                controller: _emailController,
                validator: validateEmail,
                obscureText: false,
              )
            ],
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
      username: _usernameController.text,
      email: _emailController.text,
      about: widget.user.about,
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
    _usernameController.text = widget.user.username;
    _emailController.text = widget.user.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ProgressLineDialog(
        key: _dialogKey,
        title: const Text("Edit username and email"),
        content: _buildContent(),
        actions: _buildActions(),
      ),
    );
  }
}
