import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/screens/registration_screen.dart';
import 'package:wordsmith_utils/logger.dart';

class NavigationBarWidget extends StatefulWidget {
  final Widget? title;

  const NavigationBarWidget({super.key, this.title});

  @override
  State<StatefulWidget> createState() => NavigationBarWidgetState();
}

class NavigationBarWidgetState extends State<NavigationBarWidget> {
  final _logger = LogManager.getLogger("NavigationBar");
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

  @override
  Widget build(BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        _page = const Placeholder();
        break;
      case 1:
        _page = const RegistrationScreenWidget();
        break;
      default:
        throw UnimplementedError("No widget for $_selectedIndex");
    }

    return Scaffold(
      appBar: AppBar(
        title: widget.title,
      ),
      bottomNavigationBar: NavigationBar(
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
    );
  }
}
