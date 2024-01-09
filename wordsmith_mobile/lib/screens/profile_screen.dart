import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_utils/providers/user_login_provider.dart';

class ProfileScreenWidget extends StatefulWidget {
  const ProfileScreenWidget({super.key});

  @override
  State<StatefulWidget> createState() => ProfileScreenWidgetState();
}

class ProfileScreenWidgetState extends State<ProfileScreenWidget> {
  late UserLoginProvider _userLoginProvider;
  @override
  Widget build(BuildContext context) {
    _userLoginProvider = context.read<UserLoginProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () async {
              _userLoginProvider.eraseLogin();
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
