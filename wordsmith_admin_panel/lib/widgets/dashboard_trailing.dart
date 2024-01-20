import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:wordsmith_utils/popup_menu.dart";
import "package:wordsmith_utils/providers/auth_provider.dart";
import "package:wordsmith_utils/providers/user_login_provider.dart";

class DashboardTrailingWidget extends StatefulWidget {
  const DashboardTrailingWidget({super.key});

  @override
  State<StatefulWidget> createState() => _DashboardTrailingState();
}

class _DashboardTrailingState extends State<DashboardTrailingWidget> {
  late AuthProvider _authProvider;

  @override
  Widget build(BuildContext context) {
    _authProvider = context.read<AuthProvider>();

    return Consumer<UserLoginProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 32.0),
          child: AuthProvider.loggedUser != null
              ? Row(
                  children: <Widget>[
                    Text(AuthProvider.loggedUser?.username ?? ""),
                    const SizedBox(
                      width: 8.0,
                    ),
                    IconButton(
                      onPressed: () {
                        showPopupMenu(context, [
                          PopupMenuItem(
                            value: "logout",
                            child: const Text("Logout"),
                            onTap: () {
                              _authProvider.eraseLogin();
                            },
                          )
                        ]);
                      },
                      icon: const Icon(Icons.person),
                      padding: const EdgeInsets.all(0.0),
                    )
                  ],
                )
              : null,
        );
      },
    );
  }
}
