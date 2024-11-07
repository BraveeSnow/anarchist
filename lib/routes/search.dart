import 'package:anarchist/util/search_query.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum SearchType { anime, manga }

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SearchQueryHandler{
  SearchType type = SearchType.anime;

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
          Expanded(
            child: GridView.count(
              primary: false,
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              children: [
                Card(
                  child: Center(
                      child: Text(AppLocalizations.of(context)!.searchTop100)),
                ),
                Card(
                  child: Center(
                      child:
                          Text(AppLocalizations.of(context)!.searchTrending)),
                ),
              ],
            ),
          )
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
        onTap: () {
          setState(() {
            controller.openView();
          });
        },
        onChanged: (_) {
          setState(() {
            controller.openView();
          });
        },
        onTapOutside: (_) {
          setState(() {
            controller.closeView(controller.text);
          });
        },
      );
    }, suggestionsBuilder: (context, controller) {
      return fetchSearchResults(controller); //Maybe store past searches and grab them here?
    });
  }

  Future<List<SearchCard>> fetchSearchResults(SearchController controller) async {
    final data = await fetchSearchCards(controller.text, type.name);
    return data;
  }
}
