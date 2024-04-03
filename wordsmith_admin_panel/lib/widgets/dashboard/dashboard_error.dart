import "package:flutter/material.dart";

class DashboardErrorWidget extends StatelessWidget {
  final Widget? title;

  const DashboardErrorWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: title),
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              "An error has occured. This most probably indicates a server-side issue. Restart the app to retry.",
            ),
          )
        ],
      ),
    );
  }
}
