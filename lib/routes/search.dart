import 'dart:math';

import 'package:anarchist/types/anilist_data.dart';
import 'package:anarchist/util/search_query.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum SearchType { anime, manga }

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SearchQueryHandler {
  SearchType type = SearchType.anime;
  String? searchQuery;
  TextEditingController tCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          searchTypeButton(),
          Padding(
            padding: const EdgeInsets.all(8),
            child: searchBar(),
          ),
          buildBody(context)
        ],
      ),
    );
  }

  SegmentedButton searchTypeButton() {
    return SegmentedButton<SearchType>(
      segments: [
        ButtonSegment(
          value: SearchType.anime,
          label: Text(AppLocalizations.of(context)!.navbarAnime),
        ),
        ButtonSegment(
            value: SearchType.manga,
            label: Text(AppLocalizations.of(context)!.navbarManga))
      ],
      selected: <SearchType>{type},
      onSelectionChanged: (Set<SearchType> selected) {
        setState(() {
          type = selected.first;
          tCon.clear();
        });
      },
    );
  }

  SearchAnchor searchBar() {
    return SearchAnchor(builder: (context, controller) {
      return SearchBar(
        // add horizontal padding to conform to material 3 specs
        // https://m3.material.io/components/search/specs#8d0982eb-5b42-40e3-a9d9-db6cb7ccd3cc
        hintText: AppLocalizations.of(context)!.searchPlaceholder,
        padding:
            const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
        leading: const Icon(Icons.search),
        controller: tCon,
        trailing: searchQuery == null
            ? null
            : [
                IconButton(
                    onPressed: () {
                      setState(() {
                        tCon.clear();
                        searchQuery = null;
                      });
                    },
                    icon: const Icon(Icons.clear))
              ],
        onChanged: (changed) {
          controller.text = changed;
        },
        onTapOutside: (_) {
          setState(() {
            FocusScope.of(context).unfocus();
            if (controller.text.isEmpty) {
              searchQuery = null;
            } else {
              searchQuery = controller.text;
            }
          });
        },
        onSubmitted: (searchString) {
          setState(() {
            if (controller.text.isEmpty) {
              searchQuery = null;
            } else {
              searchQuery = controller.text;
            }
          });
        },
      );
    }, suggestionsBuilder: (context, controller) async {
      return []; //Maybe store past searches and grab them here?
    });
  }

  Future<List<MediaEntry>> fetchSearchResults(String query) async {
    final data = await fetchSearchCards(query, type.name);
    return data;
  }

  Widget buildBody(BuildContext context) {
    if (searchQuery == null) {
      return buildNoSearchBody(context);
    }
    return buildSearchBody(context);
  }

  Widget buildNoSearchBody(BuildContext context) {
    return Expanded(
      child: GridView.count(
        primary: false,
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        children: [
          GestureDetector(
            child: Card(
              child: Center(
                  child: Text(AppLocalizations.of(context)!.searchTop100)),
            ),
            onTap: () {
              searchQuery = "_top100_";
              tCon.text = AppLocalizations.of(context)!.searchTop100;
              setState(() {});
            },
          ),
          GestureDetector(
            child: Card(
              child: Center(
                  child: Text(AppLocalizations.of(context)!.searchTrending)),
            ),
            onTap: () {
              searchQuery = "_trending_";
              tCon.text = AppLocalizations.of(context)!.searchTrending;
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget buildSearchBody(BuildContext context) {
    Future<List<MediaEntry>> futureData;

    if (searchQuery == "_top100_") {
      futureData = fetchTop(type.name);
    } else if (searchQuery == "_trending_") {
      futureData = fetchTrending(type.name);
    } else {
      futureData = fetchSearchResults(searchQuery ?? "");
    }

    return FutureBuilder(
        future: futureData,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            searchQuery = null;
            return const Text("Nothing Found!");
          }

          List<MediaEntry> entries = snapshot.data!;
          int size = entries.length;

          return Flexible(
              child: ListView.builder(
                  itemBuilder: (context, index) {
                    return SearchCard(entry: entries[index]);
                  },
                  itemCount: max(0, size)));

          return Text("AAAA");
        });
  }
}
