import 'package:flutter/material.dart';
import 'package:wordsmith_utils/size_config.dart';

class NavigationBarLoadingWidget extends StatelessWidget {
  final Widget? title;

  const NavigationBarLoadingWidget({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: title),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: SizeConfig.safeBlockHorizontal * 30.0,
              height: SizeConfig.safeBlockVertical * 15.0,
              child: CircularProgressIndicator(
                strokeWidth: SizeConfig.safeBlockHorizontal * 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
