import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:wordsmith_admin_panel/screens/login_screen.dart";
import "package:wordsmith_admin_panel/screens/profile_screen.dart";
import "package:wordsmith_admin_panel/screens/reports_screen.dart";
import "package:wordsmith_admin_panel/widgets/dashboard_error.dart";
import "package:wordsmith_admin_panel/widgets/dashboard_loading.dart";
import "package:wordsmith_admin_panel/widgets/dashboard_trailing.dart";
import "package:wordsmith_utils/exceptions/exception_types.dart";
import "package:wordsmith_utils/models/result.dart";
import "package:wordsmith_utils/models/user/user.dart";
import "package:wordsmith_utils/providers/auth_provider.dart";
import "package:wordsmith_utils/providers/user_provider.dart";

class DashboardWidget extends StatefulWidget {
  final Widget? title;

  const DashboardWidget({required this.title, super.key});

  @override
  State<StatefulWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  int _selectedIndex = 0;
  late Widget _page;
  final bool _extended = false;
  final NavigationRailLabelType _labelType = NavigationRailLabelType.selected;

  late Future<void> _checkLoggedUserFuture;
  late UserProvider _userProvider;
  late AuthProvider _authProvider;

  List<NavigationRailDestination> _loadNavDestinations() {
    return <NavigationRailDestination>[
      const NavigationRailDestination(
          icon: Icon(Icons.person), label: Text("Profile")),
      const NavigationRailDestination(
          icon: Icon(Icons.report), label: Text("Reports")),
      const NavigationRailDestination(
          icon: Icon(Icons.book_online), label: Text("eBooks"))
    ];
  }

  Future<void> _checkLoggedUser() async {
    await _userProvider.getLoggedUser().then((result) async {
      switch (result) {
        case Success<User>(data: final d):
          await _authProvider.storeLogin(user: d);
        case Failure<User>(exception: final e):
          if (e.type == ExceptionType.internalAppError) {
            return Future.error(e);
          }
      }
    });
  }

  @override
  void initState() {
    _userProvider = context.read<UserProvider>();
    _authProvider = context.read<AuthProvider>();

    _checkLoggedUserFuture = _checkLoggedUser();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: _checkLoggedUserFuture,
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return DashboardLoadingWidget(title: widget.title);
          }

          if (snapshot.hasError) {
            return DashboardErrorWidget(title: widget.title);
          }

          return Consumer<AuthProvider>(builder: (context, provider, child) {
            return LayoutBuilder(builder: (context, constraints) {
              if (AuthProvider.loggedUser != null) {
                switch (_selectedIndex) {
                  case 0:
                    _page = ProfileScreenWidget();
                    break;
                  case 1:
                    _page = ReportsScreenWidget();
                    break;
                  case 2:
                    _page = const Placeholder();
                    break;
                  default:
                    throw UnimplementedError("No widget for $_selectedIndex");
                }
              } else {
                _selectedIndex = 0;
                _page = const LoginScreenWidget();
              }

              return Scaffold(
                appBar: AppBar(
                  title: widget.title,
                  actions: const <Widget>[
                    DashboardTrailingWidget(),
                  ],
                ),
                body: Row(
                  children: <Widget>[
                    SafeArea(
                      child: NavigationRail(
                        selectedIndex: _selectedIndex,
                        labelType: _labelType,
                        extended: _extended,
                        destinations: _loadNavDestinations(),
                        onDestinationSelected: (index) {
                          // Only allow navigation to index 0 if the user isn't logged in
                          if (index > 0 && AuthProvider.loggedUser == null) {
                            return;
                          }
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                      ),
                    ),
                    const VerticalDivider(),
                    Expanded(child: _page),
                  ],
                ),
              );
            });
          });
        });
  }
}
