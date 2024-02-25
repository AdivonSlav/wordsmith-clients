import 'package:flutter/material.dart';

class ProgressIndicatorDialog {
  static final ProgressIndicatorDialog _singleton =
      ProgressIndicatorDialog._internal();

  BuildContext? _context;
  bool isDisplayed = false;

  factory ProgressIndicatorDialog() {
    return _singleton;
  }

  ProgressIndicatorDialog._internal();

  show(BuildContext context, {String text = "loading..."}) {
    if (isDisplayed == true) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        _context = context;
        isDisplayed = true;

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
  }

  dismiss() {
    if (isDisplayed == true && _context != null) {
      Navigator.of(_context!).pop();
      isDisplayed = false;
      _context = null;
    }
  }
}
