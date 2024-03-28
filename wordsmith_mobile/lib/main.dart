import 'dart:io';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:wordsmith_mobile/utils/indexers/ebook_index_provider.dart';
import 'package:wordsmith_mobile/utils/indexers/base_index_provider.dart';
import 'package:wordsmith_mobile/utils/indexers/user_index_provider.dart';
import 'package:wordsmith_mobile/utils/themes.dart';
import 'package:wordsmith_mobile/x509_override.dart';
import 'package:wordsmith_mobile/widgets/navigation_bar/navigation_bar.dart';
import 'package:wordsmith_utils/dialogs/progress_indicator_dialog.dart';
import 'package:wordsmith_utils/formatters/datetime_formatter.dart';
import 'package:wordsmith_utils/logger.dart';
import 'package:wordsmith_utils/providers/auth_provider.dart';
import 'package:wordsmith_utils/providers/base_provider.dart';
import 'package:wordsmith_utils/providers/comment_provider.dart';
import 'package:wordsmith_utils/providers/ebook_download_provider.dart';
import 'package:wordsmith_utils/providers/ebook_parse_provider.dart';
import 'package:wordsmith_utils/providers/ebook_provider.dart';
import 'package:wordsmith_utils/providers/ebook_rating_provider.dart';
import 'package:wordsmith_utils/providers/ebook_rating_statistics_provider.dart';
import 'package:wordsmith_utils/providers/genre_provider.dart';
import 'package:wordsmith_utils/providers/maturity_ratings_provider.dart';
import 'package:wordsmith_utils/providers/order_provider.dart';
import 'package:wordsmith_utils/providers/user_library_category_provider.dart';
import 'package:wordsmith_utils/providers/user_library_provider.dart';
import 'package:wordsmith_utils/providers/user_login_provider.dart';
import 'package:wordsmith_utils/providers/user_provider.dart';
import 'package:wordsmith_utils/size_config.dart';

Future<void> main() async {
  if (kReleaseMode) {
    LogManager.init(LogLevel.WARNING);
  } else {
    LogManager.init(LogLevel.INFO);
  }

  await dotenv.load();
  BaseProvider.apiUrl =
      dotenv.get("API_URL", fallback: "https://localhost:6443/");

  // Disables X509 certificate verification in order for self-signed backend certificates to work
  HttpOverrides.global = X509Override();

  initializeDateFormattingForLocale();

  await BaseIndexProvider.initDatabase();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => UserLoginProvider()),
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => EbookParseProvider()),
      ChangeNotifierProvider(create: (_) => EbookDownloadProvider()),
      ChangeNotifierProvider(create: (_) => GenreProvider()),
      ChangeNotifierProvider(create: (_) => MaturityRatingsProvider()),
      ChangeNotifierProvider(create: (_) => EbookProvider()),
      ChangeNotifierProvider(create: (_) => UserLibraryProvider()),
      ChangeNotifierProvider(create: (_) => UserLibraryCategoryProvider()),
      ChangeNotifierProvider(create: (_) => EbookIndexProvider()),
      ChangeNotifierProvider(create: (_) => UserIndexProvider()),
      ChangeNotifierProvider(create: (_) => OrderProvider()),
      ChangeNotifierProvider(create: (_) => EbookRatingProvider()),
      ChangeNotifierProvider(create: (_) => EbookRatingStatisticsProvider()),
      ChangeNotifierProvider(create: (_) => CommentProvider()),
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
        title: "Wordsmith Mobile Client",
        theme: theme,
        darkTheme: darkTheme,
        home: const NavigationBarWidget(),
        navigatorKey: navigatorKey,
      ),
    );
  }
}
