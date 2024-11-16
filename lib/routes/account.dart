import 'package:anarchist/types/anilist_data.dart';
import 'package:anarchist/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:anarchist/util/search_query.dart';

class AccountPage extends StatelessWidget with AuthorizedQueryHandler {
  const AccountPage({super.key});

  Future<UserIdentity?> loadUser() async {
    return await getUserIdentityfromName("Braveesnow");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserIdentity?>(
      future: loadUser(), // The Future you want to wait on
      builder: (context, snapshot) {
        // Checking the state of the Future
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
                child: CircularProgressIndicator()), // While waiting, show a loading indicator
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot
                .error}')), // Show error message if the Future fails
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text(
                'No user data found')), // Show message if no data is returned
          );
        } else {
          final user = snapshot.data!;
          return Scaffold(
            //appBar: AppBar(title: Text('Welcome, ${user.name}')),
            body: Center(child: Column(
              children: [
                ShaderMask(shaderCallback: (rect) =>
                    const LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, Colors.transparent]
                    ).createShader(rect),
                  child: Image.network(user.bannerimg),
                ),
                _usernameinfo(user),
                _userpage(context, user)
              ],
            )
            ), // Show the user's info
          );
        }
      },
    );
  }

  Widget _usernameinfo(UserIdentity user) {
    return SizedBox(
      height: 100, // Adjust height to fit content
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        // Align items vertically in the center
        children: [
          // Avatar on the left
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: paddingScreenEdge),
            child: ClipOval(
              child: Image.network(
                user.userimg,
                width: 80, // Avatar size
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Text (username and additional info) next to the avatar
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              // Add space between avatar and text
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                // Align text to the left
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5), // Spacing between rows
                  const Row(
                    children: [
                      Text("1", style: TextStyle(fontSize: 16)),
                      SizedBox(width: 10), // Spacing between elements
                      //Text("${user.favoriteanimesid[0]['id']}",style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _userpage(BuildContext context, UserIdentity user) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _useranimecarossel(context, user)
      ],
    );
  }

  Widget _useranimecarossel(BuildContext context, user) {
    return ConstrainedBox(
      constraints: BoxConstraints(
          maxHeight: 250, maxWidth: MediaQuery
          .sizeOf(context)
          .width),
      child: CarouselView(
          itemExtent: 120,
          itemSnapping: true,
          children: List.generate(
            12,
              (index){
                return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    //child: Text("${user.favoriteanimesid[index]['id']}"),
                    child: _useranime(user.favoriteanimesid[index]['id']),
                );
              }
          )
      )
      //child: Text("${}")
    );
  }

  
  
  Widget _useranime(int animeid) {
    return FutureBuilder<MediaEntry?>(
      future: getmediafromID(animeid),
      builder: (BuildContext context, AsyncSnapshot<MediaEntry?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          String title = snapshot.data?.englishName ?? 'Unknown';
          String image = snapshot.data?.coverImageURLHD ?? 'https://cdn.frankerfacez.com/emoticon/742598/4';

          return Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 110,
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(image),
                alignment: Alignment.center,
                fit: BoxFit.cover,
              ),
            ),
            child: ColoredBox(
              color: Colors.black.withOpacity(0.75),
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
          } else {
          return Text("No data available");
        }
      },
    );

    // return LayoutBuilder(
    //   builder: (context, constraints) {
    //     print('Tile size: ${constraints.maxWidth} x ${constraints.maxHeight}');
    //     return FutureBuilder<MediaEntry?>(
    //       future: getmediafromID(animeid),
    //       builder: (BuildContext context, AsyncSnapshot<MediaEntry?> snapshot) {
    //         if (snapshot.connectionState == ConnectionState.waiting) {
    //           return CircularProgressIndicator();
    //         } else if (snapshot.hasError) {
    //           return Text('Error: ${snapshot.error}');
    //         } else if (snapshot.hasData) {
    //           final String title = snapshot.data?.englishName ?? 'Unknown Title';
    //           final String image = snapshot.data?.coverImageURLHD ?? 'https://cdn.frankerfacez.com/emoticon/742598/4';
    //           return Container(
    //             width: constraints.maxWidth,
    //             height: constraints.maxHeight,
    //             alignment: Alignment.bottomCenter,
    //             decoration: BoxDecoration(
    //               image: DecorationImage(
    //                 image: NetworkImage(image),
    //                 alignment: Alignment.center,
    //                 fit: BoxFit.cover,
    //               ),
    //             ),
    //             child: ColoredBox(
    //               color: Colors.black.withOpacity(0.75),
    //               child: Text(
    //                 title,
    //                 style: const TextStyle(color: Colors.white, fontSize: 16),
    //                 textAlign: TextAlign.center,
    //                 maxLines: 1,
    //                 overflow: TextOverflow.ellipsis,
    //               ),
    //             ),
    //           );
    //         } else {
    //           return Text('No data found');
    //         }
    //       },
    //     );
    //   },
    //);
  }
}
