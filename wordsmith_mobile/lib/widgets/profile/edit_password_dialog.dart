import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/widgets/input_field.dart';
import 'package:wordsmith_utils/dialogs/progress_line_dialog.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/user/user.dart';
import 'package:wordsmith_utils/models/user/user_update.dart';
import 'package:wordsmith_utils/providers/auth_provider.dart';
import 'package:wordsmith_utils/providers/user_provider.dart';
import 'package:wordsmith_utils/show_snackbar.dart';
import 'package:wordsmith_utils/validators.dart';

class EditPasswordDialogWidget extends StatefulWidget {
  const EditPasswordDialogWidget({super.key});

  @override
  State<EditPasswordDialogWidget> createState() =>
      _EditPasswordDialogWidgetState();
}

class _EditPasswordDialogWidgetState extends State<EditPasswordDialogWidget> {
  late UserProvider _userProvider;
  late AuthProvider _authProvider;

  final _dialogKey = GlobalKey<ProgressLineDialogState>();
  final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  bool _changingInProgress = false;

  Widget _buildContent() {
    var size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              InputField(
                labelText: "New password",
                maxLines: 1,
                controller: _passwordController,
                validator: validatePassword,
                obscureText: true,
              ),
              const SizedBox(height: 16.0),
              InputField(
                labelText: "Old password",
                maxLines: 1,
                controller: _oldPasswordController,
                obscureText: true,
              ),
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
          onPressed: () => _changePassword(), child: const Text("Change")),
    ];
  }

  void _dismiss() {
    if (!_changingInProgress) {
      Navigator.of(context).pop();
    }
  }

  void _toggleChangingInProgress() {
    setState(() {
      _dialogKey.currentState!.toggleProgressLine();
      _changingInProgress = !_changingInProgress;
    });
  }

  void _changePassword() async {
    var loggedUser = AuthProvider.loggedUser;

    if (_changingInProgress ||
        !_formKey.currentState!.validate() ||
        loggedUser == null) {
      return;
    }
    _toggleChangingInProgress();

    var request = UserUpdate(
      username: loggedUser.username,
      email: loggedUser.email,
      about: loggedUser.about,
      password: _passwordController.text,
      oldPassword: _oldPasswordController.text,
    );

    await _userProvider.updateLoggeduser(request).then((result) async {
      _toggleChangingInProgress();
      switch (result) {
        case Success<User>():
          showSnackbar(
            context: context,
            content: "Succesfully changed password",
          );
          await _authProvider.storeLogin(user: result.data);
          _dismiss();
        case Failure<User>():
          showSnackbar(
            context: context,
            content: result.exception.message,
            backgroundColor: Colors.red,
          );
      }
    });
  }

  @override
  void initState() {
    _userProvider = context.read<UserProvider>();
    _authProvider = context.read<AuthProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ProgressLineDialog(
        key: _dialogKey,
        title: const Text("Change password"),
        content: _buildContent(),
        actions: _buildActions(),
      ),
    );
  }
}
