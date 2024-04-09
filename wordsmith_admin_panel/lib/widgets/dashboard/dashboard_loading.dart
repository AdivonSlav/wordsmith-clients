import "package:flutter/material.dart";
import "package:wordsmith_utils/size_config.dart";

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
            SizedBox(
              width: SizeConfig.safeBlockHorizontal * 15.0,
              height: SizeConfig.safeBlockHorizontal * 15.0,
              child: CircularProgressIndicator(
                strokeWidth: SizeConfig.safeBlockHorizontal * 0.75,
              ),
            ),
            SizedBox(height: SizeConfig.safeBlockVertical * 2.0),
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
