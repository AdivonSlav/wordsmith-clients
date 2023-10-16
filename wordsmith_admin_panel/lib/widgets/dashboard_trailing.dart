import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:wordsmith_admin_panel/utils/popup_menu.dart";
import "package:wordsmith_utils/providers/user_login_provider.dart";

class DashboardTrailingWidget extends StatefulWidget {
  const DashboardTrailingWidget({super.key});

  @override
  State<StatefulWidget> createState() => _DashboardTrailingState();
}

class _DashboardTrailingState extends State<DashboardTrailingWidget> {
  late UserLoginProvider _userLoginProvider;

  @override
  Widget build(BuildContext context) {
    _userLoginProvider = context.read<UserLoginProvider>();

    return Consumer<UserLoginProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 32.0),
          child: UserLoginProvider.loggedUser != null
              ? Row(
                  children: <Widget>[
                    Text(UserLoginProvider.loggedUser?.username ?? ""),
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
                              _userLoginProvider.eraseLogin();
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
