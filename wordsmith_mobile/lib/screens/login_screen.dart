import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/utils/indexers/models/user_index_model.dart';
import 'package:wordsmith_mobile/utils/indexers/user_index_provider.dart';
import 'package:wordsmith_mobile/widgets/input_field.dart';
import 'package:wordsmith_utils/dialogs/progress_indicator_dialog.dart';
import 'package:wordsmith_utils/dialogs/show_error_dialog.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/user/user_login.dart';
import 'package:wordsmith_utils/providers/auth_provider.dart';
import 'package:wordsmith_utils/providers/user_login_provider.dart';
import 'package:wordsmith_utils/size_config.dart';
import 'package:wordsmith_utils/validators.dart';

class LoginScreenWidget extends StatefulWidget {
  const LoginScreenWidget({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreenWidgetState();
}

class _LoginScreenWidgetState extends State<LoginScreenWidget> {
  final _logger = LogManager.getLogger("LoginScreen");
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: "");
  final _passwordController = TextEditingController(text: "");

  late UserLoginProvider _userLoginProvider;
  late AuthProvider _authProvider;
  late UserIndexProvider _userIndexProvider;

  bool _obscuredPassword = true;

  Future<void> _submitLogin() async {
    ProgressIndicatorDialog().show(context, text: "Logging in...");

    var username = _usernameController.text;
    var password = _passwordController.text;

    _logger.info("Attempting login with $username:$password");

    await _userLoginProvider
        .getUserLogin(username, password)
        .then((result) async {
      switch (result) {
        case Success<UserLogin>(data: final d):
          await _userIndexProvider.addToIndex(d.user).then((indexResult) async {
            ProgressIndicatorDialog().dismiss();
            switch (indexResult) {
              case Success<UserIndexModel>():
                Navigator.of(context).pop();
                await _authProvider.storeLogin(loginCreds: d);
              case Failure<UserIndexModel>():
                showErrorDialog(
                    context: context,
                    content:
                        const Text("Failed to login due to internal error!"));
            }
          });
        case Failure<UserLogin>(exception: final e):
          ProgressIndicatorDialog().dismiss();
          showErrorDialog(context: context, content: Text(e.toString()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _userLoginProvider = context.read<UserLoginProvider>();
    _authProvider = context.read<AuthProvider>();
    _userIndexProvider = context.read<UserIndexProvider>();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: SizeConfig.safeBlockVertical * 14.0, horizontal: 16.0),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Login to your account",
                    style: theme.textTheme.headlineSmall,
                  ),
                  SizedBox(
                    height: SizeConfig.safeBlockVertical * 6.0,
                  ),
                  InputField(
                    labelText: "Username",
                    controller: _usernameController,
                    obscureText: false,
                    validator: validateRequired,
                  ),
                  SizedBox(
                    height: SizeConfig.safeBlockVertical * 5.0,
                  ),
                  InputField(
                    labelText: "Password",
                    controller: _passwordController,
                    obscureText: _obscuredPassword,
                    maxLines: 1,
                    validator: validateRequired,
                    suffixIcon: IconButton(
                      onPressed: () {
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
                    height: SizeConfig.safeBlockVertical * 5.0,
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
                                _logger.info("Login in progress...");

                                await _submitLogin();
                              }
                            },
                            child: const Text("Login")),
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
            ),
          ),
        ),
      ),
    );
  }
}
