import 'package:anarchist/types/anilist_data.dart';
import 'package:anarchist/util/constants.dart';
import 'package:anarchist/util/search_query.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MediaDetailsPage extends StatelessWidget with SearchQueryHandler {
  static const String route = '/details/:id';
  static const double _bannerHeight = 256;

  late final Future<DetailedMediaEntry> _mediaEntry;

  MediaDetailsPage({super.key, required int mediaId}) {
    _mediaEntry = fetchMediaDetails(mediaId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
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
        Text(details.preferredName!,
            style: const TextStyle(fontSize: fontSizeSecondaryTitle)),
      ],
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
