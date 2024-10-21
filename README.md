# Anarchist 🔥

[![forthebadge](https://forthebadge.com/images/badges/made-with-flutter.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/images/badges/built-for-android.svg)](https://forthebadge.com)

Anarchist is an unofficial mobile app for [AniList](https://anilist.co/).

## Building

For the app to work properly, `OAUTH_SECRET` must be defined through `--dart-define`. Otherwise,
authentication will not work. You can build the android apk like so:

```sh
flutter build apk --dart-define OAUTH_SECRET="<OAUTH_SECRET>"
```
