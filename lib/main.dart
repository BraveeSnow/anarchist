import 'package:anarchist/routes/account.dart';
import 'package:anarchist/routes/home.dart';
import 'package:anarchist/routes/list.dart';
import 'package:anarchist/routes/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const Anarchist());
}

class Anarchist extends StatelessWidget {
  const Anarchist({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const AnarchistMainPage(),
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
        child: const [
          HomePage(),
          SearchPage(),
          ListPage(mediaType: ListType.anime),
          ListPage(mediaType: ListType.manga),
          AccountPage(),
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
