import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:window_manager/window_manager.dart";
import "package:wordsmith_admin_panel/widgets/dashboard.dart";
import "package:wordsmith_utils/logger.dart";
import "package:wordsmith_utils/models/ebook_report.dart";
import "package:wordsmith_utils/providers/ebook_reports_provider.dart";
import "package:wordsmith_utils/providers/user_login_provider.dart";
import "package:wordsmith_utils/providers/user_provider.dart";
import "package:wordsmith_utils/providers/user_reports_provider.dart";
import "package:wordsmith_utils/size_config.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Setting the minimum window size that is allowed. This is cross-platform
  WindowOptions options = const WindowOptions(
    minimumSize: Size(800, 600),
  );

  windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  if (kReleaseMode) {
    LogManager.init(LogLevel.INFO);
  } else {
    LogManager.init(LogLevel.WARNING);
  }

  final mainLogger = LogManager.getLogger("Main");

  FlutterError.onError = (FlutterErrorDetails details) {
    mainLogger.severe(details.exception);
  };

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => UserLoginProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => UserProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => UserReportsProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => EBookReportsProvider(),
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

    return MaterialApp(
      title: "Wordsmith Admin Panel",
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
      home: const DashboardWidget(title: Text("Wordsmith")),
    );
  }
}
