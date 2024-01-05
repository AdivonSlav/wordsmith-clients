import 'package:flutter/material.dart';
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
        icon: Icon(Icons.person),
        label: "Profile",
      ),
      const NavigationDestination(
        icon: Icon(Icons.person),
        label: "Placeholder1",
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
        _page = const Placeholder();
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
      body: SafeArea(
        child: Expanded(
          child: _page,
        ),
      ),
    );
  }
}
