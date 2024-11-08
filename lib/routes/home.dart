import 'package:anarchist/util/constants.dart';
import 'package:anarchist/util/search_query.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SearchQueryHandler {
  static const int maxTrendingEntries = 5;
  static const double carouselItemExtent = 330;

  late Future<List<SearchCard>> _trending;

  _HomePageState() {
    _trending = fetchTrending("ANIME");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.homeTrendingTitle,
          style: const TextStyle(fontSize: fontSizeSecondaryTitle),
        ),
        trendingCarousel(context),
      ],
    );
  }

  Widget trendingCarousel(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
          maxHeight: 250, maxWidth: MediaQuery.sizeOf(context).width),
      child: CarouselView(
        itemExtent: carouselItemExtent,
        itemSnapping: true,
        children: List.generate(
          maxTrendingEntries,
          (index) {
            return FutureBuilder(
              future: _trending,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                return TrendingCard(
                    title: snapshot.data![index].nameEnglish,
                    imageUri: snapshot.data![index].coverImageURLHD);
              },
            );
          },
        ),
      ),
    );
  }
}

// class LoadingCard extends StatelessWidget {
//
// }

class TrendingCard extends StatelessWidget {
  final String title;
  final String imageUri;

  const TrendingCard({
    super.key,
    required this.title,
    required this.imageUri,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imageUri),
          alignment: Alignment.center,
          fit: BoxFit.cover,
        ),
      ),
      child: ColoredBox(
        color: Colors.black.withOpacity(0.75),
        child: LayoutBuilder(
          builder: (context, constraint) => SizedBox(
            width: constraint.maxWidth,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
                overflow: TextOverflow.clip,
                maxLines: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
