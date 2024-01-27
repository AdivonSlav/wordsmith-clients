import 'dart:io';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/widgets/navigation_bar.dart';
import 'package:wordsmith_utils/datetime_formatter.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/providers/auth_provider.dart';
import 'package:wordsmith_utils/providers/ebook_parse_provider.dart';
import 'package:wordsmith_utils/providers/ebook_provider.dart';
import 'package:wordsmith_utils/providers/genre_provider.dart';
import 'package:wordsmith_utils/providers/maturity_ratings_provider.dart';
import 'package:wordsmith_utils/providers/user_login_provider.dart';
import 'package:wordsmith_utils/providers/user_provider.dart';
import 'package:wordsmith_utils/size_config.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

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

  // Disables X509 certificate verification in order for self-signed backend certificates to work
  HttpOverrides.global = MyHttpOverrides();

  initializeDateFormattingForLocale();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => UserLoginProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => UserProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => EBookParseProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => GenreProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => MaturityRatingsProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => EBookProvider(),
      )
    ],
    child: const Application(),
  ));
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return AdaptiveTheme(
      light: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
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
      dark: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
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
      initial: AdaptiveThemeMode.dark,
      builder: (theme, darkTheme) => MaterialApp(
        title: "Wordsmith Mobile Client",
        theme: theme,
        darkTheme: darkTheme,
        home: const NavigationBarWidget(),
      ),
    );
  }
}
