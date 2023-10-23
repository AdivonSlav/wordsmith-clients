import "package:flutter/material.dart";

class DashboardLoadingWidget extends StatelessWidget {
  final Widget? title;

  const DashboardLoadingWidget({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: title),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              width: 128,
              height: 128,
              child: CircularProgressIndicator(
                strokeWidth: 8.0,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              "Loading...",
              style: theme.textTheme.headlineMedium,
            )
          ],
        ),
      ),
    );
  }
}
