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
  late Future<void> _checkLoggedUserFuture;
  late UserProvider _userProvider;
  late AuthProvider _authProvider;

  int _selectedIndex = 0;
  late Widget _page;
  final bool _extended = false;
  final NavigationRailLabelType _labelType = NavigationRailLabelType.selected;

  String _loadAppBarTitle(int index) {
    switch (index) {
      case 1:
        return "Profile";
      case 2:
        return "Reports";
      case 3:
        return "Ebooks";
      default:
        return "Wordsmith";
    }
  }

  List<NavigationRailDestination> _loadNavDestinations() {
    return <NavigationRailDestination>[
      const NavigationRailDestination(
          icon: Icon(Icons.person), label: Text("Profile")),
      const NavigationRailDestination(
          icon: Icon(Icons.report), label: Text("Reports")),
      const NavigationRailDestination(
          icon: Icon(Icons.book_online), label: Text("Ebooks"))
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

  PreferredSizeWidget? _buildAppBar() {
    final String appBarTitle = _loadAppBarTitle(_selectedIndex);

    return AuthProvider.loggedUser == null
        ? null
        : AppBar(
            title: Text(appBarTitle),
            actions: const <Widget>[
              DashboardTrailingWidget(),
            ],
          );
  }

  Widget _buildNavigationRail() {
    // Don't show the nav rail if the user isn't logged in
    if (AuthProvider.loggedUser == null) {
      return Container();
    }

    return SafeArea(
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
    );
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

        return Consumer<AuthProvider>(
          builder: (context, provider, child) {
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
                appBar: _buildAppBar(),
                body: Row(
                  children: <Widget>[
                    Builder(builder: (context) => _buildNavigationRail()),
                    const VerticalDivider(),
                    Expanded(child: _page),
                  ],
                ),
              );
            });
          },
        );
      },
    );
  }
}
