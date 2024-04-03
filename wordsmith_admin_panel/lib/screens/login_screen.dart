import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:wordsmith_utils/dialogs/progress_indicator_dialog.dart";
import "package:wordsmith_utils/dialogs/show_error_dialog.dart";
import "package:wordsmith_utils/models/result.dart";
import "package:wordsmith_utils/providers/auth_provider.dart";
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
  final _logger = LogManager.getLogger("LoginScreen");
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: "");
  final _passwordController = TextEditingController(text: "");

  late UserLoginProvider _userLoginProvider;
  late AuthProvider _authProvider;

  bool _obscuredPassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscuredPassword = !_obscuredPassword;
    });
  }

  Future<void> _submitLogin() async {
    ProgressIndicatorDialog().show(context, text: "Logging in...");

    var username = _usernameController.text;
    var password = _passwordController.text;

    _logger.info("Attempting login with $username:$password");

    await _userLoginProvider
        .getUserLogin(username, password, "admin.client")
        .then((result) async {
      ProgressIndicatorDialog().dismiss();
      switch (result) {
        case Success(data: final d):
          _logger.info("Logged in with access token ${d.accessToken}");
          await _authProvider.storeLogin(loginCreds: d);
        case Failure(exception: final e):
          showErrorDialog(context: context, content: Text(e.toString()));
      }
    });
  }

  Widget _buildLoginForm() {
    return SizedBox(
      width: 400.0,
      height: 250.0,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InputField(
                          labelText: "Username",
                          controller: _usernameController,
                          validator: validateRequired,
                          width: constraints.maxWidth * 0.9,
                        ),
                        const SizedBox(height: 30.0),
                        InputField(
                          labelText: "Password",
                          controller: _passwordController,
                          obscureText: _obscuredPassword,
                          width: constraints.maxWidth * 0.9,
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
                      ],
                    ),
                    SizedBox(
                      width: 100.0,
                      height: 40.0,
                      child: FilledButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await _submitLogin();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Please fill all the inputs!")),
                            );
                          }
                        },
                        child: const Text("Login"),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _userLoginProvider = context.read<UserLoginProvider>();
    _authProvider = context.read<AuthProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "Login to your admin account",
              style: TextStyle(
                fontSize: 26.0,
              ),
            ),
            const SizedBox(height: 30.0),
            Builder(builder: (context) => _buildLoginForm()),
          ],
        ),
      ),
    );
  }
}
