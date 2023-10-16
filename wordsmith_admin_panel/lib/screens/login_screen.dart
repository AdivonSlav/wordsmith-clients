import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:wordsmith_admin_panel/utils/dialogs.dart";
import "package:wordsmith_admin_panel/widgets/input_field.dart";
import "package:wordsmith_utils/exceptions/base_exception.dart";
import "package:wordsmith_utils/models/user_login.dart";
import "package:wordsmith_utils/providers/user_login_provider.dart";
import "package:wordsmith_utils/validators.dart";

class LoginScreenWidget extends StatefulWidget {
  const LoginScreenWidget({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreenWidgetState();
}

class _LoginScreenWidgetState extends State<LoginScreenWidget> {
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

    print("Attempting login with $username:$password");

    Map<String, String> request = {
      "username": username,
      "password": password,
    };

    try {
      var result = await _userLoginProvider.get(filter: request);
      var loginCreds = result?.result[0];

      if (loginCreds == null ||
          loginCreds.accessToken == null ||
          loginCreds.refreshToken == null) {
        throw BaseException("Could not login");
      }

      return loginCreds;
    } on BaseException catch (error) {
      _toggleLoginInProgress();

      if (context.mounted) {
        showErrorDialog(
          context,
          const Text("Error"),
          Text(error.toString()),
        );
      }

      print(error);
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
        showErrorDialog(
          context,
          const Text("Error"),
          const Text("Something unexpected happened"),
        );
      }

      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    _userLoginProvider = context.read<UserLoginProvider>();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
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
                    const SizedBox(height: 8.0),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 8.0),
                      child: SizedBox(
                        width: 100,
                        height: 35,
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
