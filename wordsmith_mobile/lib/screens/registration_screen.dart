import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/widgets/input_field.dart';
import 'package:wordsmith_utils/logger.dart';
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

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

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
                    onPressed: () {
                      _logger.info("Registration in progress...");
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
