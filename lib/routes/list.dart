import 'dart:developer';

import 'package:anarchist/util/search_query.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    log('test');
    return Column(
      children: [
        Text(watchlist.name, style: const TextStyle(fontSize: 24)),
        ...watchlist.entries.map((e) => UserMediaEntryCard(userEntry: e)),
      ],
    );
  }
}

class UserMediaEntryCard extends StatelessWidget {
  static const double _cardSize = 150;
  final UserMediaEntry userEntry;

  const UserMediaEntryCard({super.key, required this.userEntry});

  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints:
          const BoxConstraints(minHeight: _cardSize, maxHeight: _cardSize),
      child: Card.outlined(
        child: Row(
          children: [
            CachedNetworkImage(imageUrl: userEntry.mediaEntry.coverImageURL!),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _titleLabels(context),
                    _statusRow(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleLabels(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          userEntry.mediaEntry.englishName!.isNotEmpty
              ? userEntry.mediaEntry.englishName!
              : userEntry.mediaEntry.romajiName!,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          userEntry.mediaEntry.nativeName!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
        ),
      ],
    );
  }

  Widget _statusRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('${userEntry.progress}/${userEntry.mediaEntry.episodes ?? '?'}'),
        _statusButton(context)
      ],
    );
  }

  Widget _statusButton(BuildContext context) {
    return switch (userEntry.status) {
      MediaListStatus.current => FilledButton(
          onPressed: () {},
          style: FilledButton.styleFrom(
              backgroundColor: catppuccin.mocha.sapphire),
          child: Text(AppLocalizations.of(context)!.listWatching),
        ),
      MediaListStatus.planning => FilledButton(
          onPressed: () {},
          style:
              FilledButton.styleFrom(backgroundColor: catppuccin.mocha.yellow),
          child: Text(AppLocalizations.of(context)!.listPlanning),
        ),
      MediaListStatus.completed => FilledButton(
          onPressed: () {},
          style:
              FilledButton.styleFrom(backgroundColor: catppuccin.mocha.green),
          child: Text(AppLocalizations.of(context)!.listCompleted),
        ),
      MediaListStatus.dropped => FilledButton(
          onPressed: () {},
          style: FilledButton.styleFrom(backgroundColor: catppuccin.mocha.red),
          child: Text(AppLocalizations.of(context)!.listDropped),
        ),
      MediaListStatus.paused => FilledButton(
          onPressed: () {},
          style:
              FilledButton.styleFrom(backgroundColor: catppuccin.mocha.peach),
          child: Text(AppLocalizations.of(context)!.listPaused),
        ),
      MediaListStatus.repeating => FilledButton(
          onPressed: () {},
          style: FilledButton.styleFrom(backgroundColor: catppuccin.mocha.pink),
          child: Text(AppLocalizations.of(context)!.listRepeating),
        ),
    };
  }
}
