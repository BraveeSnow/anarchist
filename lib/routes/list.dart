import 'package:flutter/cupertino.dart';

enum ListType {
  anime,
  manga,
}

class ListPage extends StatefulWidget {
  const ListPage({super.key, required this.mediaType});

  final ListType mediaType;

  @override
  State<StatefulWidget> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  @override
  Widget build(BuildContext context) {
    if (widget.mediaType == ListType.anime) {
      return const Text("Anime page");
    } else {
      return const Text("Manga page");
    }
  }
}