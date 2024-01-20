import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:provider/provider.dart";
import "package:wordsmith_utils/providers/auth_provider.dart";
import "package:wordsmith_utils/size_config.dart";
import "package:wordsmith_admin_panel/widgets/input_field.dart";
import "package:wordsmith_utils/dialogs.dart";
import "package:wordsmith_utils/exceptions/base_exception.dart";
import "package:wordsmith_utils/logger.dart";
import "package:wordsmith_utils/models/user_login.dart";
import "package:wordsmith_utils/providers/user_login_provider.dart";
import "package:wordsmith_utils/validators.dart";

class LoginScreenWidget extends StatefulWidget {
  const LoginScreenWidget({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreenWidgetState();
}

class _LoginScreenWidgetState extends State<LoginScreenWidget> {
  final Logger _logger = LogManager.getLogger("LoginScreen");
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController =
      TextEditingController(text: "");
  final TextEditingController _passwordController =
      TextEditingController(text: "");

  late UserLoginProvider _userLoginProvider;
  late AuthProvider _authProvider;

  bool _obscuredPassword = true;
  bool _loginInProgress = false;

  void _togglePasswordVisibility() {
    setState(() {
      _obscuredPassword = !_obscuredPassword;
    });
  }

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
    _authProvider = context.read<AuthProvider>();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Login to your admin account",
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 20.0),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    InputField(
                      labelText: "Username",
                      controller: _usernameController,
                      validator: validateRequired,
                    ),
                    SizedBox(height: SizeConfig.safeBlockVertical * 0.9),
                    InputField(
                      labelText: "Password",
                      controller: _passwordController,
                      obscureText: _obscuredPassword,
                      suffixIcon: IconButton(
                        onPressed: () => _togglePasswordVisibility(),
                        icon: Icon(
                          _obscuredPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                      validator: validateRequired,
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 100.0,
                          height: 30.0,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate() &&
                                  !_loginInProgress) {
                                var loginCreds = await _submitLogin();

                                if (loginCreds != null) {
                                  _logger.info(
                                      "Logged in with access token ${loginCreds.accessToken}");

                                  _toggleLoginInProgress();

                                  await _authProvider.storeLogin(
                                      loginCreds: loginCreds);
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Please fill all the inputs!")),
                                );
                              }
                            },
                            child: !_loginInProgress
                                ? const Text("Submit")
                                : const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(),
                                  ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
