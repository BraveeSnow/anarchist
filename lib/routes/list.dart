import 'dart:developer';

import 'package:anarchist/util/search_query.dart';
import 'package:flutter/cupertino.dart';

import '../types/anilist_data.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key, required this.mediaType});

  final MediaType mediaType;

  @override
  State<StatefulWidget> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> with AuthorizedQueryHandler {
  late final Future<List<UserWatchlist>?> _userWatchlists =
      fetchUserLists(widget.mediaType);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _userWatchlists,
      builder: (context, snapshot) {
        return ListView.builder(
          itemCount: snapshot.data?.length ?? 0,
          itemBuilder: (context, index) {
            if (snapshot.data == null) {
              return null;
            }
            log(snapshot.data!.length.toString());
            return renderUserList(snapshot.data![index]);
          },
        );
      },
    );
  }

  Widget renderUserList(UserWatchlist watchlist) {
    log(watchlist.entries.length.toString());
    return Column(
      children: [
        Text(watchlist.name, style: const TextStyle(fontSize: 24)),
        ...watchlist.entries.map((e) => SearchCard(entry: e)),
      ],
    );
  }
}
