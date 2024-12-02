import 'package:anarchist/types/UserPreference.dart';
import 'package:anarchist/types/anilist_data.dart';
import 'package:anarchist/types/UserPreference.dart';
import 'package:anarchist/util/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:anarchist/util/search_query.dart';
import 'package:anarchist/util/data_handler.dart';
import 'package:firebase_core/firebase_core.dart';


class AccountPage extends StatelessWidget with AuthorizedQueryHandler {
  const AccountPage({super.key});

  Future<UserIdentity?> loadUser() async {
    if (DataHandler().identity == null) {
      print("No login given default account used");
      return await getUserIdentityfromName("Braveesnow");
    }
    return DataHandler().identity;
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
            body: Center(
              child: Column(
                children: [
                  _buildBannerImageWithButton(user, context), // Updated
                  _usernameinfo(user),
                  _userpage(context, user),
                ],
              ),
            ),
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
                  Row(
                    children: [
                      Text("anilist ID: ${user.id}", style: TextStyle(fontSize: 16)),
                      SizedBox(width: 10),
                      // Spacing between elements
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

  ShaderMask _buildBannerImageWithButton(UserIdentity user,
      BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) =>
          const LinearGradient(
            begin: Alignment.center,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.transparent],
          ).createShader(rect),
      child: Stack(
        children: [
          // Banner Image
          Image.network(
            user.bannerimg,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 16,
            right: 16,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
                // Adjust padding inside the button
                backgroundColor: Colors.black.withOpacity(
                    0.5), // Semi-transparent background
              ),
              onPressed: () {
                //Move to settings screen
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => _accountsettings(user))
                );
              },
              child: const Icon(
                Icons.settings,
                color: Colors.white,
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
        _useranimecarossel(context, user),
        _statspage(user)
      ],
    );
  }

  Widget _useranimecarossel(BuildContext context, UserIdentity user) {
    return FutureBuilder<List<MediaEntry>?>(
      future: getmediafromID(
          user.favoriteanimesid.map((anime) => anime['id'] as int).toList()),
      builder: (BuildContext context,
          AsyncSnapshot<List<MediaEntry>?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          print("Error: ${snapshot.error}");
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print("No animes found");
          return const Text("No favorite anime found");
        } else {
          final mediaEntries = snapshot.data!;
          print("Media Entries: ${mediaEntries.map((e) => e.preferredName).toList()}");
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 250,
              maxWidth: MediaQuery
                  .sizeOf(context)
                  .width,
            ),
            child: CarouselView(
              itemExtent: 300,
              children: mediaEntries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _animeCard(entry),
                );
              }).toList(),
            )
          );
        }
      },
    );
  }

  Widget _animeCard(MediaEntry entry) {
    return Container(
      width: 120,
      height: 200,
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(entry.coverImageURLHD ?? ""),
          alignment: Alignment.center,
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ColoredBox(
        color: Colors.black.withOpacity(0.75),
        child: Text(
          entry.preferredName ?? "No Name Available",
          style: const TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Future<List<dynamic>> getallgenredata(UserIdentity user) async {
    List<int> animeIds = user.favoriteanimesid.map((
        anime) => anime['id'] as int).toList();
    List<MediaEntry>? mediaEntries = await getmediafromID(animeIds);

    if (mediaEntries == null) return [];

    // Collect genres, ensuring no duplicates
    Set<dynamic> genres = {};
    for (var entry in mediaEntries) {
      if (entry.genre != null) {
        genres.addAll(entry.genre!);
      }
    }

    return genres.toList();
  }


  Widget _statspage(UserIdentity user) {
    return FutureBuilder<List<dynamic>>(
      future: getallgenredata(user),
      builder: (context, genresSnapshot) {
        if (genresSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (genresSnapshot.hasError) {
          return Center(child: Text('Error: ${genresSnapshot.error}'));
        } else if (!genresSnapshot.hasData || genresSnapshot.data!.isEmpty) {
          return const Center(child: Text('No genres found'));
        } else {
          final genres = genresSnapshot.data!;
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                "Your Top Genres",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: genres.length,
                  itemBuilder: (context, index) {
                    final genre = genres[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Chip(
                        label: Text(
                          genre.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

}

class _accountsettings extends StatefulWidget{
  final UserIdentity user;

  const _accountsettings(this.user, {super.key});

  @override
  State<_accountsettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<_accountsettings> with AuthorizedQueryHandler{
  late TextEditingController _aboutMeController;
  String _selectedTimezone = "UTC";
  bool _adultContentEnabled = false;

  @override
  void initState() {
    super.initState();
    _aboutMeController = TextEditingController();
  }

  //-------------------------------------------------------------------------------

  Future<UserPreference?> getUserPreference(int userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('referencesforuserpreference')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty){
        print("Error getting data");
        return null;
      }

      return UserPreference.fromFirestore(snapshot.docs.first.data());
    } catch (e) {
      print('Error fetching user preferences: $e');
      return null;
    }
  }

  Future<void> updateUserPreference(UserPreference preference) async {
    try {
      await FirebaseFirestore.instance
          .collection('referencesforuserpreference')
          .doc(preference.userId.toString())
          .set(preference.toFirestore());
    } catch (e) {
      print('Error updating user preferences: $e');
    }
  }

  //-------------------------------------------------------------------------------

  @override
  void dispose() {
    _aboutMeController.dispose();
    super.dispose();
  }

  void _submitSettings() async{
    final updatedPreference = UserPreference(
      userId: widget.user.id,
      aboutMe: _aboutMeController.text,
      adultContent: _adultContentEnabled,
      timezone: _selectedTimezone,
    );

    await updateUserPreference(updatedPreference);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getUserPreference(widget.user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            _aboutMeController.text = "No user available";
            _selectedTimezone = "UTC";
            _adultContentEnabled = false;
            return Scaffold(
              appBar: AppBar(
                title: const Text("Account Settings"),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "About Me",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _aboutMeController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Tell us about yourself...",
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Timezone",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedTimezone,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedTimezone = newValue!;
                        });
                      },
                      items: const [
                        DropdownMenuItem(value: "UTC", child: Text("UTC")),
                        DropdownMenuItem(value: "GMT", child: Text("GMT")),
                        DropdownMenuItem(value: "EST", child: Text("EST")),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Show Adult Content",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Switch(
                          value: _adultContentEnabled,
                          onChanged: (bool value) {
                            setState(() {
                              _adultContentEnabled = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: _submitSettings,
                child: const Icon(Icons.check),
              ),
            );
          } else {
            final userPreference = snapshot.data!;
            _aboutMeController.text = userPreference.aboutMe ?? "";
            _selectedTimezone = userPreference.timezone ?? "UTC";
            _adultContentEnabled = userPreference.adultContent ?? false;

            return Scaffold(
              appBar: AppBar(
                title: const Text("Account Settings"),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "About Me",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _aboutMeController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Tell us about yourself...",
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Timezone",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedTimezone,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedTimezone = newValue!;
                        });
                      },
                      items: const [
                        DropdownMenuItem(value: "UTC", child: Text("UTC")),
                        DropdownMenuItem(value: "GMT", child: Text("GMT")),
                        DropdownMenuItem(value: "EST", child: Text("EST")),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Show Adult Content",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Switch(
                          value: _adultContentEnabled,
                          onChanged: (bool value) {
                            setState(() {
                              _adultContentEnabled = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: _submitSettings,
                child: const Icon(Icons.check),
              ),
            );
          }
        }
    );
  }
}
