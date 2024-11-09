import 'package:anarchist/util/search_query.dart';
import 'package:flutter/material.dart';

import '../types/anilist_data.dart';
import '../util/data_handler.dart';

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
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        Map<String, UserWatchlist> mappedUserLists = {};
        for (final watchlist in snapshot.data!) {
          mappedUserLists[watchlist.name] = watchlist;
        }

        UserIdentity? identity = DataHandler().identity;
        return ListView.builder(
          itemCount: identity?.animeSectionOrder.length ?? 0,
          itemBuilder: (context, index) {
            // TODO: this may not be the best way to go about things
            // some lists are defined in user identity but not guaranteed in
            // fetching user lists
            if (snapshot.data == null ||
                !mappedUserLists.keys
                    .contains(identity!.animeSectionOrder[index])) {
              return Container();
            }
            return renderUserList(
                mappedUserLists[identity.animeSectionOrder[index]]!);
          },
        );
      },
    );
  }

  Widget renderUserList(UserWatchlist watchlist) {
    return Column(
      children: [
        Text(watchlist.name, style: const TextStyle(fontSize: 24)),
        ...watchlist.entries.map((e) => SearchCard(entry: e)),
      ],
    );
  }
}
