import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:provider/provider.dart";
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

    Map<String, String> request = {
      "username": username,
      "password": password,
    };

    try {
      var result = await _userLoginProvider.get(filter: request);
      var loginCreds = result.result[0];

      if (loginCreds.accessToken == null || loginCreds.refreshToken == null) {
        throw BaseException("Could not login");
      }

      return loginCreds;
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

  Future _handleCredentials(UserLogin loginCreds) async {
    try {
      await _userLoginProvider.storeLogin(loginCreds: loginCreds);
      _toggleLoginInProgress();
    } catch (error) {
      _toggleLoginInProgress();

      if (context.mounted) {
        await showErrorDialog(
          context,
          const Text("Error"),
          const Text("Something unexpected happened"),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    _userLoginProvider = context.read<UserLoginProvider>();

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
              SizedBox(height: SizeConfig.safeBlockVertical * 2.0),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    InputField(
                      labelText: "Username",
                      controller: _usernameController,
                      validator: validateRequired,
                      width: SizeConfig.safeBlockHorizontal * 45.0,
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
                      width: SizeConfig.safeBlockHorizontal * 45.0,
                    ),
                    SizedBox(height: SizeConfig.safeBlockVertical * 2.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: SizeConfig.safeBlockHorizontal * 15.0,
                          height: SizeConfig.safeBlockVertical * 3.5,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate() &&
                                  !_loginInProgress) {
                                var loginCreds = await _submitLogin();

                                if (loginCreds != null) {
                                  await _handleCredentials(loginCreds);
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
                        SizedBox(width: SizeConfig.safeBlockHorizontal * 2.0),
                        SizedBox(
                          height: SizeConfig.safeBlockVertical * 3.5,
                          child: ElevatedButton(
                            onPressed: () async {
                              await showRegistrationDialog(context);
                            },
                            child: const Text("Don't have an account?"),
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

Future<dynamic> showRegistrationDialog(BuildContext context) async {
  final logger = LogManager.getLogger("RegistrationDialog");
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool registerInProgress = false;
  var theme = Theme.of(context);

  return await showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text("Register"),
      content: SingleChildScrollView(
        child: SizedBox(
          height: SizeConfig.safeBlockVertical * 35.0,
          width: SizeConfig.safeBlockHorizontal * 50.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    InputField(
                      labelText: "Username",
                      controller: usernameController,
                      validator: validateUsername,
                      width: SizeConfig.safeBlockHorizontal * 45.0,
                    ),
                    SizedBox(height: SizeConfig.safeBlockVertical * 0.9),
                    InputField(
                      labelText: "Email",
                      controller: emailController,
                      validator: validateEmail,
                      width: SizeConfig.safeBlockHorizontal * 45.0,
                    ),
                    SizedBox(height: SizeConfig.safeBlockVertical * 0.9),
                    InputField(
                      labelText: "Password",
                      controller: passwordController,
                      validator: validatePassword,
                      width: SizeConfig.safeBlockHorizontal * 45.0,
                    ),
                    SizedBox(height: SizeConfig.safeBlockVertical * 0.9),
                    InputField(
                      labelText: "Confirm password",
                      controller: confirmPasswordController,
                      validator: (value) {
                        return value == passwordController.text
                            ? null
                            : "The passwords do not match!";
                      },
                      width: SizeConfig.safeBlockHorizontal * 45.0,
                    ),
                    SizedBox(height: SizeConfig.safeBlockVertical * 2.0),
                    ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          registerInProgress = true;
                        }
                      },
                      child: !registerInProgress
                          ? const Text("Register")
                          : const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(),
                            ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"))
      ],
    ),
  );
}
