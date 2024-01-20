import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:provider/provider.dart";
import "package:wordsmith_admin_panel/screens/login_screen.dart";
import "package:wordsmith_admin_panel/screens/profile_screen.dart";
import "package:wordsmith_admin_panel/screens/reports_screen.dart";
import "package:wordsmith_admin_panel/widgets/dashboard_error.dart";
import "package:wordsmith_admin_panel/widgets/dashboard_loading.dart";
import "package:wordsmith_admin_panel/widgets/dashboard_trailing.dart";
import "package:wordsmith_utils/exceptions/base_exception.dart";
import "package:wordsmith_utils/logger.dart";
import "package:wordsmith_utils/providers/auth_provider.dart";
import "package:wordsmith_utils/providers/user_provider.dart";

class DashboardWidget extends StatefulWidget {
  final Widget? title;

  const DashboardWidget({required this.title, super.key});

  @override
  State<StatefulWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  final Logger _logger = LogManager.getLogger("Dashboard");
  int _selectedIndex = 0;
  late Widget _page;
  final bool _extended = false;
  final NavigationRailLabelType _labelType = NavigationRailLabelType.selected;

  late Future<dynamic> _checkLoggedUserFuture;
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

  Future<dynamic> _checkLoggedUser() async {
    try {
      var loggedUser = await _userProvider.getLoggedUser();
      await _authProvider.storeLogin(user: loggedUser);
    } on BaseException catch (error) {
      _logger.info(error);
    } on Exception catch (error) {
      _logger.severe(error);
      return Future.error(error);
    }
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
