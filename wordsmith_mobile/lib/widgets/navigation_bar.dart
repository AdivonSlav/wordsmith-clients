import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/screens/intro_screen.dart';
import 'package:wordsmith_mobile/screens/profile_screen.dart';
import 'package:wordsmith_mobile/widgets/app_bar_settings_trailing.dart';
import 'package:wordsmith_mobile/widgets/navigation_bar_error.dart';
import 'package:wordsmith_mobile/widgets/navigation_bar_loading.dart';
import 'package:wordsmith_mobile/widgets/navigation_bar_publish.dart';
import 'package:wordsmith_utils/exceptions/base_exception.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/providers/auth_provider.dart';
import 'package:wordsmith_utils/providers/user_provider.dart';

class NavigationBarWidget extends StatefulWidget {
  const NavigationBarWidget({super.key});

  @override
  State<StatefulWidget> createState() => _NavigationBarWidgetState();
}

class _NavigationBarWidgetState extends State<NavigationBarWidget> {
  final _logger = LogManager.getLogger("NavigationBar");

  late Future<dynamic> _checkLoggedUserFuture;
  late UserProvider _userProvider;
  late AuthProvider _authProvider;

  int _selectedIndex = 0;
  late Widget _page;

  List<NavigationDestination> _loadNavDestinations() {
    return <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.wrong_location),
        label: "Placeholder",
      ),
      const NavigationDestination(
        icon: Icon(Icons.person),
        label: "Profile",
      ),
    ];
  }

  String _loadAppBarTitle(int index) {
    switch (index) {
      case 3:
        return "Profile";
      default:
        return "Wordsmith";
    }
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
    return FutureBuilder(
      future: _checkLoggedUserFuture,
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        final String appBarTitle = _loadAppBarTitle(_selectedIndex);

        if (snapshot.connectionState != ConnectionState.done) {
          return NavigationBarLoadingWidget(title: Text(appBarTitle));
        }

        if (snapshot.hasError) {
          return NavigationBarErrorWidget(title: Text(appBarTitle));
        }

        return Consumer<AuthProvider>(
          builder: (context, provider, child) {
            if (AuthProvider.loggedUser != null) {
              switch (_selectedIndex) {
                case 0:
                  _page = const Placeholder();
                  break;
                case 1:
                  _page = ProfileScreenWidget(user: AuthProvider.loggedUser!);
                  break;
                default:
                  throw UnimplementedError("No widget for $_selectedIndex");
              }
            } else {
              _selectedIndex = 0;
              _page = const IntroScreenWidget();
            }

            return Scaffold(
              appBar: AuthProvider.loggedUser == null
                  ? null
                  : AppBar(
                      title: Text(appBarTitle),
                      actions: _page is ProfileScreenWidget
                          ? [const AppBarSettingsTrailingWidget()]
                          : null,
                    ),
              bottomNavigationBar: AuthProvider.loggedUser == null
                  ? null
                  : NavigationBar(
                      onDestinationSelected: (int index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      selectedIndex: _selectedIndex,
                      destinations: _loadNavDestinations(),
                    ),
              body: Flex(
                direction: Axis.vertical,
                children: <Widget>[
                  Expanded(child: _page),
                ],
              ),
              floatingActionButton: AuthProvider.loggedUser == null
                  ? null
                  : const NavigationBarPublishWidget(),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
            );
          },
        );
      },
    );
  }
}
