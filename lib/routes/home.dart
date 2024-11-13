import 'package:anarchist/types/anilist_data.dart';
import 'package:anarchist/util/constants.dart';
import 'package:anarchist/util/search_query.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SearchQueryHandler {
  static const int maxTrendingEntries = 5;
  static const double carouselItemExtent = 330;

  late Future<List<MediaEntry>> _trending;

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
    return FutureBuilder(
      future: _trending,
      builder: (context, snapshot) {
        return ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: 250, maxWidth: MediaQuery.of(context).size.width),
          child: CarouselView(
            itemExtent: carouselItemExtent,
            itemSnapping: true,
            onTap: (index) {
              context.push('/details/${snapshot.data![index].id}');
            },
            children: List.generate(
              maxTrendingEntries,
              (index) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const CircularProgressIndicator();
                }

                return TrendingCard(entry: snapshot.data![index]);
              },
            ),
          ),
        );
      },
    );
  }
}

// class LoadingCard extends StatelessWidget {
//
// }

class TrendingCard extends StatelessWidget {
  final MediaEntry entry;

  const TrendingCard({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(entry.coverImageURLHD!),
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
                entry.preferredName!,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
                overflow: TextOverflow.fade,
                softWrap: false,
                maxLines: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
