import 'package:flutter/material.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class ProgressIndicatorDialog {
  static final ProgressIndicatorDialog _singleton =
      ProgressIndicatorDialog._internal();

  bool isDisplayed = false;

  factory ProgressIndicatorDialog() {
    return _singleton;
  }

  ProgressIndicatorDialog._internal();

  show(BuildContext context, {String text = "Loading..."}) {
    if (isDisplayed == true) {
      return;
    }

    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: SimpleDialog(
            children: <Widget>[
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Padding(
                      padding:
                          EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
                      child: CircularProgressIndicator(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(text),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );

    isDisplayed = true;
  }

  dismiss() {
    if (isDisplayed == true) {
      Navigator.of(navigatorKey.currentContext!).pop();
      isDisplayed = false;
    }
  }
}
