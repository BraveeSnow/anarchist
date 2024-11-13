import 'package:anarchist/types/anilist_data.dart';
import 'package:anarchist/util/constants.dart';
import 'package:anarchist/util/search_query.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MediaDetailsPage extends StatelessWidget with SearchQueryHandler {
  static const String route = '/details/:id';
  static const double _bannerHeight = 200;

  late final Future<DetailedMediaEntry> _mediaEntry;

  MediaDetailsPage({super.key, required int mediaId}) {
    _mediaEntry = fetchMediaDetails(mediaId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: FutureBuilder(
        future: _mediaEntry,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _errorScreen(snapshot.error);
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return _body(snapshot.data!);
        },
      ),
    );
  }

  Widget _body(DetailedMediaEntry details) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            begin: Alignment.center,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.transparent],
          ).createShader(rect),
          child: Image.network(
            details.bannerImage,
            height: _bannerHeight,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        _titleInformation(details),
      ],
    );
  }

  Widget _titleInformation(DetailedMediaEntry details) {
    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: paddingWidgetSpacer),
            child: Image.network(
              details.coverImageURLHD!,
            ),
          ),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  details.preferredName!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16),
                ),
                Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite_outline),
                    ),
                    FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.playlist_add),
                      label: const Text('Add to List'),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorScreen(Object? error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(paddingScreenEdge),
            child: Icon(Icons.warning),
          ),
          Text(error.toString(), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
