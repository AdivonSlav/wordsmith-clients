import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:wordsmith_admin_panel/screens/login_screen.dart";
import "package:wordsmith_admin_panel/widgets/dashboard_trailing.dart";
import "package:wordsmith_utils/exceptions/base_exception.dart";
import "package:wordsmith_utils/providers/user_login_provider.dart";
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
  late UserProvider _userProvider;
  late UserLoginProvider _userLoginProvider;

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

  Future<dynamic> _checkLogin() async {
    try {
      var loggedUser = await _userProvider.getLoggedUser();

      if (loggedUser == null) return;

      await _userLoginProvider.storeLogin(user: loggedUser);
    } on BaseException catch (error) {
      print(error);
    } on Exception catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    _userProvider = context.read<UserProvider>();
    _userLoginProvider = context.read<UserLoginProvider>();

    return FutureBuilder<dynamic>(
        future: _checkLogin(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          return LayoutBuilder(builder: (context, constraints) {
            switch (_selectedIndex) {
              case 0:
                _page = const LoginScreenWidget();
                break;
              case 1:
                _page = const Placeholder();
                break;
              case 2:
                _page = const Placeholder();
                break;
              default:
                throw UnimplementedError("No widget for $_selectedIndex");
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
                        if (index > 0 && UserLoginProvider.loggedUser == null) {
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
  }
}
