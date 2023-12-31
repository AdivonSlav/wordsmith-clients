import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/widgets/input_field.dart';
import 'package:wordsmith_utils/dialogs.dart';
import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/models/user_insert.dart';
import 'package:wordsmith_utils/models/user_login.dart';
import 'package:wordsmith_utils/providers/user_login_provider.dart';
import 'package:wordsmith_utils/providers/user_provider.dart';
import 'package:wordsmith_utils/size_config.dart';
import 'package:wordsmith_utils/validators.dart';

class RegistrationScreenWidget extends StatefulWidget {
  const RegistrationScreenWidget({super.key});

  @override
  State<StatefulWidget> createState() => RegistrationScreenWidgetState();
}

class RegistrationScreenWidgetState extends State<RegistrationScreenWidget> {
  final _logger = LogManager.getLogger("RegistrationScreen");
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: "");
  final _emailController = TextEditingController(text: "");
  final _passwordController = TextEditingController(text: "");
  final _confirmPasswordController = TextEditingController(text: "");

  late UserProvider _userProvider;
  late UserLoginProvider _userLoginProvider;

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

  void _toggleRegistrationInProgress() {
    setState(() {
      _registrationInProgress = !_registrationInProgress;
    });
  }

  Future<UserLogin?> _submitRegistration() async {
    _toggleRegistrationInProgress();
    _logger.info("Attempting registration for ${_usernameController.text}");

    try {
      var userInsert = UserInsert(
          _usernameController.text,
          _emailController.text,
          _passwordController.text,
          _confirmPasswordController.text,
          null);

      var registerResult = await _userProvider.postNewUser(userInsert);

      // Small delay to allow synchronization with the backend identity server
      UserLogin? loginResult = await Future.delayed(
        const Duration(milliseconds: 500),
        () async {
          return await _userLoginProvider.getUserLogin(
            registerResult.username,
            userInsert.password,
          );
        },
      );

      if (loginResult == null) {
        throw BaseException("Could not login");
      }

      return loginResult;
    } on BaseException catch (error) {
      _toggleRegistrationInProgress();

      if (context.mounted) {
        await showErrorDialog(
          context,
          const Text("Error"),
          Text(
            error.toString(),
          ),
        );
      }

      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    _userProvider = context.read<UserProvider>();
    _userLoginProvider = context.read<UserLoginProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(children: [
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
                  validator: _validatePasswordConfirmation,
                ),
                SizedBox(
                  height: SizeConfig.safeBlockHorizontal * 5.0,
                ),
                SizedBox(
                  width: SizeConfig.safeBlockHorizontal * 40.0,
                  height: SizeConfig.safeBlockVertical * 6.0,
                  child: ElevatedButton(
                    onPressed: () async {
                      _logger.info("Registration in progress...");

                      if (_formKey.currentState!.validate() &&
                          !_registrationInProgress) {
                        var loginCreds = await _submitRegistration();

                        if (loginCreds != null) {
                          _logger.info(
                              "Registered and logged in with ${loginCreds.accessToken}");
                          _toggleRegistrationInProgress();
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Please fill all the inputs!")),
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
              ],
            ),
          )
        ]),
      ),
    );
  }
}
