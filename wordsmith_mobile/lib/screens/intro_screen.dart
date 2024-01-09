import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/screens/login_screen.dart';
import 'package:wordsmith_mobile/screens/registration_screen.dart';
import 'package:wordsmith_utils/size_config.dart';

class IntroScreenWidget extends StatefulWidget {
  const IntroScreenWidget({super.key});

  @override
  State<StatefulWidget> createState() => IntroScreenWidgetState();
}

class IntroScreenWidgetState extends State<IntroScreenWidget> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Welcome to Wordsmith!",
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          SizedBox(
            height: SizeConfig.safeBlockVertical * 2.0,
          ),
          const Text(
            "To start, either login or create a new account",
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: SizeConfig.safeBlockVertical * 8.0,
          ),
          SizedBox(
            width: SizeConfig.safeBlockHorizontal * 45.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreenWidget(),
                        ),
                      );
                    },
                    child: const Text("Login")),
                const Divider(),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const RegistrationScreenWidget(),
                        ),
                      );
                    },
                    child: const Text("Create an account")),
              ],
            ),
          )
        ],
      ),
    );
  }
}
