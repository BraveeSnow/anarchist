import 'dart:async';
import 'dart:ui';

import 'package:anarchist/firebase_options.dart';
import 'package:anarchist/login.dart';
import 'package:anarchist/routes/account.dart';
import 'package:anarchist/routes/home.dart';
import 'package:anarchist/routes/list.dart';
import 'package:anarchist/routes/media_details.dart';
import 'package:anarchist/routes/search.dart';
import 'package:anarchist/types/anarchist_data.dart';
import 'package:anarchist/types/oauth_response.dart';
import 'package:anarchist/util/data_handler.dart';
import 'package:anarchist/util/oauth_handler.dart';
import 'package:anarchist/util/search_query.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';

void main() async {
  usePathUrlStrategy();

  // configure firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
    return true;
  };

  runApp(const Anarchist());
}

class Anarchist extends StatefulWidget {
  static final DataHandler dataHandler = DataHandler();

  const Anarchist({super.key});

  @override
  State<StatefulWidget> createState() => _AnarchistState();
}

class _AnarchistState extends State<Anarchist> {
  static bool _firstRun = true;

  final router = GoRouter(
    initialLocation: AnarchistMainPage.route,
    routes: [
      GoRoute(
        path: AnarchistMainPage.route,
        // TODO - create a cleaner approach to logging in
        redirect: _verifyLogin,
        builder: (context, state) => const AnarchistMainPage(),
        routes: [
          GoRoute(
            path: LoginPage.route,
            builder: (context, state) => const LoginPage(),
          ),
          GoRoute(
            // this route only serves to authenticate the user
            path: 'redirect',
            redirect: _authenticateUser,
          ),
        ],
      ),
      GoRoute(
          path: MediaDetailsPage.route,
          builder: (context, state) => MediaDetailsPage(
              mediaId: int.parse(state.pathParameters['id']!))),
    ],
  );

  static Future<String?> _verifyLogin(
      BuildContext context, GoRouterState state) async {
    // check if login was voluntarily skipped
    if (!_firstRun) {
      return null;
    } else {
      _firstRun = false;
    }

    // go to login page if a token is not found
    AnarchistData schema = await Anarchist.dataHandler.readData();
    if (schema.accessToken != null) {
      return null;
    }

    return '/${LoginPage.route}';
  }

  static Future<String?> _authenticateUser(
      BuildContext context, GoRouterState state) async {
    AnarchistData schema;
    OAuthResponse? tokens =
        await OAuthHandler.retrieveToken(state.uri.queryParameters['code']!);

    if (tokens == null) {
      return '/${LoginPage.route}';
    }

    schema = AnarchistData(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      tokenExpiry: tokens.expiresIn,
    );
    Anarchist.dataHandler.writeData(schema);
    return AnarchistMainPage.route;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      theme: ThemeData.dark(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale("en"),
        Locale("ru"),
      ],
    );
  }
}

class AnarchistMainPage extends StatefulWidget {
  static const String route = '/';

  const AnarchistMainPage({super.key});

  @override
  State<StatefulWidget> createState() => _AnarchistMainPageState();
}

class _AnarchistMainPageState extends State<AnarchistMainPage> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: mainNavigationBar(),
      body: SafeArea(
        child: [
          const HomePage(),
          const SearchPage(),
          ListPage(key: UniqueKey(), mediaType: MediaType.anime),
          ListPage(key: UniqueKey(), mediaType: MediaType.manga),
          const AccountPage(),
        ][currentPage],
      ),
    );
  }

  NavigationBar mainNavigationBar() {
    return NavigationBar(
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: AppLocalizations.of(context)!.navbarHome,
        ),
        NavigationDestination(
          icon: const Icon(Icons.search_outlined),
          selectedIcon: const Icon(Icons.search),
          label: AppLocalizations.of(context)!.navbarSearch,
        ),
        NavigationDestination(
          icon: const Icon(Icons.play_arrow_outlined),
          selectedIcon: const Icon(Icons.play_arrow),
          label: AppLocalizations.of(context)!.navbarAnime,
        ),
        NavigationDestination(
          icon: const Icon(Icons.book_outlined),
          selectedIcon: const Icon(Icons.book),
          label: AppLocalizations.of(context)!.navbarManga,
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outlined),
          selectedIcon: const Icon(Icons.person),
          label: AppLocalizations.of(context)!.navbarAccount,
        ),
      ],
      selectedIndex: currentPage,
      onDestinationSelected: (int selected) {
        setState(() {
          currentPage = selected;
        });
      },
    );
  }
}
