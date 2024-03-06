import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/utils/indexers/user_index_provider.dart';
import 'package:wordsmith_mobile/widgets/input_field.dart';
import 'package:wordsmith_utils/dialogs/progress_indicator_dialog.dart';
import 'package:wordsmith_utils/dialogs/show_error_dialog.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/user/user.dart';
import 'package:wordsmith_utils/models/user/user_insert.dart';
import 'package:wordsmith_utils/models/user/user_login.dart';
import 'package:wordsmith_utils/providers/auth_provider.dart';
import 'package:wordsmith_utils/providers/user_login_provider.dart';
import 'package:wordsmith_utils/providers/user_provider.dart';
import 'package:wordsmith_utils/size_config.dart';
import 'package:wordsmith_utils/validators.dart';

class RegistrationScreenWidget extends StatefulWidget {
  const RegistrationScreenWidget({super.key});

  @override
  State<StatefulWidget> createState() => _RegistrationScreenWidgetState();
}

class _RegistrationScreenWidgetState extends State<RegistrationScreenWidget> {
  final _logger = LogManager.getLogger("RegistrationScreen");
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: "");
  final _emailController = TextEditingController(text: "");
  final _passwordController = TextEditingController(text: "");
  final _confirmPasswordController = TextEditingController(text: "");

  late UserProvider _userProvider;
  late UserLoginProvider _userLoginProvider;
  late AuthProvider _authProvider;
  late UserIndexProvider _userIndexProvider;

  bool _obscuredPassword = true;
  bool _registrationInProgress = false;

  String? _validatePasswordConfirmation(String? value) {
    if (value == null || value.isEmpty) {
      return "Please confirm your password";
    }

    if (value != _passwordController.text) {
      return "Passwords do not match";
    }

    return null;
  }

  Future<void> _submitRegistration() async {
    ProgressIndicatorDialog()
        .show(context, text: "Registration in progress...");

    var userInsert = UserInsert(
      _usernameController.text,
      _emailController.text,
      _passwordController.text,
      _confirmPasswordController.text,
      null,
    );

    _logger.info("Attempting registration for ${_usernameController.text}");
    User? registerResult;

    await _userProvider.postNewUser(userInsert).then((result) {
      switch (result) {
        case Success<User>(data: final d):
          registerResult = d;
        case Failure<User>(exception: final e):
          showErrorDialog(context: context, content: Text(e.toString()));
      }
    });

    if (registerResult != null) {
      await Future.delayed(const Duration(milliseconds: 500), () async {
        await _userLoginProvider
            .getUserLogin(registerResult!.username, userInsert.password)
            .then((result) async {
          switch (result) {
            case Success<UserLogin>(data: final d):
              await _userIndexProvider
                  .addToIndex(d.user)
                  .then((indexResult) async {
                ProgressIndicatorDialog().dismiss();
                switch (indexResult) {
                  case Success():
                    Navigator.of(context).pop();
                    await _authProvider.storeLogin(loginCreds: d);
                  case Failure():
                    showErrorDialog(
                      context: context,
                      content:
                          const Text("Failed to login due to internal error!"),
                    );
                }
              });
            case Failure<UserLogin>(exception: final e):
              ProgressIndicatorDialog().dismiss();
              showErrorDialog(context: context, content: Text(e.toString()));
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    _userProvider = Provider.of<UserProvider>(context);
    _userLoginProvider = Provider.of<UserLoginProvider>(context);
    _authProvider = Provider.of<AuthProvider>(context);
    _userIndexProvider = Provider.of<UserIndexProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: SizeConfig.safeBlockVertical * 14.0, horizontal: 16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Register an account",
                  style: theme.textTheme.headlineSmall,
                ),
                SizedBox(
                  height: SizeConfig.safeBlockVertical * 6.0,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      InputField(
                        labelText: "Username",
                        controller: _usernameController,
                        obscureText: false,
                        validator: validateUsername,
                      ),
                      SizedBox(
                        height: SizeConfig.safeBlockHorizontal * 5.0,
                      ),
                      InputField(
                        labelText: "Email",
                        controller: _emailController,
                        obscureText: false,
                        validator: validateEmail,
                      ),
                      SizedBox(
                        height: SizeConfig.safeBlockHorizontal * 5.0,
                      ),
                      InputField(
                        labelText: "Password",
                        controller: _passwordController,
                        obscureText: _obscuredPassword,
                        maxLines: 1,
                        validator: validatePassword,
                        suffixIcon: IconButton(
                          onPressed: () {
                            if (_registrationInProgress) {
                              return;
                            }

                            setState(() {
                              _obscuredPassword = !_obscuredPassword;
                            });
                          },
                          icon: Icon(_obscuredPassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.safeBlockHorizontal * 5.0,
                      ),
                      InputField(
                        labelText: "Confirm password",
                        controller: _confirmPasswordController,
                        obscureText: true,
                        maxLines: 1,
                        validator: _validatePasswordConfirmation,
                      ),
                      SizedBox(
                        height: SizeConfig.safeBlockHorizontal * 5.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: SizeConfig.safeBlockHorizontal * 40.0,
                            height: SizeConfig.safeBlockVertical * 6.0,
                            child: FilledButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  await _submitRegistration();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Please fill all the inputs!")),
                                  );
                                }
                              },
                              child: !_registrationInProgress
                                  ? const Text("Register")
                                  : const SizedBox(
                                      width: 20.0,
                                      height: 20.0,
                                      child: CircularProgressIndicator(),
                                    ),
                            ),
                          ),
                          SizedBox(
                            width: SizeConfig.safeBlockHorizontal * 6.0,
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Back"),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
