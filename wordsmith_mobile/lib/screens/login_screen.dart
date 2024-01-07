import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/widgets/input_field.dart';
import 'package:wordsmith_utils/logger.dart';
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
  bool _obscuredPassword = true;
  bool _loginInProgress = false;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Form(
          key: _formKey,
          child: Column(
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
              SizedBox(
                width: SizeConfig.safeBlockHorizontal * 40.0,
                height: SizeConfig.safeBlockVertical * 6.0,
                child: ElevatedButton(
                  onPressed: () {
                    _loginInProgress = true;
                    _logger.info("Login in progress...");
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
            ],
          ),
        ),
      ),
    );
  }
}
