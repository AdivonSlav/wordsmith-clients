import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:provider/provider.dart";
import "package:wordsmith_utils/dialogs/show_error_dialog.dart";
import "package:wordsmith_utils/models/result.dart";
import "package:wordsmith_utils/providers/auth_provider.dart";
import "package:wordsmith_utils/size_config.dart";
import "package:wordsmith_admin_panel/widgets/input_field.dart";
import "package:wordsmith_utils/logger.dart";
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

  Future<void> _submitLogin() async {
    _toggleLoginInProgress();

    var username = _usernameController.text;
    var password = _passwordController.text;

    _logger.info("Attempting login with $username:$password");

    await _userLoginProvider
        .getUserLogin(username, password)
        .then((result) async {
      switch (result) {
        case Success(data: final d):
          _logger.info("Logged in with access token ${d.accessToken}");
          await _authProvider.storeLogin(loginCreds: d);
        case Failure(exception: final e):
          showErrorDialog(context: context, content: Text(e.toString()));
      }
    });

    _toggleLoginInProgress();
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
                                await _submitLogin();
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
