import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/screens/login_screen.dart';
import 'package:wordsmith_mobile/screens/registration_screen.dart';

class IntroScreenWidget extends StatefulWidget {
  const IntroScreenWidget({super.key});

  @override
  State<StatefulWidget> createState() => _IntroScreenWidgetState();
}

class _IntroScreenWidgetState extends State<IntroScreenWidget> {
  Widget _buildLogo() {
    var adaptiveTheme = AdaptiveTheme.of(context);
    var logo = adaptiveTheme.brightness == Brightness.dark
        ? const AssetImage("assets/images/logo_white.png")
        : const AssetImage("assets/images/logo_black.png");

    return Container(
      width: 128,
      height: 128,
      decoration: BoxDecoration(
        image: DecorationImage(image: logo),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: <Widget>[
        Builder(builder: (context) => _buildLogo()),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: Text(
            "Welcome to Wordsmith!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24.0,
            ),
          ),
        ),
        const Text(
          "To start, either login or create a new account",
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionBody() {
    var size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreenWidget(),
                  ),
                );
              },
              child: const Text("Login")),
          Divider(indent: size.width / 5.0, endIndent: size.width / 5.0),
          FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const RegistrationScreenWidget(),
                  ),
                );
              },
              child: const Text("Create an account")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Builder(builder: (context) => _buildHeader()),
          Builder(builder: (context) => _buildActionBody()),
        ],
      ),
    );
  }
}
