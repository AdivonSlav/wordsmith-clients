import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/screens/intro_screen.dart';
import 'package:wordsmith_mobile/screens/profile_screen.dart';
import 'package:wordsmith_mobile/widgets/app_bar_settings_trailing.dart';
import 'package:wordsmith_mobile/widgets/navigation_bar_error.dart';
import 'package:wordsmith_mobile/widgets/navigation_bar_loading.dart';
import 'package:wordsmith_mobile/widgets/navigation_bar_publish.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/providers/user_login_provider.dart';

class NavigationBarWidget extends StatefulWidget {
  const NavigationBarWidget({super.key});

  @override
  State<StatefulWidget> createState() => NavigationBarWidgetState();
}

class NavigationBarWidgetState extends State<NavigationBarWidget> {
  final _logger = LogManager.getLogger("NavigationBar");

  late Future<dynamic> _checkLogin;
  late UserLoginProvider _userLoginProvider;

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

  @override
  void initState() {
    _userLoginProvider = context.read<UserLoginProvider>();
    _checkLogin = _userLoginProvider.validateUserLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkLogin,
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        final String appBarTitle = _loadAppBarTitle(_selectedIndex);

        if (snapshot.connectionState != ConnectionState.done) {
          return NavigationBarLoadingWidget(title: Text(appBarTitle));
        }

        if (snapshot.hasError) {
          return NavigationBarErrorWidget(title: Text(appBarTitle));
        }

        return Consumer<UserLoginProvider>(
          builder: (context, provider, child) {
            if (UserLoginProvider.loggedUser != null) {
              switch (_selectedIndex) {
                case 0:
                  _page = const Placeholder();
                  break;
                case 1:
                  _page =
                      ProfileScreenWidget(user: UserLoginProvider.loggedUser!);
                  break;
                default:
                  throw UnimplementedError("No widget for $_selectedIndex");
              }
            } else {
              _selectedIndex = 0;
              _page = const IntroScreenWidget();
            }

            return Scaffold(
              appBar: UserLoginProvider.loggedUser == null
                  ? null
                  : AppBar(
                      title: Text(appBarTitle),
                      actions: _page is ProfileScreenWidget
                          ? [const AppBarSettingsTrailingWidget()]
                          : null,
                    ),
              bottomNavigationBar: UserLoginProvider.loggedUser == null
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
              floatingActionButton: UserLoginProvider.loggedUser == null
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
