import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/screens/publish_screen.dart';

class NavigationBarPublishWidget extends StatelessWidget {
  const NavigationBarPublishWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const elevation = 3.0;

    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const PublishScreenWidget()),
        );
      },
      shape: const CircleBorder(),
      elevation: elevation,
      child: const Icon(Icons.add),
    );
  }
}
