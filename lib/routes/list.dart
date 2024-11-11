import 'package:anarchist/util/constants.dart';
import 'package:anarchist/util/search_query.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../types/anilist_data.dart';
import '../util/data_handler.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key, required this.mediaType});

  final MediaType mediaType;

  @override
  State<StatefulWidget> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> with AuthorizedQueryHandler {
  late Future<List<UserWatchlist>?> _userWatchlists =
      fetchUserLists(widget.mediaType);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _userWatchlists.asStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(paddingScreenEdge),
                  child: Icon(Icons.warning),
                ),
                Text(snapshot.error.toString(), textAlign: TextAlign.center),
              ],
            ),
          );
        }
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(paddingWidgetSpacer),
          child: Text(watchlist.name, style: const TextStyle(fontSize: fontSizeSecondaryTitle)),
        ),
        ...watchlist.entries.map((e) => UserMediaEntryCard(
            userEntry: e, entryUpdateCallback: updateEntryCallback)),
      ],
    );
  }

  void updateEntryCallback(int mediaId, MediaListStatus status) async {
    await mutateUserMediaEntry(mediaId, status);
    setState(() {
      _userWatchlists = fetchUserLists(widget.mediaType);
    });
  }
}

class UserMediaEntryCard extends StatelessWidget {
  static const double _cardSize = 150;

  final UserMediaEntry userEntry;
  final Function(int, MediaListStatus) entryUpdateCallback;

  const UserMediaEntryCard(
      {super.key, required this.userEntry, required this.entryUpdateCallback});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints:
          const BoxConstraints(minHeight: _cardSize, maxHeight: _cardSize),
      child: Card.outlined(
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: userEntry.mediaEntry.coverImageURL!,
              fit: BoxFit.fitHeight,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(paddingScreenEdge),
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userEntry.score != 0)
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: paddingSmallSpacing),
                    child: Icon(Icons.star, color: catppuccin.mocha.yellow),
                  ),
                  Text('${userEntry.score}/10'),
                ],
              ),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: paddingSmallSpacing),
                  child: Icon(Icons.movie_outlined),
                ),
                Text(
                    '${userEntry.progress}/${userEntry.mediaEntry.episodes ?? '?'}'),
              ],
            ),
          ],
        ),
        _statusButton(context)
      ],
    );
  }

  Widget _statusButton(BuildContext context) {
    return switch (userEntry.status) {
      MediaListStatus.current => FilledButton.icon(
          onPressed: () => _sendToNewList(context),
          style: FilledButton.styleFrom(
              backgroundColor: catppuccin.mocha.sapphire),
          icon: const Icon(Icons.play_arrow),
          label: Text(AppLocalizations.of(context)!.listWatching),
        ),
      MediaListStatus.planning => FilledButton.icon(
          onPressed: () => _sendToNewList(context),
          style:
              FilledButton.styleFrom(backgroundColor: catppuccin.mocha.yellow),
          icon: const Icon(Icons.access_time_filled),
          label: Text(AppLocalizations.of(context)!.listPlanning),
        ),
      MediaListStatus.completed => FilledButton.icon(
          onPressed: () => _sendToNewList(context),
          style:
              FilledButton.styleFrom(backgroundColor: catppuccin.mocha.green),
          icon: const Icon(Icons.check),
          label: Text(AppLocalizations.of(context)!.listCompleted),
        ),
      MediaListStatus.dropped => FilledButton.icon(
          onPressed: () => _sendToNewList(context),
          style: FilledButton.styleFrom(backgroundColor: catppuccin.mocha.red),
          icon: const Icon(Icons.delete),
          label: Text(AppLocalizations.of(context)!.listDropped),
        ),
      MediaListStatus.paused => FilledButton.icon(
          onPressed: () => _sendToNewList(context),
          style:
              FilledButton.styleFrom(backgroundColor: catppuccin.mocha.peach),
          icon: const Icon(Icons.pause),
          label: Text(AppLocalizations.of(context)!.listPaused),
        ),
      MediaListStatus.repeating => FilledButton.icon(
          onPressed: () => _sendToNewList(context),
          style: FilledButton.styleFrom(backgroundColor: catppuccin.mocha.pink),
          icon: const Icon(Icons.repeat),
          label: Text(AppLocalizations.of(context)!.listRepeating),
        ),
    };
  }

  void _sendToNewList(BuildContext context) {
    MediaListStatus selected = userEntry.status;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.listChangeListTitle),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
            },
            child: Text(AppLocalizations.of(context)!.dialogCancel),
          ),
          TextButton(
            onPressed: () {
              // needless to change if the status is the same
              if (selected == userEntry.status) {
                context.pop();
                return;
              }

              // proceed with updating entry
              entryUpdateCallback(userEntry.id, selected);
              context.pop();
            },
            child: Text(AppLocalizations.of(context)!.dialogConfirm),
          ),
        ],
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context)!.listChangeListDialog),
              ...MediaListStatus.values.map((status) => RadioListTile(
                  title: Text(switch (status) {
                    MediaListStatus.current =>
                      AppLocalizations.of(context)!.listWatching,
                    MediaListStatus.planning =>
                      AppLocalizations.of(context)!.listPlanning,
                    MediaListStatus.completed =>
                      AppLocalizations.of(context)!.listCompleted,
                    MediaListStatus.dropped =>
                      AppLocalizations.of(context)!.listDropped,
                    MediaListStatus.paused =>
                      AppLocalizations.of(context)!.listPaused,
                    MediaListStatus.repeating =>
                      AppLocalizations.of(context)!.listRepeating,
                  }),
                  value: status,
                  groupValue: selected,
                  onChanged: (changed) {
                    setState(() {
                      selected = changed!;
                    });
                  })),
            ],
          ),
        ),
      ),
    );
  }
}
