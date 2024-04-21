import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/screens/ebook_browse_screen.dart';
import 'package:wordsmith_mobile/screens/home_screen.dart';
import 'package:wordsmith_mobile/screens/intro_screen.dart';
import 'package:wordsmith_mobile/screens/library_screen.dart';
import 'package:wordsmith_mobile/screens/personal_profile_screen.dart';
import 'package:wordsmith_mobile/utils/indexers/models/user_index_model.dart';
import 'package:wordsmith_mobile/utils/indexers/user_index_provider.dart';
import 'package:wordsmith_mobile/widgets/navigation_bar/app_bar_settings_trailing.dart';
import 'package:wordsmith_mobile/widgets/navigation_bar/navigation_bar_error.dart';
import 'package:wordsmith_mobile/widgets/navigation_bar/navigation_bar_loading.dart';
import 'package:wordsmith_mobile/widgets/navigation_bar/navigation_bar_publish.dart';
import 'package:wordsmith_utils/exceptions/exception_types.dart';
import 'package:wordsmith_utils/models/result.dart';
import 'package:wordsmith_utils/models/user/user.dart';
import 'package:wordsmith_utils/providers/auth_provider.dart';
import 'package:wordsmith_utils/providers/user_provider.dart';

class NavigationBarWidget extends StatefulWidget {
  const NavigationBarWidget({super.key});

  @override
  State<StatefulWidget> createState() => _NavigationBarWidgetState();
}

class _NavigationBarWidgetState extends State<NavigationBarWidget> {
  late Future<void> _checkLoggedUserFuture;
  late UserProvider _userProvider;
  late AuthProvider _authProvider;
  late UserIndexProvider _userIndexProvider;

  int _selectedIndex = 0;
  late Widget _page;

  List<NavigationDestination> _loadNavDestinations() {
    return <NavigationDestination>[
      const NavigationDestination(icon: Icon(Icons.home), label: "Home"),
      const NavigationDestination(
          icon: Icon(Icons.library_books), label: "Library"),
      const NavigationDestination(icon: Icon(Icons.search), label: "Browse"),
      const NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
    ];
  }

  String _loadAppBarTitle(int index) {
    switch (index) {
      case 0:
        return "Home";
      case 1:
        return "Library";
      case 2:
        return "Browse";
      case 3:
        return "Profile";
      default:
        return "";
    }
  }

  Future<void> _storeUserFromIndex() async {
    await _userIndexProvider.getUser().then((result) async {
      switch (result) {
        case Success<UserIndexModel?>(data: final d):
          if (d != null) {
            var user = d.toUser();

            await _authProvider.storeLogin(user: user);
          }
          break;
        case Failure(exception: final e):
          return Future.error(e);
      }
    });
  }

  Future<void> _checkLoggedUser() async {
    await _userProvider.getLoggedUser().then((result) async {
      switch (result) {
        case Success<User>(data: final d):
          await _userIndexProvider.addToIndex(d).then((indexResult) async {
            switch (indexResult) {
              case Success<UserIndexModel>():
                await _authProvider.storeLogin(user: d);
              case Failure<UserIndexModel>(exception: final e):
                return Future.error(e);
            }
          });
        case Failure<User>(exception: final e):
          if (e.type == ExceptionType.internalAppError) {
            return Future.error(e);
          }
          if (e.type == ExceptionType.unauthorizedException) {
            await _authProvider.eraseLogin();
            return;
          }

          return await _storeUserFromIndex();
      }
    });
  }

  @override
  void initState() {
    _userProvider = context.read<UserProvider>();
    _authProvider = context.read<AuthProvider>();
    _userIndexProvider = context.read<UserIndexProvider>();

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
                  _page = const HomeScreenWidget();
                  break;
                case 1:
                  _page = const LibraryScreenWidget();
                  break;
                case 2:
                  _page = const EbookBrowseScreenWidget();
                  break;
                case 3:
                  _page = const PersonalProfileScreenWidget();
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
                      actions: _page is PersonalProfileScreenWidget
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
