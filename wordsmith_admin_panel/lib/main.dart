import "package:adaptive_theme/adaptive_theme.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:provider/provider.dart";
import "package:window_manager/window_manager.dart";
import "package:wordsmith_admin_panel/utils/reports_filter_values.dart";
import "package:wordsmith_admin_panel/utils/themes.dart";
import "package:wordsmith_admin_panel/widgets/dashboard/dashboard.dart";
import "package:wordsmith_utils/dialogs/progress_indicator_dialog.dart";
import "package:wordsmith_utils/formatters/datetime_formatter.dart";
import "package:wordsmith_utils/logger.dart";
import "package:wordsmith_utils/providers/auth_provider.dart";
import "package:wordsmith_utils/providers/base_provider.dart";
import "package:wordsmith_utils/providers/ebook_provider.dart";
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
    LogManager.init(LogLevel.WARNING);
  } else {
    LogManager.init(LogLevel.INFO);
  }

  await dotenv.load();
  BaseProvider.apiUrl =
      dotenv.get("API_URL", fallback: "https://localhost:6443/");

  initializeDateFormattingForLocale();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => UserLoginProvider()),
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => UserReportsProvider()),
      ChangeNotifierProvider(create: (_) => EbookReportsProvider()),
      ChangeNotifierProvider(create: (_) => ReportFilterValuesProvider()),
      ChangeNotifierProvider(create: (_) => EbookProvider()),
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
      light: ThemeManager.generateLightTheme(),
      dark: ThemeManager.generateDarkTheme(),
      initial: AdaptiveThemeMode.dark,
      builder: (theme, darkTheme) => MaterialApp(
        title: "Wordsmith Admin Panel",
        theme: theme,
        darkTheme: darkTheme,
        home: const DashboardWidget(title: Text("Wordsmith")),
        navigatorKey: navigatorKey,
      ),
    );
  }
}
