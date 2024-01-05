import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wordsmith_mobile/widgets/navigation_bar.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/size_config.dart';

void main() {
  if (kReleaseMode) {
    LogManager.init(LogLevel.WARNING);
  } else {
    LogManager.init(LogLevel.INFO);
  }

  final mainLogger = LogManager.getLogger("Main");

  FlutterError.onError = (FlutterErrorDetails details) {
    mainLogger.severe(details.exception);
  };

  runApp(const Application());
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return MaterialApp(
      title: "Wordsmith Mobile Client",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue, brightness: Brightness.dark),
        useMaterial3: true,
        fontFamily: "Inter",
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            fontWeight: FontWeight.normal,
          ),
          bodyMedium: TextStyle(
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      home: const NavigationBarWidget(
        title: Text("Wordsmith"),
      ),
    );
  }
}
