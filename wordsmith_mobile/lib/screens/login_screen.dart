import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/widgets/input_field.dart';
import 'package:wordsmith_utils/dialogs.dart';
import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/user_login.dart';
import 'package:wordsmith_utils/providers/user_login_provider.dart';
import 'package:wordsmith_utils/size_config.dart';
import 'package:wordsmith_utils/validators.dart';

class LoginScreenWidget extends StatefulWidget {
  const LoginScreenWidget({super.key});

  @override
  State<StatefulWidget> createState() => LoginScreenWidgetState();
}

class LoginScreenWidgetState extends State<LoginScreenWidget> {
  final _logger = LogManager.getLogger("LoginScreen");
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: "");
  final _passwordController = TextEditingController(text: "");

  late UserLoginProvider _userLoginProvider;

  bool _obscuredPassword = true;
  bool _loginInProgress = false;

  void _toggleLoginInProgress() {
    setState(() {
      _loginInProgress = !_loginInProgress;
    });
  }

  Future<UserLogin?> _submitLogin() async {
    _toggleLoginInProgress();

    var username = _usernameController.text;
    var password = _passwordController.text;

    _logger.info("Attempting login with $username:$password");

    try {
      var result = await _userLoginProvider.getUserLogin(username, password);

      if (result == null) {
        throw BaseException("Could not login");
      }

      return result;
    } on BaseException catch (error) {
      _toggleLoginInProgress();

      if (context.mounted) {
        await showErrorDialog(
          context,
          const Text("Error"),
          Text(error.toString()),
        );
      }

      _logger.severe(error);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    _userLoginProvider = context.read<UserLoginProvider>();

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
                        if (_loginInProgress) {
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
                            if (_formKey.currentState!.validate() &&
                                !_loginInProgress) {
                              _logger.info("Login in progress...");

                              var loginCreds = await _submitLogin();

                              if (loginCreds != null) {
                                _logger.info(
                                    "Logged in with access token ${loginCreds.accessToken}");
                                _toggleLoginInProgress();

                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              }
                            }
                          },
                          child: !_loginInProgress
                              ? const Text("Login")
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
            ),
          ),
        ),
      ),
    );
  }
}