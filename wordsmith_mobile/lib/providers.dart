import 'package:provider/provider.dart';
import 'package:wordsmith_utils/providers/auth_provider.dart';
import 'package:wordsmith_utils/providers/ebook_parse_provider.dart';
import 'package:wordsmith_utils/providers/ebook_provider.dart';
import 'package:wordsmith_utils/providers/genre_provider.dart';
import 'package:wordsmith_utils/providers/maturity_ratings_provider.dart';
import 'package:wordsmith_utils/providers/user_library_category_provider.dart';
import 'package:wordsmith_utils/providers/user_library_provider.dart';
import 'package:wordsmith_utils/providers/user_login_provider.dart';
import 'package:wordsmith_utils/providers/user_provider.dart';

List<ChangeNotifierProvider> getProviders() {
  return [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => UserLoginProvider()),
    ChangeNotifierProvider(create: (_) => UserProvider()),
    ChangeNotifierProvider(create: (_) => EBookParseProvider()),
    ChangeNotifierProvider(create: (_) => GenreProvider()),
    ChangeNotifierProvider(create: (_) => MaturityRatingsProvider()),
    ChangeNotifierProvider(create: (_) => EBookProvider()),
    ChangeNotifierProvider(create: (_) => UserLibraryProvider()),
    ChangeNotifierProvider(create: (_) => UserLibraryCategoryProvider()),
  ];
}
